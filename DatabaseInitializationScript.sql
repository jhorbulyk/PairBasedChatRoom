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

# Ensure exactly one is NULL.
DELIMITER //
CREATE PROCEDURE EnsureOneIsNull (id1 BIGINT, id2 BIGINT, message VARCHAR(255))
BEGIN
    If (id1 > 0 XOR id2 > 0) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = message;
    END IF; 
END;
//
DELIMITER ;

# Ensure two are not equal (including NULLS)
DELIMITER //
CREATE FUNCTION Same (id1 BIGINT, id2 BIGINT)
RETURNS BOOL
BEGIN
    If (id1 > 0 AND id2 > 0) THEN
        if(id1 = id2) THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    ELSEIF (id1 > 0 OR id2 > 0) THEN
        RETURN 0;
    ELSE
        RETURN 1;
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
CREATE TABLE SuggestionsToChange (
    id BIGINT NOT NULL UNIQUE AUTO_INCREMENT,
    categoryToMove BIGINT,
    topicToMove BIGINT,
    newCategory BIGINT,
    CONSTRAINT ctm FOREIGN KEY (categoryToMove)
        REFERENCES Categories (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT tmp FOREIGN KEY (topicToMove) 
        REFERENCES Topics(id)
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
  REFERENCES SuggestionsToChange(id)
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
    FOREIGN KEY (suggestionToChangeConversation) REFERENCES SuggestionsToChange(id)
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (postedBy) REFERENCES Users(id)
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE
);

# Create Conversations Table
CREATE TABLE Conversations(
    id BIGINT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    topic BIGINT NOT NULL,
	positionAUser BIGINT,
	positionBUser BIGINT,
    FOREIGN KEY (topic) REFERENCES Topics(id),
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
	id BIGINT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    conversation BIGINT NOT NULL,
    creationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    postContent TEXT NOT NULL,
    postedBySideA BOOL NOT NULL,
    seenByOtherUser BOOL NOT NULL DEFAULT 0,
    flaggedAsAbusive BOOL NOT NULL DEFAULT 0,
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

# Ensure validity of ChangeCategorySuggestion 
DELIMITER //
CREATE PROCEDURE ValidateCategoryChangeSuggestion (categoryToMove BIGINT, topicToMove BIGINT, newCategory BIGINT)
BEGIN
    CALL EnsureOneIsNull(categoryToMove, topicToMove, 'Exactly one of categoryToMove and topicToMove must be NULL.');
    If(categoryToMove = newCategory) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = "Can not move category to itself.";
    END IF;

    IF (categoryToMove > 0) THEN
        SELECT parent INTO @oldParent FROM Categories WHERE id = categoryToMove;    
        IF(Same(oldParent, categoryToMove)) THEN
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = "Old parent and new parent are the same.";
        END IF;
    END IF;


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

# On create SuggestionToChange
DELIMITER //
CREATE TRIGGER CreateSuggestionToChange BEFORE INSERT ON SuggestionsToChange 
FOR EACH ROW
BEGIN 
    CALL ValidateCategoryChangeSuggestion(NEW.categoryToMove, NEW.topicToMove, NEW.newCategory);
END;
//
DELIMITER ;

# On update SuggestionToChange
DELIMITER //
CREATE TRIGGER UpdateSuggestionToChange BEFORE UPDATE ON SuggestionsToChange 
FOR EACH ROW
BEGIN 
    CALL ValidateCategoryChangeSuggestion(NEW.categoryToMove, NEW.topicToMove, NEW.newCategory);
END;
//
DELIMITER ;
