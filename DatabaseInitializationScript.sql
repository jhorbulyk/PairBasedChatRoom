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

#Create Topics Table
CREATE TABLE `pairbasedchatroom`.`Topics` (
  `uuid` INT NOT NULL,
  `topicTitle` TINYTEXT NOT NULL,
  `positionAStatement` TINYTEXT NOT NULL,
  `positionBStatement` TINYTEXT NOT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE INDEX `uuid_UNIQUE` (`uuid` ASC));
  
#Add Foreign Key for category
ALTER TABLE `pairbasedchatroom`.`Topics` 
ADD COLUMN `categories.uuid` INT NULL AFTER `positionBStatement`,
ADD INDEX `categories.uuid_idx` (`categories.uuid` ASC);
ALTER TABLE `pairbasedchatroom`.`Topics` 
ADD CONSTRAINT `categories.uuid`
 FOREIGN KEY (`categories.uuid`)
 REFERENCES `pairbasedchatroom`.`Categories` (`uuid`)
 ON DELETE NO ACTION
 ON UPDATE NO ACTION;
