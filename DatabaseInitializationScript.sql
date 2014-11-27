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

