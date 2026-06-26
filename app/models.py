"""
Ngurra Digital Library - Database Models

This file contains helper functions that connect Flask routes to the MySQL database.

Models / Tables:
    - Community: cultural communities
    - Collection: collections of items
    - Users: system users with roles and permissions
    - Item: individual library items
    - CulturalMetadata: metadata, approval status and sensitivity levels
    - UsersCommunity: junction table for many-to-many relationship between Community and Users
    - ApprovalComment: approval discussion comments
    - ItemAccessRequest: requests to access restricted items
    - ItemAccessApproval: approval decisions for access requests
"""

from datetime import datetime
from . import mysql


def get_cursor():
    return mysql.connect.cursor()


"""
Community helpers
"""


def get_all_communities():
    cursor = get_cursor()
    sql = """
    SELECT 
        communityID, 
        communityName, 
        communityRegion 
    FROM Community
    """
    cursor.execute(sql)
    results = cursor.fetchall()
    return results


def get_community_by_id(community_id):
    """Fetch ONE community by its community ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        communityName, 
        communityRegion 
    FROM Community 
    WHERE communityID = %s
    """
    cursor.execute(sql, (community_id,))
    result = cursor.fetchone()
    return result


"""
Collection helpers
"""


def get_collection_by_id(collection_id):
    cursor = get_cursor()
    sql = """
    SELECT 
        collectionName, 
        collectionShortName, 
        collectionDateCreated 
    FROM Collection 
    WHERE collectionID = %s
    """
    cursor.execute(sql, (collection_id,))
    result = cursor.fetchone()
    return result


"""
Item helpers
"""


def get_all_items_with_metadata():
    """
    Fetch all items with their related community, collection and cultural metadata.

    This is used by the Home page, search and filters.
    """
    cursor = get_cursor()
    sql = """
    SELECT 
        i.itemID,
        i.itemTitle,
        i.itemDescription,
        i.itemDate,
        i.itemImage,
        i.itemMediaType,

        c.communityID,
        c.communityName,
        c.communityRegion,

        col.collectionID,
        col.collectionName,
        col.collectionShortName,
        col.collectionDateCreated,

        cm.metadataID,
        cm.itemStatus,
        cm.itemStatusHeader,
        cm.itemApprovalDate,
        cm.itemApproverID,
        cm.itemLanguageGroup,
        cm.itemCulturalNote,
        cm.itemSensitivityLabel,
        cm.itemCulturalWarningFlag,
        cm.itemCulturalWarningText

    FROM Item i
    LEFT JOIN Community c 
        ON i.communityID = c.communityID
    LEFT JOIN Collection col 
        ON i.collectionID = col.collectionID
    LEFT JOIN CulturalMetadata cm 
        ON i.itemID = cm.itemID
    ORDER BY i.itemDate DESC
    """
    cursor.execute(sql)
    results = cursor.fetchall()
    return results


def get_item_with_metadata(item_id):
    """
    Fetch one item with its community, collection, approver and cultural metadata.

    This is used by the Item Details page and Assessment page.
    """
    cursor = get_cursor()
    sql = """
    SELECT 
        i.itemID,
        i.itemTitle,
        i.itemDescription,
        i.itemDate,
        i.itemImage,
        i.itemMediaType,
        i.collectionID,
        i.communityID,

        c.communityName,
        c.communityRegion,

        col.collectionName,
        col.collectionShortName,
        col.collectionDateCreated,

        u.userHonourific,
        u.userFirstName,
        u.userLastName,

        cm.metadataID,
        cm.itemStatus,
        cm.itemStatusHeader,
        cm.itemApprovalDate,
        cm.itemApproverID,
        cm.itemLanguageGroup,
        cm.itemCulturalNote,
        cm.itemSensitivityLabel,
        cm.itemCulturalWarningFlag,
        cm.itemCulturalWarningText

    FROM Item i
    LEFT JOIN CulturalMetadata cm 
        ON i.itemID = cm.itemID
    LEFT JOIN Community c 
        ON i.communityID = c.communityID
    LEFT JOIN Collection col 
        ON i.collectionID = col.collectionID
    LEFT JOIN Users u 
        ON cm.itemApproverID = u.userID
    WHERE i.itemID = %s
    """
    cursor.execute(sql, (item_id,))
    result = cursor.fetchone()
    return result


"""
User helpers
"""


def get_all_users():
    """Fetch ALL users"""
    cursor = get_cursor()
    sql = """
    SELECT 
        userID, 
        userHonourific, 
        userLastName, 
        userFirstName, 
        userEmail, 
        userRole, 
        userPermissionLevel 
    FROM Users
    """
    cursor.execute(sql)
    results = cursor.fetchall()
    return results


