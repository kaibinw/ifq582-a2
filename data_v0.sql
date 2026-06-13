-- Data Defintion for IFQ582 Assignment 2

-- create data base
create database if not exists IFQ582;
use IFQ582; 

-- drop tables
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Community;
DROP TABLE IF EXISTS Collection;
DROP TABLE IF EXISTS CulturalMetadata;
DROP TABLE IF EXISTS Item;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS UsersCommunity;

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
    -- collectionStatus ENUM('Option A', 'Option B') NOT NULL, -- unsure what values should be
    collectionDateCreated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP -- confirm if time stamp is fine, added a default value
); 

INSERT INTO Collection 
	(collectionName, collectionDateCreated)
VALUES
	('Oral Histories of South East Queensland','2025-05-25'),
    ('Ceremonial and Sacred Records','2023-04-12'),
    ('Archival Photographic Collection', '2024-05-05');

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
    itemTitle VARCHAR(50) NOT NULL,
    itemDescription VARCHAR(250) NOT NULL,
    itemImage VARCHAR(50) NULL, -- placeholder for now, not sure how image files should work in SQL.
    itemMediaType VARCHAR(50) NOT NULL, 
    CONSTRAINT item_collectionID_FK 
		FOREIGN KEY (collectionID) REFERENCES Collection(collectionID), 
	CONSTRAINT item_communityID_FK
		FOREIGN KEY (communityID) REFERENCES Community(communityID)
);

INSERT INTO Item 
	(collectionID, communityID, itemTitle, itemDescription, itemImage, itemMediaType)
VALUES 
	(1, 1, 'Memories of River Life', 'Oral account of river life', 'ImagePlaceholder.png', 'Audio'),
    (2, 2, 'Ceremonial gathering of 1999', 'Documentation of ceremonial practice', 'ImagePlaceholder.png', 'Photograph'),
    (3, 3, 'Sacred Site Mapping', 'Hand drawn sacred site maps', 'ImagePlaceholder.png', 'Map'),
    (3, 4, 'Rainforest Camp c.1955', 'Archival photographs of camp life', 'ImagePlaceholder.png', 'Photograph'),
	(3, 3, 'Sacred site gifts', 'Documentation of gifts exchanged at sacred site', 'ImagePlaceholder.png', 'Photograph');

-- Cultural metadata class
CREATE TABLE IF NOT EXISTS CulturalMetadata(
	metadataID INT AUTO_INCREMENT PRIMARY KEY, -- 
    itemID INT NOT NULL, -- add an index as this will be used all the time
	itemStatus ENUM('Approved', 'Restricted', 'Pending Approval') NOT NULL, -- unsure what the values should be.. and does this overlap with collection Status?
    itemApprovalDate TIMESTAMP NULL DEFAULT NULL, -- should there be an item created date? 
    itemApproverID INT NULL, -- this is a user id
	itemLanguageGroup VARCHAR(50) NOT NULL,
    itemSensitivityLabel ENUM('Low', 'Moderate', 'High') NULL DEFAULT NULL,
    itemCulturalWarningFlag BOOLEAN NOT NULL,
    itemCulturalWarningText VARCHAR(250) NULL,
    CONSTRAINT culturalMetadata_itemID_FK 
		FOREIGN KEY (itemID) REFERENCES Item(itemID),
	CONSTRAINT item_approverID_FK
		FOREIGN KEY (itemApproverID) REFERENCES Users(userID)
);
CREATE INDEX idx_culturalMetadata_itemID ON CulturalMetadata(itemID);

INSERT INTO CulturalMetadata
	(itemID, itemStatus, itemApproverID, itemLanguageGroup, itemSensitivityLabel, itemCulturalWarningFlag, itemCulturalWarningText)
VALUES
	(1, 'Approved', 4, 'Yuggera', 'Low', FALSE, NULL),
    (2, 'Restricted', 4, 'Waka Waka', 'High', TRUE, 'Contains ceremonial content restricted to initiated members'),
    (3, 'Pending Approval', NULL, 'Gugu Badhun', NULL, TRUE, 'May contain content of a sensitive nature'), 
    (4, 'Approved', 4, 'Kalkadoon', 'Low', FALSE, NULL),
    (5, 'Restricted', 4, 'Gugu Badhun', 'High', TRUE, 'Sacred site information - community access only' );


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

-- place holder: Approval discussions comments table

-- place holder: User access requests


