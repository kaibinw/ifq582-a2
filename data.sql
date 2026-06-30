-- ========================================
-- IFQ582 data base creation process
-- A. Database definition
-- B. Table defintion
-- C. Data insertion
-- ========================================

-- ========================================
-- A. Database definition
-- ========================================
CREATE DATABASE IF NOT EXISTS IFQ582;
USE IFQ582;

-- ========================================
-- B. Table defintion
-- ========================================
-- Community class
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Community;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE IF NOT EXISTS Community (
	communityID INT AUTO_INCREMENT PRIMARY KEY, -- changed to int & auto increment 
    communityName VARCHAR(50) NOT NULL,
    communityRegion VARCHAR(50) NOT NULL -- not sure what this does? 
);


-- Collection class
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Collection;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE IF NOT EXISTS Collection (
	collectionID INT AUTO_INCREMENT PRIMARY KEY, -- changed to int
    collectionName VARCHAR(250) NOT NULL, 
    collectionShortName VARCHAR(50) NOT NULL, -- e.g. 'oral history' or 'ceremonial'
    -- collectionStatus ENUM('Option A', 'Option B') NOT NULL, -- in the data model but unsure what values should be
    collectionDateCreated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP -- confirm if time stamp is fine, added a default value
); 


-- Users class
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Users;
SET FOREIGN_KEY_CHECKS = 1;

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

-- Item class
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Item;
SET FOREIGN_KEY_CHECKS = 1;

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

-- Cultural metadata class
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS CulturalMetadata;
SET FOREIGN_KEY_CHECKS = 1;

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

-- UserCommunity bridging table
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS UsersCommunity;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE IF NOT EXISTS UsersCommunity(
	userID INT NOT NULL,
    communityID INT NOT NULL,
    PRIMARY KEY (userID, communityID),
    CONSTRAINT usersCommunity_userID_FK 
		FOREIGN KEY (userID) REFERENCES Users(userID),
	CONSTRAINT usersCommunity_communityID_FK
		FOREIGN KEY (communityID) REFERENCES Community(communityID)
);

-- ApprovalDiscussion class
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS ApprovalComment;
SET FOREIGN_KEY_CHECKS = 1;

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

-- ItemAccessRequest class
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS ItemAccessRequest;
SET FOREIGN_KEY_CHECKS = 1;

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

-- ItemAccessApproval
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS ItemAccessApproval;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE IF NOT EXISTS ItemAccessApproval(
    accessApprovalID INT AUTO_INCREMENT PRIMARY KEY,
    requestID INT NOT NULL,
    approverID INT NOT NULL,
    accessApprovalStatus ENUM('Approved', 'Not Approved')  NULL DEFAULT NULL, -- maybe move this to a boolean with default of No
    accessApprovalDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT itemAccessApproval_requestID_FK
        FOREIGN KEY (requestID) REFERENCES ItemAccessRequest(requestID),
    CONSTRAINT itemAccessApproval_approverID_FKß
        FOREIGN KEY (approverID) REFERENCES Users(userID)
);


-- ========================================
-- B. Table defintion
-- ========================================
-- Community table records
INSERT INTO Community
	(communityName, communityRegion)
VALUES
	('Yuggera','South East Queensland'),
    ('Waka Waka','Central Queensland'),
    ('Gugu Badhun','North Queensland'),
    ('Kalkadoon','Northwest Queensland'),
    ('Gubbi Gubbi', 'South East Queensland'),
    ('Butchulla', 'Fraser Coast Queensland'),
    ('Jirrbal', 'North Queensland'),
    ('Wulgurukaba', 'North Queensland'),
    ('Yidinji', 'North Queensland'),
    ('Iningai', 'Central Queensland'),
    ('Bidjara', 'Southwest Queensland'),
    ('Kullilli', 'Southwest Queensland'),
    ('Wakaman', 'North Queensland'),
    ('Barunggam', 'South East Queensland');

-- Collections table records
INSERT INTO Collection
	(collectionName, collectionShortName, collectionDateCreated)
