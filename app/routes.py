from flask import Blueprint, render_template, request

main_bp = Blueprint('main', __name__)

# Temporary sample data for Claudia's pages
# Later this will be connected to the database models
sample_items = [
    {
        "id": 1,
        "title": "Memories of River Life",
        "description": "Oral history recording about community stories and river life.",
        "category": "Oral History",
        "cultural_group": "Yuggera Country",
        "access_level": "Public",
        "sensitivity_level": "Low",
        "review_status": "Approved",
        "year": "1977"
    },
    {
        "id": 2,
        "title": "Ceremonial Cultural Item",
        "description": "Restricted cultural item. Details are limited due to cultural sensitivity.",
        "category": "Ceremonial",
        "cultural_group": "Waka Waka Country",
        "access_level": "Restricted",
        "sensitivity_level": "High",
        "review_status": "Restricted",
        "year": "Unknown"
    },
    {
        "id": 3,
        "title": "Community Map",
        "description": "A cultural map currently pending approval before public access.",
        "category": "Map",
        "cultural_group": "Gugu Badhun",
        "access_level": "Community Only",
        "sensitivity_level": "Medium",
        "review_status": "Pending",
        "year": "Unknown"
    }
]


@main_bp.route('/')
def index():
    search_query = request.args.get('q', '').lower()
    category = request.args.get('category', '')

    filtered_items = sample_items

    if search_query:
        filtered_items = [
            item for item in filtered_items
            if search_query in item["title"].lower()
            or search_query in item["description"].lower()
            or search_query in item["cultural_group"].lower()
        ]

    if category:
        filtered_items = [
            item for item in filtered_items
            if item["category"] == category
        ]

    return render_template(
        'index.html',
        items=filtered_items,
        search_query=search_query,
        selected_category=category
    )


@main_bp.route('/item/<int:item_id>')
def item_detail(item_id):
    item = next((item for item in sample_items if item["id"] == item_id), None)

    if item is None:
        return "Item not found", 404

    return render_template('item_details.html', item=item)


@main_bp.route('/assessment/<int:item_id>')
def item_assessment(item_id):
    return render_template('item_assessment.html', id=item_id)
