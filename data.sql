-- Data Defintion for IFQ582 Assignment 2

-- create data base
CREATE DATABASE IF NOT EXISTS IFQ582;
USE IFQ582;

-- drop tables
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Community;
DROP TABLE IF EXISTS Collection;
DROP TABLE IF EXISTS CulturalMetadata;
DROP TABLE IF EXISTS Item;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS UsersCommunity;
DROP TABLE IF EXISTS ApprovalDiscussion;
DROP TABLE IF EXISTS ItemAccessRequest;
DROP TABLE IF EXISTS ItemAccessApproval;

SET FOREIGN_KEY_CHECKS = 1;

-- create tables
-- Community class
-- removed Contact Person as we should use Primary Keys as FKs and we have a separate table
CREATE TABLE IF NOT EXISTS Community (
	communityID INT AUTO_INCREMENT PRIMARY KEY, -- changed to int & auto increment 
    communityName VARCHAR(50) NOT NULL,
    communityRegion VARCHAR(50) NOT NULL -- not sure what this does? 
);

INSERT INTO Community 
	(communityName, communityRegion)
VALUES
	('Yuggera','South East Queensland'),
    ('Waka Waka','Central Queensland'),
    ('Gugu Badhun','North Queensland'),
    ('Kalkadoon','Northwest Queensland');
    
    
-- Collection class
CREATE TABLE IF NOT EXISTS Collection (
	collectionID INT AUTO_INCREMENT PRIMARY KEY, -- changed to int
    collectionName VARCHAR(250) NOT NULL, 
    collectionShortName VARCHAR(50) NOT NULL, -- e.g. 'oral history' or 'ceremonial'
    -- collectionStatus ENUM('Option A', 'Option B') NOT NULL, -- in the data model but unsure what values should be
    collectionDateCreated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP -- confirm if time stamp is fine, added a default value
); 

INSERT INTO Collection 
	(collectionName, collectionShortName, collectionDateCreated)
VALUES
	('Oral Histories of South East Queensland', 'Oral History', '2025-05-25'),
    ('Ceremonial and Sacred Records', 'Ceremonial', '2023-04-12'),
    ('Archival Photographic Collection', 'Photography', '2024-05-05');

-- Users class
CREATE TABLE IF NOT EXISTS Users (
    userID INT AUTO_INCREMENT PRIMARY KEY,
    userHonourific VARCHAR(50) NULL, -- added for "Aunties" & "Uncles"
    userLastName VARCHAR(50) NOT NULL, -- split up for 1NF, added to a composite index
    userFirstName VARCHAR(50) NOT NULL, -- split up for 1NF, added to a composite index
    userEmail VARCHAR(50) NOT NULL,
    userRole ENUM('Curator', 'Elder', 'Public', 'Admin') NOT NULL,  -- admin role for Assignment 2 req's
    userPermissionLevel INT NOT NULL,  
    userPassword VARCHAR(60) NOT NULL -- NOTE: hash using bcrypt in Python! password is for Assignment 2 req's 
);
CREATE INDEX idx_users_fullname ON Users(userLastName, userFirstName); 

INSERT INTO Users 
	(userHonourific, userLastName, userFirstName, userEmail, userRole, userPermissionLevel, userPassword)
VALUES
	(NULL, 'Sarah', 'Matthews', 's.matthews@ngurra.edu.au', 'Curator', 2, 'SM_password'),
    (NULL, 'Paul', 'Friend', 'p.friend@ngurra.edu.au', 'Curator', 2, 'PF_password'),
    (NULL, 'Job', 'Bluth', 'j.bluth@ngurra.edu.au', 'Public', 1, 'JB_password'),
    ('Aunty', 'Doris', 'Bancroft', 'd.bancroft@ngurra.edu.au', 'Elder', 3, 'DB_password'),
    (NULL, 'James', 'Johns', 'j.johns@ngurra.edu.au', 'Admin', 4, 'JJ_password');

-- Item class
CREATE TABLE IF NOT EXISTS Item (
	itemID INT AUTO_INCREMENT PRIMARY KEY, -- changed to int & auto increment
    collectionID INT NOT NULL,
    communityID INT NOT NULL,
    itemDate DATE NOT NULL,
    itemTitle VARCHAR(50) NOT NULL,
    itemDescription VARCHAR(250) NOT NULL,
    itemImage VARCHAR(50) NULL, -- placeholder for now, not sure how image files should work in SQL.
    itemMediaType ENUM('Audio Recording', 'Photograph', 'Map') NOT NULL, 
    CONSTRAINT item_collectionID_FK 
		FOREIGN KEY (collectionID) REFERENCES Collection(collectionID), 
	CONSTRAINT item_communityID_FK
		FOREIGN KEY (communityID) REFERENCES Community(communityID)
);

INSERT INTO Item 
	(collectionID, communityID, itemDate, itemTitle, itemDescription, itemImage, itemMediaType)
VALUES 
	(1, 1, '1990-05-01', 'Memories of River Life', 'Oral account of river life', 'ImagePlaceholder.png', 'Audio Recording'),
    (2, 2, '1999-05-01','Ceremonial gathering of 1999', 'Documentation of ceremonial practice', 'ImagePlaceholder.png', 'Photograph'),
    (3, 3, '1994-05-01','Sacred Site Mapping', 'Hand drawn sacred site maps', 'ImagePlaceholder.png', 'Map'),
    (3, 4, '1955-05-01','Rainforest Camp c.1955', 'Archival photographs of camp life', 'ImagePlaceholder.png', 'Photograph'),
	(3, 3, '1999-05-01','Sacred site gifts', 'Documentation of gifts exchanged at sacred site', 'ImagePlaceholder.png', 'Photograph');