VALUES
	('Oral Histories of South East Queensland', 'Oral History',  '2025-05-25'),
    ('Ceremonial and Sacred Records',           'Ceremonial',    '2023-04-12'),
    ('Archival Photographic Collection',        'Photography',   '2024-05-05'),
    ('Traditional Language Documentation',      'Language',      '2022-08-10'),
    ('Land and Country Records',                'Land Records',  '2021-11-30'),
    ('Genealogy and Family Histories',          'Genealogy',     '2020-03-17'),
    ('Sacred Site and Landscape Records',       'Sacred Sites',  '2019-07-22'),
    ('Artefact and Material Culture',           'Artefacts',     '2018-02-14'),
    ('Bush Medicine and Plant Knowledge',       'Bush Medicine', '2017-09-01'),
    ('Song, Dance and Performance',             'Performing',    '2016-05-11'),
    ('Elder Knowledge Archives',                'Elder Archive', '2015-12-03'),
    ('Dreaming and Narrative Records',          'Dreaming',      '2014-06-29');


-- Users table records
INSERT INTO Users
	(userHonourific, userLastName, userFirstName, userEmail, userRole, userPermissionLevel, userPassword)
VALUES
	(NULL,    'Matthews', 'Sarah',    's.matthews@ngurra.edu.au', 'Curator', 2, 'SM_password'),
    (NULL,    'Friend',   'Paul',     'p.friend@ngurra.edu.au',   'Curator', 2, 'PF_password'),
    (NULL,    'Bluth',    'Job',      'j.bluth@ngurra.edu.au',    'Public',  1, 'JB_password'),
    ('Aunty', 'Bancroft', 'Doris',    'd.bancroft@ngurra.edu.au', 'Elder',   3, 'DB_password'),
    (NULL,    'Johns',    'James',    'j.johns@ngurra.edu.au',    'Admin',   4, 'JJ_password'),
    ('Uncle', 'Watson',   'Charlie',  'c.watson@ngurra.edu.au',   'Elder',   3, 'CW_password'),
    (NULL,    'Rivera',   'Maria',    'm.rivera@ngurra.edu.au',   'Curator', 2, 'MR_password'),
    (NULL,    'Thompson', 'David',    'd.thompson@ngurra.edu.au', 'Public',  1, 'DT_password'),
    ('Aunty', 'Fisher',   'Margaret', 'm.fisher@ngurra.edu.au',   'Elder',   3, 'MF_password'),
    (NULL,    'Chen',     'Leo',      'l.chen@ngurra.edu.au',     'Public',  1, 'LC_password'),
    ('Uncle', 'Murray',   'Robert',   'r.murray@ngurra.edu.au',   'Elder',   3, 'RM_password'),
    (NULL,    'Nguyen',   'Tran',     't.nguyen@ngurra.edu.au',   'Curator', 2, 'TN_password'),
    (NULL,    'Harris',   'Grace',    'g.harris@ngurra.edu.au',   'Public',  1, 'GH_password'),
    ('Aunty', 'Peters',   'Joyce',    'j.peters@ngurra.edu.au',   'Elder',   3, 'JP_password'),
    (NULL,    'Lawson',   'Craig',    'c.lawson@ngurra.edu.au',   'Public',  1, 'CL_password'),
    (NULL,    'Webb',     'Sandra',   's.webb@ngurra.edu.au',     'Curator', 2, 'SW_password'),
    (NULL,    'King',     'Dylan',    'd.king@ngurra.edu.au',     'Public',  1, 'DK_password'),
    ('Uncle', 'Bowen',    'Neville',  'n.bowen@ngurra.edu.au',   'Elder',   3, 'NB_password'),
    (NULL,    'Cross',    'Leanne',   'l.cross@ngurra.edu.au',    'Public',  1, 'LC2_password'),
    (NULL,    'Burke',    'Patrick',  'p.burke@ngurra.edu.au',    'Public',  1, 'PB_password');

