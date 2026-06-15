from flask import Blueprint, render_template
from . import models

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    items = models.get_all_items_with_metadata()
    return render_template('index.html', items=items)

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