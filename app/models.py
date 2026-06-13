# Placeholder models
# db instance will move into __init__.py when database is wired

from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy()

class Item(db.Model):
    __tablename__ = 'items'
    pass

class User(db.Model):
    __tablename__ = 'users'
    pass