-- overwrite passwords with hashed passwords
UPDATE Users SET userPassword = '$2b$12$e45sHB1AYqAbY1cvd/bS2eCm51s6AbApVf3NiI.RrNTDNFjoCxp0C' WHERE userID = '1';
UPDATE Users SET userPassword = '$2b$12$sgIsMcbso7fH9v8FL13N/unqTplqpqaVOcleAyb5Y0MrIy68FL4K2' WHERE userID = '2';
UPDATE Users SET userPassword = '$2b$12$BkSockNWWlGfR5SqiR6RvuGH6gTcS0qMqHMI2JX609cjiVWGpYKI.' WHERE userID = '3';
UPDATE Users SET userPassword = '$2b$12$TOVlWpyOvPqrEE3rNw8Ucerri6XrGCDWlxf9d/HByHz1bvfNXEo7q' WHERE userID = '4';
UPDATE Users SET userPassword = '$2b$12$mOW3o1J3AWS3fTgX9foQre8Lf5M0DQSJRGN73Ozyh9EherIu89Mx.' WHERE userID = '5';
UPDATE Users SET userPassword = '$2b$12$Wmm.40kr2Uip3WauoZLIxeb5HS8/UeA/CBhnnGlRmrs2g98QEr/lS' WHERE userID = '6';
UPDATE Users SET userPassword = '$2b$12$./.xW8UhnlsF0ACqiLupS.gYAm58efFSSwSxMKgyOjNMbx0WW0G7q' WHERE userID = '7';
UPDATE Users SET userPassword = '$2b$12$qE0aTlO2n10YUMQ7KxN4fO7aVA.c0qKtH0hgerIPg8saOLaCS6kjG' WHERE userID = '8';
UPDATE Users SET userPassword = '$2b$12$CoKUmZ89tUpFmUNnE5Ao2eGmigz5Q5gNJ4RZAEsSRcgNvr2.0tfYe' WHERE userID = '9';
UPDATE Users SET userPassword = '$2b$12$jjqzkFMLE/e87k3OxgO/6ecssHUcEL7GLH/TMbr7FtL8vrD566zKS' WHERE userID = '10';
UPDATE Users SET userPassword = '$2b$12$R8ezRyMCEaM0ljhKYzDpLu21zU22yIwO7CUaoe8kv1J8sTSyBA2nS' WHERE userID = '11';
UPDATE Users SET userPassword = '$2b$12$5z4S2TFG5nj16JkJwJ6Qc.LGW3KQaBZOMR.tvIADVVwFGrKQIPR86' WHERE userID = '12';
UPDATE Users SET userPassword = '$2b$12$zeSPdTOL1t0pDEUFjaVR8.cQROBKmHNqsUTtdG1idxcezDzZgdI/u' WHERE userID = '13';
UPDATE Users SET userPassword = '$2b$12$nrSGZd1.thhs99MrBkegyuvryEn/WI0qTIYZ27ZaxGzlhW5L6r9SS' WHERE userID = '14';
UPDATE Users SET userPassword = '$2b$12$NzLkhBFzvJeAaZfE6P8lAukaHre32K6L024PmgHkf6gFpIjG1cZyC' WHERE userID = '15';
UPDATE Users SET userPassword = '$2b$12$D9nDDsDR9jUYPX96Ws25tuAQuFGLq4wMmfyyqb/jOHYEv.MKIUq0C' WHERE userID = '16';
UPDATE Users SET userPassword = '$2b$12$8fg/anW3Zamy67cToaB3aekqZAo2BfX7d4iWjIuShW3HLSSgMU516' WHERE userID = '17';
UPDATE Users SET userPassword = '$2b$12$PsMvghkumqLkPS/vDU5XMepcA1qYQJ03VyVu2YZ8R0HE8SdhW85OG' WHERE userID = '18';
UPDATE Users SET userPassword = '$2b$12$raWq2jgR3GpD1j0YS7pcouPhf1pGqXf5aVDGqCpFqe.C1QbukiOyK' WHERE userID = '19';
UPDATE Users SET userPassword = '$2b$12$EWvrfwHsjjiubk6b1VcFm.Ybj5kpkcrsgFC2BhbbcIMk54S0fHuny' WHERE userID = '20';

