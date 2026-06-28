from flask import Blueprint, render_template, request, redirect, url_for, session, abort
from . import models
from functools import wraps

main_bp = Blueprint('main', __name__)

def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('userID'):
            return redirect(url_for('main.login'))
        if session.get('userRole') != 'Admin':
            return render_template('error.html',
                                    code=403,
                                    message='Access denied. Admin privileges required.'), 403
        return f(*args, **kwargs)
    return decorated_function

def elder_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('userID'):
            return redirect(url_for('main.login'))
        if session.get('userRole') not in ('Elder', 'Admin'):
            return render_template('error.html',
                                    code=403,
                                    message='Access denied. Elder or Admin privileges required.'), 403
        return f(*args, **kwargs)
    return decorated_function

def curator_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('userID'):
            return redirect(url_for('main.login'))
        if session.get('userRole') not in ('Curator', 'Admin'):
            return render_template('error.html',
                                    code=403,
                                    message='Access denied. Curator or Admin privileges required.'), 403
        return f(*args, **kwargs)
    return decorated_function

@main_bp.route('/')
def index():
    search_query = request.args.get('q', '').lower()
    category = request.args.get('category', '')
    community = request.args.get('community', '')
    access_status = request.args.get('access_status', '')
    sensitivity = request.args.get('sensitivity', '')

    items = models.get_all_items_with_metadata()
    items = list(items)

    user_role = session.get('userRole', 'Public')
    if user_role == 'Public':
        items = [
            item for item in items
            if item.get('itemStatus') in ('Approve for Public Access',)
        ]
    
    if user_role == 'Curator':
        items = [
            item for item in items
            if item.get('itemSensitivityLabel') in ('Low', 'Moderate')
        ]
        # Curators cannot access High Sensitivity items

    # sorts the index by collection, then status (pending for Elder/Admin first, then date)
    if user_role in ('Elder', 'Admin'):
        items.sort(key=lambda x: (
            x.get('collectionName', ''),
            x['itemStatus'] != 'Pending Approval',
            x['itemDate']
        ))
    else:
        items.sort(key=lambda x: (
            x.get('collectionName', ''),
            x['itemDate']
        ))
    if search_query:
        items = [
            item for item in items
            if search_query in item['itemTitle'].lower()
            or search_query in item['itemDescription'].lower()
            or search_query in item.get('communityName', '').lower()
            or search_query in item.get('collectionName', '').lower()
        ]

    if category:
        items = [
            item for item in items
            if item['itemMediaType'] == category
        ]

    if community:
        items = [
            item for item in items
            if item.get('communityName') == community
        ]

    if access_status:
        items = [
            item for item in items
            if item.get('itemStatus') == access_status
        ]

    if sensitivity:
        items = [
            item for item in items
            if item.get('itemSensitivityLabel') == sensitivity
        ]

    return render_template(
        'index.html',
        items=items,
        search_query=search_query,
        selected_category=category,
        selected_community=community,
        selected_access_status=access_status,
        selected_sensitivity=sensitivity
    )


@main_bp.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        user = models.get_user_by_email(email)
        if user and user['userPassword'] == password:
            session['user_id'] = user['userID']
            session['user_name'] = f"{user['userHonourific'] or ''} {user['userFirstName']} {user['userLastName']}".strip()
            session['user_role'] = user['userRole']
            
            # Redirect to next url if available, otherwise home page
            next_url = request.args.get('next')
            return redirect(next_url or url_for('main.index'))
        else:
            error = "Invalid email or password."
            
    return render_template('login.html', error=error)

@main_bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('main.index'))

@main_bp.route('/about')
def about():
    """Display about page"""
    return render_template('about.html')

@main_bp.route('/item/<int:item_id>')
def item_detail(item_id):
    item = models.get_item_with_metadata(item_id)
    if not item:
        abort(404)
    return render_template('item_details.html', item=item)

@main_bp.route('/request/<int:item_id>', methods=['POST'])
def item_request(item_id):
    if not session.get('userID'):
        return redirect(url_for('main.login'))
    
    first_name = request.form.get('first_name')
    last_name = request.form.get('last_name')
    email = request.form.get('email')
    reason = request.form.get('reason')

    models.create_access_request(session['userID'], item_id, reason)

    return redirect(url_for('main.item_detail', item_id=item_id))

@main_bp.route('/assessment/<int:item_id>')
@elder_required
def item_assessment(item_id):
    # Ensure user is logged in
    if not session.get('user_id'):
        return redirect(url_for('main.login', next=request.url))
    
    # Restrict to Elder, Curator, Admin
    if session.get('user_role') not in ['Elder', 'Curator', 'Admin']:
        abort(403)
        
    item = models.get_item_with_metadata(item_id)
    if not item:
        abort(404)
        
    comments = models.get_approvals_by_item_id(item_id)
    return render_template('item_assessment.html', item=item, comments=comments)

@main_bp.route('/assessment/<int:item_id>/comment', methods=['POST'])
def add_comment(item_id):
    if not session.get('user_id'):
        return redirect(url_for('main.login'))
        
    if session.get('user_role') not in ['Elder', 'Curator', 'Admin']:
        abort(403)
        
    comment_text = request.form.get('comment_text', '').strip()
    if comment_text:
        models.add_approval_comment(
            item_id=item_id,
            user_id=session['user_id'],
            comment_text=comment_text
        )
        
    return redirect(url_for('main.item_assessment', item_id=item_id))

@main_bp.route('/assessment/<int:item_id>/decision', methods=['POST'])
def submit_decision(item_id):
    if not session.get('user_id'):
        return redirect(url_for('main.login'))
        
    if session.get('user_role') not in ['Elder', 'Curator', 'Admin']:
        abort(403)
        
    sensitivity = request.form.get('sensitivity')
    warning_text_raw = request.form.get('warning_text')
    notes = request.form.get('notes', '').strip()
    decision = request.form.get('decision')
    
    # Map sensitivity label to database enum ('High / Restricted' -> 'High')
    if sensitivity == 'High / Restricted':
        sensitivity_label = 'High'
    else:
        sensitivity_label = sensitivity
        
    # Map warning flag and warning text to database fields
    if warning_text_raw == 'May contain content of sensitive nature':
        warning_flag = True
        warning_text = 'May contain sensitive content'
    elif warning_text_raw == 'Contains ceremonial content restricted to initiated members':
        warning_flag = True
        warning_text = 'Contains ceremonial information restricted to initiated members'
    else:
        warning_flag = False
        warning_text = 'No warning required'
        
    # Map button clicked to database status enum
    if decision == 'Approve':
        status = 'Approve for Public Access'
    elif decision == 'Restrict':
        status = 'Restrict - Community Only'
    elif decision == 'Reject':
        status = 'Reject'
    else:
        status = 'Pending Approval'
        
    models.update_cultural_metadata(
        item_id=item_id,
        status=status,
        approver_id=session['user_id'],
        sensitivity=sensitivity_label,
        warning_flag=warning_flag,
        warning_text=warning_text,
        notes=notes
    )
    
    return redirect(url_for('main.item_assessment', item_id=item_id))
