"""
Ngurra Digital Library - Database Models

SQLAlchemy ORM mapping Python classes to MySQL tables
(Note: SQLAlchemy was chosen based on Flask best practices),
but requires lecturer approval as it was not on the initial permitted packages. 
If rewritten to use Flask-MySQLdb, the architecture remains the same.)

Models:
    - Community: cultural communities (1:N with Items, M:N with Users)
    - Collection: collection of items
    - Users: system users with roles and permissions
    - Item - individual library items
    - CulturalMetdata: metadata, approval status, sensitivity levels
    - UsersCommunity: junction table for many-to-many relationship between Community and Users

"""

from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

"""
Community Model

Represents a cultural community in the Ngurra Library.
One Community can have many Items and many Users (via UsersCommunity junction table)
"""
class Community(db.Model):
    __tablename__ = 'Community'
    
    communityID = db.Column(
        db.Integer,
        primary_key=True,
        autoincrement=True
    )

    communityName = db.Column(
        db.String(50),
        nullable=False
    )

    communityRegion = db.Column(
        db.String(50),
        nullable=False
    )

    # Many-to-many relationship: Community <-> Users
    # via junction table: UsersCommunity
    users = db.relationship(
        'Users',
        secondary='UsersCommunity',
        backref='communities'
    )

    # added for debugging - easy to see at a glance whether database is being pulled
    def __repr__(self):
        return f'<Community {self.communityID}: {self.communityName}>'

"""
Collection Model

Represents a collection of items in the library. 
"""
class Collection(db.Model):
    __tablename__ = 'Collection'

    collectionID = db.Column(
        db.Integer,
        primary_key=True,
        autoincrement=True
    )

    collectionName = db.Column(
        db.String(250),
        nullable=False
    )

    # pending values confirmation
    # collectionStatus = db.Column(
    #     db.Enum('Option A', 'Option B'),
    #     nullable=False
    # )

    collectionDateCreated = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )

    # added for debugging - easy to see at a glance whether database is being pulled
    def __repr__(self):
        return f'<Collection {self.collectionID}: {self.collectionName}>'

"""
Users Model

Represents all the users that are available for the library. 
One User can have multiple communities (via UsersCommunity junction table)
"""
class Users(db.Model):
    __tablename__ = 'Users'

    userID = db.Column(
        db.Integer,
        primary_key=True,
        autoincrement=True
    )

    userHonourific = db.Column(
        db.String(50),
        nullable=True
    )
    
    userLastName = db.Column(
        db.String(50),
        nullable=False
    )
    
    userFirstName = db.Column(
        db.String(50),
        nullable=False
    )
    
    userEmail = db.Column(
        db.String(50),
        nullable=False
    )
    
    userRole = db.Column(
        db.Enum('Curator', 'Elder', 'Public', 'Admin'),
        nullable=False
    )
    
    userPermissionLevel = db.Column(
        db.Integer,
        nullable=False
    )
    
    userPassword = db.Column(
        db.String(60), # password must be bcrypt hash, 60 chars
        nullable=False
    )

    # represents the many-to-many Community <-> Users relationship. 
    # via junction table
    communities = db.relationship(
        'Community',
        secondary='UsersCommunity',
        backref='users'
    )

    # added for debugging - easy to see at a glance whether database is being pulled
    def __repr__(self):
        return f'<User {self.userID}: {self.userEmail}>'

"""
Item Model

All the library items
Items in the library can be in many collections and community
"""

class Item(db.Model):
    __tablename__ = 'Item'
    
    itemID = db.Column(
        db.Integer,
        autoincrement=True,
        primary_key=True
    )
    
    collectionID = db.Column(
        db.Integer,
        db.ForeignKey('Collection.collectionID'),
        nullable=False
    )
    
    communityID = db.Column(
        db.Integer,
        db.ForeignKey('Community.communityID'),
        nullable=False        
    )
    
    itemTitle = db.Column(
        db.String(50),
        nullable=False
    )
    
    itemDescription = db.Column(
        db.String(250),
        nullable=False
    )
    
    itemImage = db.Column(
        db.String(50), # - placeholder for now, pending SQL fix for image files.
        nullable=True
    )
    
    itemMediaType = db.Column(
        db.String(50),
        nullable=False
    )

    collection = db.relationship('Collection', backref='items')
    community = db.relationship('Community', backref='items')

    # added for debugging - easy to see at a glance whether database is being pulled
    def __repr__(self):
        return f'<Items: {self.itemID}: {self.itemTitle}>'    

"""
Cultural Metadata Model

Contains all the cultural metadata for the items in the library. 
"""

class CulturalMetadata(db.Model):
    __tablename__ = 'CulturalMetadata'

    metadataID = db.Column(
        db.Integer,
        autoincrement=True,
        primary_key=True
    )

    itemID = db.Column(
        db.Integer,
        db.ForeignKey('Item.itemID'),
        nullable=False
    )

    itemStatus = db.Column(
        db.Enum('Approved', 'Restricted', 'Pending Approval'),
        nullable=False
    )

    itemApprovalDate = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        nullable=True
    )

    # pending confirmation if item created date is needed.
    # itemCreatedDate = db.Column(
    #     db.DateTime
    #     default=datetime.utcnow
    #     nullable=True
    # )

    itemApproverID = db.Column(
        db.Integer,
        db.ForeignKey('Users.userID'),
        nullable=True
    )

    itemLanguageGroup = db.Column(
        db.String(50),
        nullable=False
    )

    itemSensitivityLabel = db.Column(
        db.Enum('Low', 'Moderate', 'High'),
        default='Moderate',
        nullable=True
    )

    itemCulturalWarningFlag = db.Column(
        db.Boolean,
        nullable=False
    )

    itemCulturalWarningText = db.Column(
        db.String(250),
        nullable=True
    )

    item = db.relationship('Item', backref='culturalmetadata')
    user = db.relationship('Users', backref='culturalmetadata')

    # added for debugging - easy to see at a glance whether database is being pulled
    def __repr__(self):
        return f'<CulturalMetadata: {self.metadataID}: {self.itemID}, {self.itemStatus}>'



class UsersCommunity(db.Model):
    __tablename__ = 'UsersCommunity'

    userID = db.Column(
        db.Integer,
        db.ForeignKey('Users.userID'),
        primary_key=True
    )
    
    communityID = db.Column(
        db.Integer,
        db.ForeignKey('Community.communityID'),
        primary_key=True
    )

    # added for debugging - easy to see at a glance whether database is being pulled
    def __repr__(self):
        return f'<UserCommunity: User {self.userID} ↔ Community {self.communityID}>'



