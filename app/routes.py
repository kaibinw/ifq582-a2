from flask import Blueprint, render_template, request, session, redirect, url_for
from . import models

main_bp = Blueprint('main', __name__)


@main_bp.route('/')
def index():
    search_query = request.args.get('q', '').lower()
    category = request.args.get('category', '')
    community = request.args.get('community', '')
    access_status = request.args.get('access_status', '')
    sensitivity = request.args.get('sensitivity', '')

    # Treat "All" dropdown values as no filter
    if category in ['All', 'All media types']:
        category = ''

    if community in ['All', 'All communities']:
        community = ''

    if access_status in ['All', 'All access']:
        access_status = ''

    if sensitivity in ['All', 'All sensitivity levels']:
        sensitivity = ''

    # Get data from database
    items = models.get_all_items_with_metadata()
    media_types = models.get_unique_media_types()
    communities = models.get_all_communities()
    access_statuses = models.get_unique_access_statuses()
    sensitivity_levels = models.get_unique_sensitivity_levels()

    # Role-based visibility
    user_role = session.get('userRole', 'Public')
    user_id = session.get('userID')

    if user_role == 'Public':
        items = [
            item for item in items
            if 'public' in (item.get('itemStatus') or '').strip().lower()
            or 'public' in (item.get('itemStatusHeader') or '').strip().lower()
            or 'approved' in (item.get('itemStatus') or '').strip().lower()
            or 'approved' in (item.get('itemStatusHeader') or '').strip().lower()
        ]

    elif user_role == 'Curator':
        items = [
            item for item in items
            if item.get('itemSensitivityLabel') != 'High'
        ]

    elif user_role == 'Elder' and user_id:
        user_communities = models.get_communities_for_user(user_id)
        user_community_ids = [
            community['communityID'] for community in user_communities
        ]

        items = [
            item for item in items
            if item.get('communityID') in user_community_ids
        ]

    elif user_role == 'Admin':
        pass

    # Search filter
    if search_query:
        items = [
            item for item in items
            if search_query in item.get('itemTitle', '').lower()
            or search_query in item.get('itemDescription', '').lower()
            or search_query in item.get('communityName', '').lower()
            or search_query in item.get('collectionName', '').lower()
        ]

    # Dropdown filters
    if category:
        items = [
            item for item in items
            if item.get('itemMediaType') == category
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
            or item.get('itemStatusHeader') == access_status
        ]

    if sensitivity:
        items = [
            item for item in items
            if item.get('itemSensitivityLabel') == sensitivity
        ]

    return render_template(
        'index.html',
        items=items,
        media_types=media_types,
        communities=communities,
        access_statuses=access_statuses,
        sensitivity_levels=sensitivity_levels,
        search_query=search_query,
        selected_category=category,
        selected_community=community,
        selected_access_status=access_status,
        selected_sensitivity=sensitivity
    )


@main_bp.route('/about')
def about():
    return render_template('about.html')


@main_bp.route('/item/<int:item_id>')
def item_detail(item_id):
    item = models.get_item_with_metadata(item_id)

    if not item:
        return redirect(url_for('main.index'))

    return render_template('item_details.html', item=item)


@main_bp.route('/assessment/<int:item_id>')
def item_assessment(item_id):
    user_role = session.get('userRole', 'Public')

    if user_role not in ['Elder', 'Admin']:
        return redirect(url_for('main.index'))

    item = models.get_item_with_metadata(item_id)

    if not item:
        return redirect(url_for('main.index'))

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
            session['userName'] = (
                f"{user['userHonourific'] + ' ' if user['userHonourific'] else ''}"
                f"{user['userFirstName']} {user['userLastName']}"
            )
            return redirect(url_for('main.index'))
        else:
            error = 'Invalid email or password'

    return render_template('login.html', error=error)


@main_bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('main.index'))