######################################################
# Create the database
#######################################################

# Destroy any previously existing database instances.
DROP DATABASE IF EXISTS PairBasedChatRoom;

# Create a new database
CREATE DATABASE PairBasedChatRoom;
USE PairBasedChatRoom;

######################################################
# Create the tables and constraint based triggers
#######################################################

# Create the USERS table
CREATE TABLE User (
    uuid INT NOT NULL UNIQUE PRIMARY KEY,
    email CHAR(20) NOT NULL UNIQUE,
    password CHAR(20) NOT NULL,
    username CHAR(20) NOT NULL UNIQUE
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

CREATE TABLE Categories (
  uuid BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  PRIMARY KEY (uuid),
  UNIQUE INDEX uuidIdx(uuid ASC));

#Add foreign key for parentCategory
ALTER TABLE Categories
ADD COLUMN parent BIGINT NULL,
ADD INDEX parentIdx (parent ASC);
ALTER TABLE Categories
ADD CONSTRAINT parent
  FOREIGN KEY (parent)
  REFERENCES Categories(uuid)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

