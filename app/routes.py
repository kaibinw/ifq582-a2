from flask import Blueprint, render_template, request, session, redirect, url_for
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

    user_role = session.get('userRole', 'Public')
    if user_role == 'Public':
        items = [
            item for item in items
            if item.get('itemStatus') in ('Approve for Public Access',)
        ]

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


# add about page, no helper needed
# @main_bp.route('/about')
# def about():
#     return render_template('about.html')


@main_bp.route('/item/<int:item_id>')
def item_detail(item_id):
    item = models.get_item_with_metadata(item_id)
    return render_template('item_details.html', item=item)


@main_bp.route('/assessment/<int:item_id>')
@elder_required
def item_assessment(item_id):
    item = models.get_item_with_metadata(item_id)
    return render_template('item_assessment.html', item=item)


@main_bp.route('/login', methods=('GET', 'POST'))
def login():
    error = None

    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')

        user = models.get_user_by_email(email)

        if user and user['userPassword'] == password:
            session['userID'] = user['userID']
            session['userRole'] = user['userRole']
            session['userName'] = f"{user['userHonourific'] + ' ' if user['userHonourific'] else ''}{user['userFirstName']} {user['userLastName']}"
            return redirect(url_for('main.index'))
        else:
            error = 'Invalid email or password'

    return render_template('login.html', error=error)


@main_bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('main.index'))