def get_user_by_id(user_id):
    """Fetch ONE user by their user ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        userID,
        userHonourific, 
        userLastName, 
        userFirstName, 
        userEmail, 
        userRole, 
        userPermissionLevel, 
        userPassword 
    FROM Users 
    WHERE userID = %s
    """
    cursor.execute(sql, (user_id,))
    result = cursor.fetchone()
    return result


def get_user_by_email(email):
    """Fetch ONE user by their email"""
    cursor = get_cursor()
    sql = """
    SELECT 
        userID,
        userHonourific, 
        userLastName, 
        userFirstName, 
        userEmail,
        userRole, 
        userPermissionLevel, 
        userPassword 
    FROM Users 
    WHERE userEmail = %s
    """
    cursor.execute(sql, (email,))
    result = cursor.fetchone()
    return result


def get_communities_for_user(user_id):
    """Fetch all communities for user by user ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        communityID 
    FROM UsersCommunity 
    WHERE userID = %s
    """
    cursor.execute(sql, (user_id,))
    results = cursor.fetchall()
    return results


"""
Approval comment helpers
"""


def get_approvals_by_item_id(item_id):
    """Fetch approval comments by item ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        approvalDiscussionID, 
        approvalDiscussionText, 
        approvalDiscussionDate, 
        userID 
    FROM ApprovalComment 
    WHERE itemID = %s
    """
    cursor.execute(sql, (item_id,))
    result = cursor.fetchall()
    return result


def get_approvals_by_user_id(user_id):
    """Fetch approval comments by user ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        approvalDiscussionID, 
        approvalDiscussionText, 
        approvalDiscussionDate, 
        itemID 
    FROM ApprovalComment 
    WHERE userID = %s
    """
    cursor.execute(sql, (user_id,))
    result = cursor.fetchall()
    return result


"""
Item access request helpers
"""


def get_requests_by_user_id(user_id):
    """Fetch access requests by user ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        requestID, 
        requestReasonText, 
        requestDate, 
        requestStatus, 
        itemID 
    FROM ItemAccessRequest 
    WHERE userID = %s
    """
    cursor.execute(sql, (user_id,))
    result = cursor.fetchall()
    return result


def get_requests_by_item_id(item_id):
    """Fetch access requests by item ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        requestID, 
        requestReasonText, 
        requestDate, 
        requestStatus, 
        userID 
    FROM ItemAccessRequest 
    WHERE itemID = %s
    """
    cursor.execute(sql, (item_id,))
    result = cursor.fetchall()
    return result


def get_request_by_id(request_id):
    """Fetch one access request by request ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        requestReasonText, 
        requestDate, 
        requestStatus, 
        userID, 
        itemID 
    FROM ItemAccessRequest 
    WHERE requestID = %s
    """
    cursor.execute(sql, (request_id,))
    result = cursor.fetchone()
    return result


"""
Item access approval helpers
"""


def get_approval_by_id(access_approval_id):
    """Fetch one access approval by approval ID"""
    cursor = get_cursor()
    sql = """
    SELECT 
        accessApprovalStatus, 
        accessApprovalDate, 
        requestID, 
        approverID 
    FROM ItemAccessApproval 
    WHERE accessApprovalID = %s
    """
    cursor.execute(sql, (access_approval_id,))
    result = cursor.fetchone()
    return result

def create_access_request(user_id, item_id, reason_text):
    cursor = get_cursor()
    sql = """
    INSERT INTO ItemAccessRequest (userID, itemID, requestReasonText, requestStatus)
    VALUES (%s, %s, %s, 'Open')
    """
    cursor.execute(sql, (user_id, item_id, reason_text))
    mysql.connect.commit()
    return True


"""
Pending helpers for future development
"""


# def get_approval_statuses_by_approver_id(approver_id):
#     cursor = get_cursor()
#     sql = """
#     SELECT 
#         accessApprovalStatus, 
#         accessApprovalDate, 
#         requestID, 
#         accessApprovalID 
#     FROM ItemAccessApproval 
#     WHERE approverID = %s
#     """
#     cursor.execute(sql, (approver_id,))
#     result = cursor.fetchall()
#     return result
#
#
# def get_approval_status_by_request_id(request_id):
#     cursor = get_cursor()
#     sql = """
#     SELECT 
#         accessApprovalStatus, 
#         accessApprovalDate, 
#         approverID, 
#         accessApprovalID 
#     FROM ItemAccessApproval 
#     WHERE requestID = %s
#     """
#     cursor.execute(sql, (request_id,))
#     result = cursor.fetchone()
#     return result