-- Cultural metadata class
CREATE TABLE IF NOT EXISTS CulturalMetadata(
	metadataID INT AUTO_INCREMENT PRIMARY KEY, -- 
    itemID INT NOT NULL, -- add an index as this will be used all the time
	itemStatus ENUM('Approve for Public Access', 'Restrict - Community Only', 'Reject', 'Pending Approval') NOT NULL DEFAULT 'Pending Approval', 
    itemStatusHeader ENUM('RESTRICTED ACCESS - ELDER ADVISORY COUNCIL & AUTHORISED STAFF ONLY.') NULL DEFAULT NULL, 
    itemApprovalDate TIMESTAMP NULL DEFAULT NULL,
    itemApproverID INT NULL, -- this is a userID
	itemLanguageGroup VARCHAR(50) NOT NULL,
    itemCulturalNote VARCHAR(250) NOT NULL,
    itemSensitivityLabel ENUM('Low', 'Moderate', 'High') NULL DEFAULT NULL,
    itemCulturalWarningFlag BOOLEAN NOT NULL,
    itemCulturalWarningText ENUM('No warning required' ,'May contain sensitive content', 'Contains ceremonial information restricted to initiated members') NULL,
    CONSTRAINT culturalMetadata_itemID_FK 
		FOREIGN KEY (itemID) REFERENCES Item(itemID),
	CONSTRAINT item_approverID_FK
		FOREIGN KEY (itemApproverID) REFERENCES Users(userID)
);
CREATE INDEX idx_culturalMetadata_itemID ON CulturalMetadata(itemID);

INSERT INTO CulturalMetadata
	(itemID, itemStatus, itemApprovalDate, itemApproverID, itemLanguageGroup, itemCulturalNote, itemSensitivityLabel, itemCulturalWarningFlag, itemCulturalWarningText)
VALUES
	(1, 'Approve for Public Access', '2026-05-15', 4, 'Yuggera', 'Placeholder itemCulturalNote string', 'Low', FALSE, NULL),
    (2, 'Restrict - Community Only', '2026-05-15', 4, 'Waka Waka', 'Placeholder itemCulturalNote string', 'High', TRUE, 'Contains ceremonial information restricted to initiated members'),
    (3, 'Pending Approval', '2026-05-15', NULL, 'Gugu Badhun', 'Placeholder itemCulturalNote string', NULL, TRUE, 'May contain sensitive content'), 
    (4, 'Approve for Public Access', '2026-05-15', 4, 'Kalkadoon', 'Placeholder itemCulturalNote string', 'Low', FALSE, NULL),
    (5, 'Restrict - Community Only', '2026-05-15', 4, 'Gugu Badhun', 'Placeholder itemCulturalNote string', 'High', TRUE, 'Contains ceremonial information restricted to initiated members' );


-- UserCommunity bridging table
CREATE TABLE IF NOT EXISTS UsersCommunity(
	userID INT NOT NULL,
    communityID INT NOT NULL,
    PRIMARY KEY (userID, communityID),
    CONSTRAINT usersCommunity_userID_FK 
		FOREIGN KEY (userID) REFERENCES Users(userID),
	CONSTRAINT usersCommunity_communityID_FK
		FOREIGN KEY (communityID) REFERENCES Community(communityID)
) ;

INSERT INTO UsersCommunity
	(userID, communityID)
VALUES 
	(4, 3);

-- ApprovalDiscussion class
CREATE TABLE IF NOT EXISTS ApprovalComment(
    approvalDiscussionID INT AUTO_INCREMENT PRIMARY KEY,
    itemID INT NOT NULL, 
    userID INT NOT NULL,
    approvalDiscussionText VARCHAR(250) NOT NULL,
    approvalDiscussionDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT approvals_itemID_FK
        FOREIGN KEY (itemID) REFERENCES Item(itemID),
    CONSTRAINT approvals_userID_FK
        FOREIGN KEY (userID) REFERENCES Users(userID)
);

-- Item AccessRequest class
-- note that the form takes full name and Email address, change this:
-- run off the user authentication 
-- or use it as a trigger to ask for a log in 
-- and then use authentication to save the user id with the rest of the request?
CREATE TABLE IF NOT EXISTS ItemAccessRequest(
    requestID INT AUTO_INCREMENT PRIMARY KEY,
    userID INT NOT NULL,
    itemID INT NOT NULL,
    requestReasonText VARCHAR(250) NOT NULL,
    requestDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    requestStatus ENUM('Open', 'Closed') NOT NULL, -- a method to close the request once it has been fulfilled? 
    CONSTRAINT itemAccessRequest_userID_FK
        FOREIGN KEY (userID) REFERENCES Users(userID),
    CONSTRAINT itemAccessRequest_itemID_FK
        FOREIGN KEY (itemID) REFERENCES Item(itemID)
);

-- Item Access Request Approval class 
-- How much logging should we do? 
-- Last status & change date? or full status 
CREATE TABLE IF NOT EXISTS ItemAccessApproval(
    accessApprovalID INT AUTO_INCREMENT PRIMARY KEY,
    requestID INT NOT NULL,
    approverID INT NOT NULL,
    accessApprovalStatus ENUM('Approved', 'Not Approved')  NULL DEFAULT NULL, --maybe move this to a boolean with default of No
    accessApprovalDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT itemAccessApproval_requestID_FK
        FOREIGN KEY (requestID) REFERENCES ItemAccessRequest(requestID),
    CONSTRAINT itemAccessApproval_approverID_FKß
        FOREIGN KEY (approverID) REFERENCES Users(userID)
);
