######################################################
# Create the database
#######################################################

# Destroy any previously existing database instances.
DROP DATABASE IF EXISTS PairBasedChatRoom;

# Create a new database
CREATE DATABASE PairBasedChatRoom;
USE PairBasedChatRoom;

######################################################
# User defined helper functions for validation
######################################################

# Ensure string is non-empty
DELIMITER //
CREATE PROCEDURE EnsureNonEmpty (string VARCHAR(255), message VARCHAR(255))
BEGIN
    If (LENGTH(string) = 0) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = message;
    END IF; 
END;
//
DELIMITER ;

######################################################
# Create the tables
#######################################################

# Create the USERS table
CREATE TABLE Users (
    id BIGINT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL UNIQUE
);

######################################################
# Create the Categories table
#######################################################

DROP TABLE IF EXISTS Categories;

# Create the Categories table
CREATE TABLE Categories (
    id BIGINT NOT NULL AUTO_INCREMENT ,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE INDEX idIdx (id ASC)
);
#Add foreign key for parentCategory
ALTER TABLE Categories 
ADD COLUMN parent BIGINT,
ADD INDEX parentIdx (parent ASC);
ALTER TABLE Categories 
ADD CONSTRAINT parent
 FOREIGN KEY (parent)
 REFERENCES Categories(id)
 ON DELETE CASCADE
 ON UPDATE CASCADE;

# Create the Topics table
CREATE TABLE Topics (
    id BIGINT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    category BIGINT,
    statementA VARCHAR(255) NOT NULL,
    statementB VARCHAR(255) NOT NULL
);
#Add foreign key for category
ALTER TABLE Topics
 ADD INDEX category (category ASC);
ALTER TABLE Topics 
ADD CONSTRAINT category
 FOREIGN KEY (category)
 REFERENCES Categories(id)
 ON DELETE CASCADE
 ON UPDATE CASCADE;
