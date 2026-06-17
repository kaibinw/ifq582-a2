from flask import Blueprint, render_template, request
from . import models

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    search_query = request.args.get('q', '').lower()
    category = request.args.get('category', '')

    items = models.get_all_items_with_metadata()

    if search_query:
        items = [
            item for item in items
            if search_query in item['itemTitle'].lower()
            or search_query in item['itemDescription'].lower()
        ]

    if category:
        items = [
            item for item in items
            if item['itemMediaType'] == category
        ]

    return render_template(
        'index.html',
        items=items,
        search_query=search_query,
        selected_category=category
    )

@main_bp.route('/')
def index():
    items = models.get_all_items_with_metadata()
    return render_template(
        'index.html', 
        items=items
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