-- Item table records
INSERT INTO Item
	(collectionID, communityID, itemDate, itemTitle, itemDescription, itemImage, itemMediaType)
VALUES
	(1,  1,  '1990-05-01', 'Memories of River Life',            'Oral account of river life',                                    'ImagePlaceholder.png', 'Audio Recording'),
    (2,  2,  '1999-05-01', 'Ceremonial Gathering of 1999',      'Documentation of ceremonial practice',                          'ImagePlaceholder.png', 'Photograph'),
    (3,  3,  '1994-05-01', 'Sacred Site Mapping',               'Hand drawn sacred site maps',                                   'ImagePlaceholder.png', 'Map'),
    (3,  4,  '1955-05-01', 'Rainforest Camp c.1955',            'Archival photographs of camp life',                             'ImagePlaceholder.png', 'Photograph'),
    (3,  3,  '1999-05-01', 'Sacred Site Gifts',                 'Documentation of gifts exchanged at sacred site',               'ImagePlaceholder.png', 'Photograph'),
    (4,  5,  '2001-09-14', 'Gubbi Gubbi Word List',             'Recorded vocabulary of Gubbi Gubbi language',                   'ImagePlaceholder.png', 'Audio Recording'),
    (1,  2,  '1987-03-22', 'Stories of the Wanderers',          'Oral history of seasonal movement across Waka Waka country',    'ImagePlaceholder.png', 'Audio Recording'),
    (5,  6,  '1972-11-05', 'Butchulla Country Boundary Map',    'Hand-drawn map of traditional Butchulla country boundaries',    'ImagePlaceholder.png', 'Map'),
    (6,  1,  '2010-06-18', 'Yuggera Family Tree Records',       'Genealogical records of prominent Yuggera family lines',        'ImagePlaceholder.png', 'Photograph'),
    (2,  7,  '2003-08-30', 'Jirrbal Ceremonial Dress',          'Photographs of traditional Jirrbal ceremonial dress',           'ImagePlaceholder.png', 'Photograph'),
    (5,  4,  '1965-01-20', 'Kalkadoon Country Survey',          'Early survey maps of Kalkadoon traditional lands',              'ImagePlaceholder.png', 'Map'),
    (3,  5,  '1948-07-04', 'Camp Life c.1948',                  'Archival photographs of Gubbi Gubbi community camp life',       'ImagePlaceholder.png', 'Photograph'),
    (7,  8,  '1980-03-10', 'Wulgurukaba Sacred Sites',          'Documented sacred site locations in Wulgurukaba country',       'ImagePlaceholder.png', 'Map'),
    (8,  9,  '1963-07-19', 'Yidinji Stone Tools Collection',    'Photographs of stone tool artefacts from Yidinji country',      'ImagePlaceholder.png', 'Photograph'),
    (9,  10, '2005-11-28', 'Iningai Bush Medicine Knowledge',   'Recordings of traditional plant medicine uses in Iningai',      'ImagePlaceholder.png', 'Audio Recording'),
    (10, 11, '2008-04-17', 'Bidjara Corroboree Recording',      'Audio recording of traditional Bidjara corroboree songs',       'ImagePlaceholder.png', 'Audio Recording'),
    (11, 4,  '2012-09-05', 'Kalkadoon Elder Testimonies',       'Recorded testimonies of Kalkadoon elders on country history',   'ImagePlaceholder.png', 'Audio Recording'),
    (12, 3,  '1958-06-12', 'Gugu Badhun Dreaming Stories',     'Narrated accounts of Gugu Badhun creation stories',              'ImagePlaceholder.png', 'Audio Recording'),
    (4,  9,  '1996-04-03', 'Yidinji Language Recordings',      'Field recordings of Yidinji spoken language and songs',          'ImagePlaceholder.png', 'Audio Recording'),
    (7,  12, '1978-08-25', 'Kullilli Sacred Waterhole Map',    'Hand-drawn map of sacred waterhole sites in Kullilli country',   'ImagePlaceholder.png', 'Map'),
    (10, 13, '2004-02-14', 'Wakaman Dance Ceremony',           'Photographs of traditional Wakaman dance ceremony',              'ImagePlaceholder.png', 'Photograph'),
    (9,  14, '2011-10-07', 'Barunggam Plant Medicine Lore',    'Oral accounts of traditional Barunggam plant medicine uses',     'ImagePlaceholder.png', 'Audio Recording'),
    (6,  8,  '2015-03-19', 'Wulgurukaba Genealogy Records',    'Compiled family history records of Wulgurukaba people',         'ImagePlaceholder.png', 'Photograph'),
    (8,  11, '1969-12-01', 'Bidjara Ceremonial Objects',       'Photographs of traditional Bidjara ceremonial artefacts',       'ImagePlaceholder.png', 'Photograph'),
    (5,  13, '1974-05-30', 'Wakaman Territory Survey',         'Survey map of traditional Wakaman territorial boundaries',      'ImagePlaceholder.png', 'Map'),
    (11, 6,  '2009-07-22', 'Butchulla Elder Oral Histories',   'Extended oral history recordings with Butchulla elders',        'ImagePlaceholder.png', 'Audio Recording'),
    (2,  10, '2000-09-15', 'Iningai Initiation Records',       'Documented accounts of Iningai initiation practices',           'ImagePlaceholder.png', 'Photograph'),
    (3,  14, '1952-11-10', 'Barunggam Camp Photographs',       'Archival photographs of Barunggam community life c.1952',       'ImagePlaceholder.png', 'Photograph'),
    (7,  9,  '1983-01-27', 'Yidinji Sacred Ground Mapping',   'Detailed maps of Yidinji sacred ceremonial grounds',             'ImagePlaceholder.png', 'Map'),
    (1,  12, '1991-04-08', 'Kullilli Stories of Country',      'Oral history recordings of Kullilli connection to country',     'ImagePlaceholder.png', 'Audio Recording'),
    (4,  14, '2007-06-03', 'Barunggam Language Lessons',       'Structured language lesson recordings for Barunggam revival',   'ImagePlaceholder.png', 'Audio Recording'),
    (10, 5,  '2013-08-11', 'Gubbi Gubbi Songlines',            'Recordings of traditional Gubbi Gubbi songline performances',   'ImagePlaceholder.png', 'Audio Recording'),
    (6,  7,  '2018-02-28', 'Jirrbal Family Histories',         'Genealogical records compiled from Jirrbal elder testimonies',  'ImagePlaceholder.png', 'Photograph'),
    (12, 11, '1977-09-16', 'Bidjara Dreaming Narratives',      'Narrated Bidjara dreaming stories recorded in the field',       'ImagePlaceholder.png', 'Audio Recording'),
    (8,  2,  '1966-03-04', 'Waka Waka Artefact Collection',   'Photographs of traditional Waka Waka material culture items',   'ImagePlaceholder.png', 'Photograph'),
    (5,  10, '1971-07-20', 'Iningai Land Boundary Records',    'Historical land boundary maps for Iningai traditional country', 'ImagePlaceholder.png', 'Map');