# Create the SuggestionToChange table
CREATE TABLE SuggestionToChanges (
    id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    categoryToChange BIGINT NOT NULL,
    newParent BIGINT NOT NULL,
    votesFavor INT NOT NULL,
    votesAgainst INT NOT NULL,
    votesTotal INT NOT NULL,
    CONSTRAINT itemToMove FOREIGN KEY (id)
        REFERENCES Categories (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT newCategory FOREIGN KEY (id)
        REFERENCES Categories (id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
# Create the UserVotes table
CREATE TABLE UserVotes (
    user BIGINT NOT NULL AUTO_INCREMENT,
    suggestionToChange BIGINT NOT NULL,
    voteDirection BOOL NOT NULL,
    PRIMARY KEY (user , suggestionToChange)
);
ALTER TABLE UserVotes
  ADD CONSTRAINT suggestionToChangeFk FOREIGN KEY (suggestionToChange)
  REFERENCES SuggestionToChanges(id)
  ON DELETE NO ACTION ON UPDATE NO ACTION, 
  ADD CONSTRAINT userFk FOREIGN KEY (user)
  REFERENCES Users(id)
  ON DELETE NO ACTION  ON UPDATE NO ACTION,
  ADD INDEX suggestionToChangeFk (suggestionToChange ASC),
  ADD INDEX userFk (user ASC);

# Create Change Comments Table
CREATE TABLE ChangeComments(
    suggestionToChangeConversation BIGINT NOT NULL,
    creationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    postContent TEXT NOT NULL,
    postedBy BIGINT NOT NULL,
    flaggedAsAbusive BOOL NOT NULL DEFAULT 0,
    PRIMARY KEY (suggestionToChangeConversation, creationTime),
    FOREIGN KEY (suggestionToChangeConversation) REFERENCES SuggestionToChanges(id)
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (postedBy) REFERENCES Users(id)
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE
);

# Create Conversations Table
CREATE TABLE Conversations(
    id BIGINT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    topic BIGINT NOT NULL,
	positionAUser BIGINT NOT NULL,
	positionBUser BIGINT NOT NULL,
    FOREIGN KEY (topic) REFERENCES Topics(category),
    FOREIGN KEY (positionAUser) REFERENCES Users(id),
	FOREIGN KEY (positionBUser) REFERENCES Users(id)
);

# Create the ConversationsViewedByUserTracker Tabe
CREATE TABLE ConversationsViewedByUserTracker (
    user BIGINT NOT NULL,
    conversation BIGINT NOT NULL,
    timeConversationWasViewed TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user, conversation, timeConversationWasViewed),
    FOREIGN KEY (user) REFERENCES Users(id)
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (conversation) REFERENCES Conversations(id)
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE
);

# Create the posts table
CREATE TABLE Posts (
    conversation BIGINT NOT NULL,
    creationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    postContent TEXT NOT NULL,
    postedBySideA BOOL NOT NULL,
    seenByOtherUser BOOL NOT NULL DEFAULT 0,
    flaggedAsAbusive BOOL NOT NULL DEFAULT 0,
    PRIMARY KEY (conversation, creationTime, postedBySideA),
    FOREIGN KEY (conversation) REFERENCES Conversations(id) 
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE
);

######################################################
# Triggers to handle integrety constraints on updates and insertions
######################################################

# Ensure validity of Users
DELIMITER //
CREATE PROCEDURE ValidateUser (email VARCHAR(255), password VARCHAR(255), username VARCHAR(255))
BEGIN
    # Reject empty passwords
    CALL EnsureNonEmpty(password, 'Password can not be empty.');
    
    # Reject empty usernames 
    CALL EnsureNonEmpty(username, 'Username can not be empty.');
    
    # The email address must be valid
    IF(email NOT REGEXP '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$') THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Email is not valid.';
    END IF;
END;
//
DELIMITER ;

# Ensure validity of Topic
DELIMITER //
CREATE PROCEDURE ValidateTopic (name VARCHAR(255), statementA VARCHAR(255), statementB VARCHAR(255))
BEGIN
    CALL EnsureNonEmpty(name, 'Topic name can not be empty.');
    CALL EnsureNonEmpty(statementA, 'The statement for side A can not be empty.');
    CALL EnsureNonEmpty(statementB, 'The statement for side B can not be empty.');
END;
//
DELIMITER ;

# On Topic Creation
DELIMITER //
CREATE TRIGGER CreateNewTopic BEFORE INSERT ON Topics 
FOR EACH ROW
BEGIN 
    CALL ValidateTopic(NEW.name, NEW.statementA, NEW.statementB);
END;
//
DELIMITER ;

# On Topic update.
DELIMITER //
CREATE TRIGGER UpdateTopic BEFORE UPDATE ON Topics 
FOR EACH ROW
BEGIN 
    CALL ValidateTopic(NEW.name, NEW.statementA, NEW.statementB);
END;
//

# On User Creation
DELIMITER //
CREATE TRIGGER CreateNewUser BEFORE INSERT ON Users
FOR EACH ROW
BEGIN 
    CALL ValidateUser(NEW.email, NEW.password, NEW.username);
END;
//
DELIMITER ;

# On User update.
DELIMITER //
CREATE TRIGGER UpdateUser BEFORE UPDATE ON Users
FOR EACH ROW
BEGIN 
    CALL ValidateUser(NEW.email, NEW.password, NEW.username);
END;
//
DELIMITER ;

# On Category Creation
DELIMITER //
CREATE TRIGGER CreateCategory BEFORE INSERT ON Categories 
FOR EACH ROW
BEGIN 
    CALL EnsureNonEmpty(NEW.name, 'Category name can not be empty.');
END;
//
DELIMITER ;

# On Category Update 
DELIMITER //
CREATE TRIGGER UpdateCategory BEFORE UPDATE ON Categories 
FOR EACH ROW
BEGIN 
    CALL EnsureNonEmpty(NEW.name, 'Category name can not be empty.');
END;
//
DELIMITER ;

# On Creation
DELIMITER //
CREATE TRIGGER CreateNewConversation BEFORE INSERT ON Conversations
FOR EACH ROW
BEGIN 
    If (NEW.positionAUser=NEW.positionBUser) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'positions cannot equal';
    END IF; 
END;
//
DELIMITER ;

# On update.
DELIMITER //
CREATE TRIGGER UpdateConversation BEFORE UPDATE ON Conversations
FOR EACH ROW
BEGIN 
    If (NEW.positionAUser=NEW.positionBUser) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'positions cannot equal';
    END IF; 
END;
//
DELIMITER ;
