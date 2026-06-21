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

    items = models.get_all_items_with_metadata()

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