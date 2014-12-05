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

# Generate UUID if none has been specified
DELIMITER //
CREATE FUNCTION GetOrUseUUID (uuid BIGINT) 
    RETURNS BIGINT
BEGIN
    # Generate UUID if not created
    IF (uuid = 0) THEN
        RETURN UUID_SHORT();
    END IF;
    RETURN uuid;
END;
//
DELIMITER ;

# Ensure string is non-empty
DELIMITER //
CREATE PROCEDURE EnsureNonEmpty (string VARCHAR(20), message VARCHAR(255))
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
    uuid BIGINT NOT NULL UNIQUE PRIMARY KEY,
    email VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(20) NOT NULL,
    username VARCHAR(20) NOT NULL UNIQUE
);

# Dummy conversation table
CREATE TABLE Conversations (
    uuid BIGINT PRIMARY KEY
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
    FOREIGN KEY (conversation) REFERENCES Conversations(uuid) 
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE
);

######################################################
# Create the Categories table
#######################################################

DROP TABLE IF EXISTS Categories;

# Create the Categories table
CREATE TABLE Categories (
    uuid BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (uuid),
    UNIQUE INDEX uuidIdx (uuid ASC)
);
#Add foreign key for parentCategory
ALTER TABLE Categories 
ADD COLUMN parent BIGINT NOT NULL,
ADD INDEX parentIdx (parent ASC);
ALTER TABLE Categories 
ADD CONSTRAINT parent
 FOREIGN KEY (parent)
 REFERENCES Categories(uuid)
 ON DELETE CASCADE
 ON UPDATE CASCADE;
# Create the Topics table
CREATE TABLE Topics (
    category BIGINT NOT NULL,
    statementA TEXT NOT NULL,
    statementB TEXT NOT NULL,
    PRIMARY KEY (category)
);
#Add foreign key for category
ALTER TABLE Topics
 ADD INDEX category (category ASC);
ALTER TABLE Topics 
ADD CONSTRAINT category
 FOREIGN KEY (category)
 REFERENCES Categories(uuid)
 ON DELETE CASCADE
 ON UPDATE CASCADE;
# Create the SuggestionToChange table
CREATE TABLE SuggestionToChanges (
    uuid BIGINT NOT NULL PRIMARY KEY,
    categoryToChange BIGINT NOT NULL,
    newParent BIGINT NOT NULL,
    votesFavor INT NOT NULL,
    votesAgainst INT NOT NULL,
    votesTotal INT NOT NULL,
    CONSTRAINT itemToMove FOREIGN KEY (uuid)
        REFERENCES Categories (uuid)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT newCategory FOREIGN KEY (uuid)
        REFERENCES Categories (uuid)
        ON DELETE CASCADE ON UPDATE CASCADE
);
# Create the UserVotes table
CREATE TABLE UserVotes (
    user BIGINT NOT NULL,
    suggestionToChange BIGINT NOT NULL,
    voteDirection BOOL NOT NULL,
    PRIMARY KEY (user , suggestionToChange)
);
ALTER TABLE UserVotes
  ADD CONSTRAINT suggestionToChangeFk FOREIGN KEY (suggestionToChange)
  REFERENCES SuggestionToChanges(uuid)
  ON DELETE NO ACTION ON UPDATE NO ACTION, 
  ADD CONSTRAINT userFk FOREIGN KEY (user)
  REFERENCES Users(uuid)
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
    FOREIGN KEY (suggestionToChangeConversation) REFERENCES SuggestionToChanges(uuid)
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (postedBy) REFERENCES Users(uuid)
        MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE
);

######################################################
# Triggers to handle integrety constraints on updates and insertions
######################################################

# Ensure validity
DELIMITER //
CREATE PROCEDURE ValidateUser (email VARCHAR(20), password VARCHAR(20), username VARCHAR(20))
BEGIN
    # Reject empty passwords
    CALL EnsureNonEmpty(password, 'Password can not be empty.');
    
    # Reject empty usernames 
    CALL EnsureNonEmpty(username, 'Username can not be empty.');
    
    # The email address must be valid
    IF(email NOT REGEXP '^[[:alnum:]]+@[[:alpha:]]+[[.full-stop.]][[:alpha:]]{2,3}$') THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Email is not valid.';
    END IF;
END;
//
DELIMITER ;

# On Creation
DELIMITER //
CREATE TRIGGER CreateNewUser BEFORE INSERT ON Users
FOR EACH ROW
BEGIN 
    SET NEW.uuid = GetOrUseUUID(NEW.uuid);
    CALL ValidateUser(NEW.email, NEW.password, NEW.username);
END;
//
DELIMITER ;

# On update.
DELIMITER //
CREATE TRIGGER UpdateUser BEFORE UPDATE ON Users
FOR EACH ROW
BEGIN 
    CALL ValidateUser(NEW.email, NEW.password, NEW.username);
END;
//
DELIMITER ;
