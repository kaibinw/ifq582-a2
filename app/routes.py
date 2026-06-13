from flask import Blueprint, render_template

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    return render_template('index.html')

# add about page
# @main_bp.route('/about')
# def about():
#     return render_template('about.html')

@main_bp.route('/item/<int:item_id>')
def item_detail(item_id):
    return render_template('item_details.html', id=item_id)

@main_bp.route('/assessment/<int:item_id>')
def item_assessment(item_id):
    return render_template('item_assessment.html', id=item_id)