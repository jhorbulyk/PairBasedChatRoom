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

CREATE TABLE `pairbasedchatroom`.`Category` (
  `uuid` INT NOT NULL,
  `categoryName` TINYTEXT NOT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE INDEX `uuid_UNIQUE` (`uuid` ASC));

ALTER TABLE `pairbasedchatroom`.`Category` 
ADD COLUMN `parentCategory` INT NULL AFTER `categoryName`,
ADD INDEX `parentCategory_idx` (`parentCategory` ASC);
ALTER TABLE `pairbasedchatroom`.`Category` 
ADD CONSTRAINT `parentCategory`
  FOREIGN KEY (`parentCategory`)
  REFERENCES `pairbasedchatroom`.`Category` (`uuid`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
  
