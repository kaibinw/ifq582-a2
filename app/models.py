from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

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

    users = db.relationship(
        'Users',
        secondary='UsersCommunity',
        backref='communities'
    )
    # helpful for debugging - when using print() it gives everything in the return line.
    def __repr__(self):
        return f'<Community {self.communityID}: {self.communityName}>'

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

    # collectionStatus = db.Column(
    #     db.Enum('Option A', 'Option B'),
    #     nullable=False
    # )

    collectionDateCreated = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )

    def __repr__(self):
        return f'<Collection {self.collectionID}: {self.collectionName}>'

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
        db.String(60),
        nullable=False
    )

    communities = db.relationship(
        'Community',
        secondary='UsersCommunity',
        backref='users'
    )

    def __repr__(self):
        return f'<User {self.userID}: {self.userEmail}>'



class Item(db.Model):
    __tablename__ = 'Item'
    
    itemID = db.Column(
        db.Integer,
        autoincrement=True,
        primary_key=True
    )
    
    collectionID = db.Column(
        db.Integer,
        nullable=False,
        db.ForeignKey('Collection.collectionID')
    )
    
    communityID = db.Column(
        db.Integer,
        nullable=False,
        db.ForeignKey('Community.communityID')
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

    def __repr__(self):
        return f'<Items: {self.itemID}: {self.itemTitle}>'    


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

    # pending confirmation if item created date is true.
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

    def __repr__(self):
        return f'<UserCommunity: User {self.userID} ↔ Community {self.communityID}>'



