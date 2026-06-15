# Ngurra Digital Library
A Flask web application for managing Indigenous cultural heritage under CARE Principles. 

---

## Quick Start
1. Clone the repo
2. `python -m venv venv`
3. `source venv/bin/activate`  (Mac/Linux) or `venv\Scripts\activate` (Windows)
4. `pip install -r requirements.txt`
5. Open MySQL Workbench, run 'data.sql' to create and seed the database
6. Update 'config.py' with your MySQL username and password
7. `python run.py` → visit `http://localhost:5000`

`git pull` 
run this whenever you start work to get everyone's latest commits. 
---

## Tech Stack
- **Backend:** Python, Flask
- **Frontend:** Jinja2 templates, Bootstrap 5.3
- **Database:** MySQL + SQLAlchemy ORM
- **Auth:** Flask-Login
- **Forms:** WTForms
- **Testing:** pytest

---

## Project Structure
app/
├── init.py         # Flask app factory
├── models.py        # SQLAlchemy models (Martin + Kai)
├── routes.py        # Flask routes (Jordan, Claudia, Matt add here)
templates/
├── base.html        # Jinja2 skeleton
├── index.html       # Home/catalog (Claudia)
├── item_details.html # Item view (Claudia)
└── item_assessment.html # Assessment panel (Matt)
static/
└── css/
└── custom.css   # Bootstrap 5 overrides (Kai)
config.py             # Flask config
run.py                # Entry point
requirements.txt      # Dependencies
README.md             # This file

---

## Team Assignments

<!-- SECTION 5: Who's doing what (helps avoid conflicts) -->
| Person | Responsibility |
|--------|-----------------|
| Martin | Database schema, SQLAlchemy models |
| Jordan | Flask-Login, registration, RBAC |
| Claudia | Home, catalog, search, item detail |
| Matt | Assessment panel, review workflow |
| Kai | CSS, responsive design, README, tests |

---

## Notes for Examiners (VIA)

<!-- Left blank for now, but important for submission -->
(Will fill in later — explain your design choices, what you built, how to navigate the code)
