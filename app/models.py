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
from flask_mysqldb import MySQL

mysql = MySQLdb()

"""
Community Model

Represents a cultural community in the Ngurra Library.
One Community can have many Items and many Users (via UsersCommunity junction table)
"""
def get_all_communities():
    cursor = mysql.connection.cursor()
    sql = "SELECT communityID, communityName, communityRegion FROM Community"
    cursor.execute(sql)
    results = cursor.fetchall()
    return results

def get_collection_by_id(collection_id):
    cursor = mysql.connection.cursor()
    sql = "SELECT collectionName, collectionShortName, collectionDateCreated FROM Collection WHERE collectionID = %s"
    cursor.execute(sql, (collection_id,))
    result = cursor.fetchone()
    return result

def get_all_items_with_metadata():
    cursor = mysql.connection.cursor()
    sql = "
    SELECT 
        i.itemID, i.itemDate, i.itemTitle, i.itemDescription, i.itemImage, i.itemMediaType,
        cm.itemStatus, cm.itemSensitivityLabel, cm.itemCulturalWarningFlag
    FROM Item i
    LEFT JOIN CulturalMetadata cm ON i.itemID = cm.itemID
        "
    cursor.execute(sql)
    results = cursor.fetchall()
    return results

def get_item_with_metadata(item_id):
    cursor = mysql.connection.cursor()
    sql = "
    SELECT 
        i.itemID, i.itemDate, i.itemTitle, i.itemDescription, i.itemImage, i.itemMediaType, i.collectionID, i.communityID, cm.metadataID,
        cm.itemStatus, cm.itemStatusHeader, cm.itemApprovalDate, cm.itemApproverID, cm.itemLanguageGroup, cm.itemCulturalNote, cm.itemSensitivityLabel,
        cm.itemCulturalWarningFlag, cm.itemCulturalWarningText
    FROM Item i
    LEFT JOIN CulturalMetadata cm ON i.itemID = cm.itemID
    WHERE i.itemID = %s"
    cursor.execute(sql, (item_id,))
    result = cursor.fetchone()
    return result

def get_all_users():
    """ Fetch ALL users"""
    cursor = mysql.connection.cursor()
    sql = "SELECT userID, userHonourific, userLastName, userFirstName, userEmail, userRole, userPermissionLevel FROM Users"
    cursor.execute(sql)
    results = cursor.fetchall()
    return results

def get_user_by_id(user_id):
    """ Fetch ONE user by their user ID"""
    cursor = mysql.connection.cursor()
    sql = "SELECT userHonourific, userLastName, userFirstName, userEmail, userRole, userPermissionLevel, userPassword FROM Users WHERE userID = %s"
    cursor.execute(sql, (user_id,))
    result = cursor.fetchone()
    return result

def get_user_by_email(email): 
    """ Fetch ONE user by their email"""
    cursor = mysql.connection.cursor()   
    sql = "SELECT userHonourific, userLastName, userFirstName, userID, userRole, userPermissionLevel, userPassword FROM Users WHERE userEmail = %s"
    cursor.execute(sql, (email,))
    result = cursor.fetchone()
    return result

def get_community_by_id(community_id):
    """ Fetch ONE community by its community ID"""
    cursor = mysql.connection.cursor()
    sql = "SELECT communityName, communityRegion FROM Community WHERE communityID = %s"
    cursor.execute(sql, (community_id,))
    result = cursor.fetchone()
    return result

def get_communities_for_user(user_id):
    "Fetch all communities for user by user ID"
    cursor = mysql.connection.cursor()
    sql = "SELECT communityID FROM UsersCommunity WHERE userID = %s"
    cursor.execute(sql, (user_id,))
    results = cursor.fetchall()
    return results

def get_approvals_by_item_id(item_id):
    """Fetch approvals by item ID"""
    cursor = mysql.connection.cursor()
    sql = "SELECT approvalDiscussionID, approvalDiscussionText, approvalDiscussionDate, userID FROM ApprovalComment WHERE itemID = %s"
    cursor.execute(sql, (item_id,))
    result = cursor.fetchall()
    return result

def get_approvals_by_user_id(user_id):
    """Fetch approvals by user ID"""
    cursor = mysql.connection.cursor()
    sql = "SELECT approvalDiscussionID, approvalDiscussionText, approvalDiscussionDate, itemID FROM ApprovalComment WHERE userID = %s"
    cursor.execute(sql, (user_id,))
    result = cursor.fetchall()
    return result

def get_requests_by_user_id(user_id):
    cursor = mysql.connection.cursor()
    sql = "SELECT requestID, requestReasonText, requestDate, requestStatus, itemID FROM ItemAccessRequest WHERE userID = %s"
    cursor.execute(sql, (user_id,))
    result = cursor.fetchall()
    return result

def get_requests_by_item_id(item_id):
    cursor = mysql.connection.cursor()
    sql = "SELECT requestID, requestReasonText, requestDate, requestStatus, userID FROM ItemAccessRequest WHERE itemID = %s"
    cursor.execute(sql, (item_id,))
    result = cursor.fetchall()
    return result

def get_request_by_id(request_id):
    cursor = mysql.connection.cursor()
    sql = "SELECT requestReasonText, requestDate, requestStatus, userID, itemID FROM ItemAccessRequest WHERE requestID = %s"
    cursor.execute(sql, (request_id,))
    result = cursor.fetchone()
    return result

def get_approval_by_id(access_approval_id):
    cursor = mysql.connection.cursor()
    sql = "SELECT accessApprovalStatus, accessApprovalDate, requestID, approverID FROM ItemAccessApproval WHERE accessApprovalID = %s"
    cursor.execute(sql, (access_approval_id,))
    result = cursor.fetchone()
    return result


"""
PENDING request for more helpers
"""

# def get_approval_statuses_by_approver_id(approver_id):
#     cursor = mysql.connection.cursor()
#     sql = "SELECT accessApprovalStatus, accessApprovalDate, requestID, access_approval_id FROM ItemAccessApproval WHERE approver_id = %s"
#     cursor.execute(sql, (approver_id,))
#     result = cursor.fetchall()
#     return result
# 
# def get_approval_status_by_id(request_id):
#     cursor = mysql.connection.cursor()
#     sql = "SELECT accessApprovalStatus, accessApprovalDate, approverID, accessApprovalID FROM ItemAccessApproval WHERE request_ID = %s"
#     cursor.execute(sql, (approver_id,))
#     result = cursor.fetchone()
#     return result