-- Elders: 4=Aunty Doris, 6=Uncle Charlie, 9=Aunty Margaret, 11=Uncle Robert, 14=Aunty Joyce, 18=Uncle Neville
INSERT INTO CulturalMetadata
	(itemID, itemStatus, itemApprovalDate, itemApproverID, itemLanguageGroup, itemCulturalNote, itemSensitivityLabel, itemCulturalWarningFlag, itemCulturalWarningText)
VALUES
	(1,  'Approve for Public Access', '2026-05-15', 4,    'Yuggera',      'Oral account approved for public educational use',                         'Low',      FALSE, NULL),
    (2,  'Restrict - Community Only', '2026-05-15', 4,    'Waka Waka',    'Ceremonial practice documentation restricted to community only',           'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (3,  'Pending Approval',          NULL,         NULL, 'Gugu Badhun',  'Sacred site maps require elder council review before any access decision', NULL,       TRUE,  'May contain sensitive content'),
    (4,  'Approve for Public Access', '2026-05-15', 4,    'Kalkadoon',    'Archival photographs approved with elder consent',                         'Low',      FALSE, NULL),
    (5,  'Restrict - Community Only', '2026-05-15', 4,    'Gugu Badhun',  'Gift documentation contains restricted ceremonial context',                'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (6,  'Approve for Public Access', '2026-01-10', 6,    'Gubbi Gubbi',  'Language recordings approved for educational access',                     'Low',      FALSE, NULL),
    (7,  'Pending Approval',          NULL,         NULL, 'Waka Waka',    'Oral account requires community review before release',                    NULL,       FALSE, 'No warning required'),
    (8,  'Restrict - Community Only', '2026-02-20', 9,    'Butchulla',    'Boundary records contain sacred site references',                         'Moderate', TRUE,  'May contain sensitive content'),
    (9,  'Approve for Public Access', '2026-03-05', 4,    'Yuggera',      'Genealogical records approved with elder consent',                        'Low',      FALSE, NULL),
    (10, 'Restrict - Community Only', '2026-04-11', 6,    'Jirrbal',      'Ceremonial dress documentation restricted to community',                  'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (11, 'Pending Approval',          NULL,         NULL, 'Kalkadoon',    'Historical survey pending cultural sensitivity assessment',                NULL,       FALSE, 'No warning required'),
    (12, 'Approve for Public Access', '2026-05-01', 9,    'Gubbi Gubbi',  'Archival photographs cleared for public access',                          'Low',      FALSE, NULL),
    (13, 'Restrict - Community Only', '2026-03-14', 11,   'Wulgurukaba',  'Sacred site map must remain restricted to community members',             'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (14, 'Approve for Public Access', '2026-04-02', 14,   'Yidinji',      'Artefact photographs approved for public research access',                'Low',      FALSE, NULL),
    (15, 'Pending Approval',          NULL,         NULL, 'Iningai',      'Bush medicine knowledge under review for cultural sensitivity',            NULL,       TRUE,  'May contain sensitive content'),
    (16, 'Restrict - Community Only', '2026-05-10', 18,   'Bidjara',      'Corroboree songs restricted to initiated community members only',         'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (17, 'Approve for Public Access', '2026-05-12', 11,   'Kalkadoon',    'Elder testimonies approved for archival and educational use',             'Low',      FALSE, NULL),
    (18, 'Restrict - Community Only', '2026-01-15', 6,    'Gugu Badhun', 'Dreaming narratives contain restricted ceremonial knowledge',             'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (19, 'Approve for Public Access', '2026-02-10', 11,   'Yidinji',     'Language recordings cleared for educational and research use',            'Low',      FALSE, NULL),
    (20, 'Restrict - Community Only', '2026-02-25', 14,   'Kullilli',    'Sacred waterhole locations must remain restricted to community',           'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (21, 'Approve for Public Access', '2026-03-08', 18,   'Wakaman',     'Ceremony photographs approved for public cultural education',              'Low',      FALSE, NULL),
    (22, 'Pending Approval',          NULL,         NULL, 'Barunggam',   'Plant medicine records under elder review for sensitivity assessment',     NULL,       FALSE, 'No warning required'),
    (23, 'Approve for Public Access', '2026-03-20', 11,   'Wulgurukaba', 'Genealogy records approved with full elder council consent',               'Low',      FALSE, NULL),
    (24, 'Restrict - Community Only', '2026-04-05', 18,   'Bidjara',     'Ceremonial artefact photographs restricted to initiated members only',     'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (25, 'Approve for Public Access', '2026-04-14', 14,   'Wakaman',     'Territory survey approved for public and academic research access',        'Low',      FALSE, NULL),
    (26, 'Approve for Public Access', '2026-04-22', 9,    'Butchulla',   'Elder oral histories approved for archival and educational access',        'Low',      FALSE, NULL),
    (27, 'Restrict - Community Only', '2026-05-03', 6,    'Iningai',     'Initiation records restricted — contains sacred ceremonial content',       'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (28, 'Approve for Public Access', '2026-05-09', 4,    'Barunggam',   'Archival photographs approved for public display and research',            'Low',      FALSE, NULL),
    (29, 'Pending Approval',          NULL,         NULL, 'Yidinji',     'Sacred ground maps require elder council decision before any release',     NULL,       TRUE,  'May contain sensitive content'),
    (30, 'Approve for Public Access', '2026-05-14', 9,    'Kullilli',    'Oral history recordings approved for public educational use',              'Low',      FALSE, NULL),
    (31, 'Pending Approval',          NULL,         NULL, 'Barunggam',   'Language lesson recordings awaiting community approval',                   NULL,       FALSE, 'No warning required'),
    (32, 'Approve for Public Access', '2026-05-16', 6,    'Gubbi Gubbi', 'Songline recordings approved for cultural education programs',             'Low',      FALSE, NULL),
    (33, 'Approve for Public Access', '2026-05-17', 4,    'Jirrbal',     'Genealogy records approved with full elder consent',                      'Low',      FALSE, NULL),
    (34, 'Restrict - Community Only', '2026-05-18', 18,   'Bidjara',     'Dreaming narratives contain secret knowledge restricted to elders',        'High',     TRUE,  'Contains ceremonial information restricted to initiated members'),
    (35, 'Approve for Public Access', '2026-05-19', 14,   'Waka Waka',   'Artefact photographs approved for research and public access',             'Low',      FALSE, NULL),
    (36, 'Pending Approval',          NULL,         NULL, 'Iningai',     'Land boundary maps under review for sacred site content',                  NULL,       TRUE,  'May contain sensitive content');


-- UsersCommunity table records
INSERT INTO UsersCommunity
	(userID, communityID)
VALUES
	(4,  3),   -- Aunty Doris     -> Gugu Badhun
    (4,  1),   -- Aunty Doris     -> Yuggera
    (6,  5),   -- Uncle Charlie   -> Gubbi Gubbi
    (6,  3),   -- Uncle Charlie   -> Gugu Badhun
    (9,  6),   -- Aunty Margaret  -> Butchulla
    (9,  7),   -- Aunty Margaret  -> Jirrbal
    (11, 8),   -- Uncle Robert    -> Wulgurukaba
    (11, 9),   -- Uncle Robert    -> Yidinji
    (14, 2),   -- Aunty Joyce     -> Waka Waka
    (14, 10),  -- Aunty Joyce     -> Iningai
    (18, 11),  -- Uncle Neville   -> Bidjara
    (18, 4),   -- Uncle Neville   -> Kalkadoon
    (3,  1),   -- Job Bluth (Public) -> Yuggera
    (8,  6),   -- David Thompson (Public) -> Butchulla
    (10, 7),   -- Leo Chen (Public) -> Jirrbal
    (20, 12);  -- Patrick Burke (Public) -> Kullilli


-- ItemAccessRequest table records
INSERT INTO ItemAccessRequest
    (userID, itemID, requestReasonText, requestDate, requestStatus)
VALUES
    (3,  2,  'I am a researcher studying ceremonial practices and would like access to this record.',               '2026-05-15 10:00:00', 'Closed'),
    (3,  5,  'Requesting access for academic research into documentation practices.',                               '2026-05-16 11:30:00', 'Closed'),
    (8,  8,  'I am a member of the Butchulla community and would like to view the boundary map records.',          '2026-05-18 09:15:00', 'Open'),
    (10, 10, 'Requesting access to view ceremonial dress documentation for cultural education purposes.',           '2026-05-20 14:00:00', 'Open'),
    (3,  11, 'Interested in accessing historical survey maps for genealogical research.',                           '2026-05-22 08:30:00', 'Open'),
    (8,  3,  'Community member requesting access to sacred site mapping records.',                                  '2026-05-24 12:00:00', 'Closed'),
    (10, 7,  'Student researcher requesting access to oral history recordings for study purposes.',                 '2026-05-25 15:45:00', 'Open'),
    (13, 18, 'Requesting access to Dreaming stories for cultural heritage studies.',                                '2026-05-26 09:00:00', 'Open'),
    (15, 20, 'I would like to view the Kullilli sacred waterhole maps for my land management research.',           '2026-05-26 10:30:00', 'Closed'),
    (17, 24, 'Requesting access to the Bidjara artefact photographs for a university research project.',           '2026-05-26 11:00:00', 'Closed'),
    (3,  27, 'Academic researcher requesting access to Iningai initiation records for anthropological study.',     '2026-05-26 13:00:00', 'Open'),
    (8,  29, 'Community member requesting access to Yidinji sacred ground mapping records.',                       '2026-05-27 08:00:00', 'Open'),
    (10, 34, 'Requesting access to Bidjara dreaming narratives for cultural education research.',                   '2026-05-27 09:30:00', 'Closed'),
    (13, 16, 'Requesting access to the Bidjara corroboree recordings for music studies.',                          '2026-05-27 10:00:00', 'Open'),
    (15, 13, 'Requesting access to Wulgurukaba sacred site maps for land and heritage management research.',       '2026-05-27 11:30:00', 'Closed'),
    (17, 36, 'Land management researcher requesting access to Iningai boundary records.',                           '2026-05-27 12:00:00', 'Open'),
    (19, 2,  'Cultural heritage student requesting access to Waka Waka ceremonial records for thesis research.',   '2026-05-27 13:00:00', 'Open'),
    (20, 5,  'Requesting access to the sacred site gifts documentation for comparative cultural study.',           '2026-05-27 14:00:00', 'Closed'),
    (3,  10, 'Researcher requesting access to Jirrbal ceremonial dress photographs for publication.',              '2026-05-28 08:00:00', 'Closed'),
    (17, 8,  'Requesting access to Butchulla boundary maps for Aboriginal land claim support documentation.',      '2026-05-28 09:00:00', 'Open'),
    (19, 20, 'Cultural studies student requesting access to Kullilli sacred waterhole map records.',               '2026-05-28 10:00:00', 'Open');


-- ItemAccessApproval table records
INSERT INTO ItemAccessApproval
    (requestID, approverID, accessApprovalStatus, accessApprovalDate)
VALUES
    (1,  4,  'Not Approved', '2026-05-16 09:00:00'),   -- Aunty Doris denied researcher access to ceremonial record
    (2,  9,  'Approved',     '2026-05-17 10:30:00'),   -- Aunty Margaret approved academic research access
    (6,  9,  'Approved',     '2026-05-25 13:00:00'),   -- Aunty Margaret approved community member for sacred site maps
    (9,  14, 'Not Approved', '2026-05-27 09:00:00'),   -- Aunty Joyce denied access to Kullilli sacred waterhole maps
    (10, 18, 'Not Approved', '2026-05-27 10:00:00'),   -- Uncle Neville denied access to Bidjara artefact photographs
    (13, 11, 'Not Approved', '2026-05-28 08:30:00'),   -- Uncle Robert denied access to Bidjara dreaming narratives
    (15, 11, 'Not Approved', '2026-05-28 10:00:00'),   -- Uncle Robert denied access to Wulgurukaba sacred site maps
    (18, 4,  'Not Approved', '2026-05-28 11:00:00'),   -- Aunty Doris denied access to sacred site gifts documentation
    (19, 6,  'Not Approved', '2026-05-28 12:00:00');   -- Uncle Charlie denied researcher access to ceremonial dress photos
    