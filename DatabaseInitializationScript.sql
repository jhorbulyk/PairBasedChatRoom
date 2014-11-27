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

#Create Categories Table
CREATE TABLE `pairbasedchatroom`.`Categories` (
  `uuid` INT NOT NULL,
  `categoryName` TINYTEXT NOT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE INDEX `uuid_UNIQUE` (`uuid` ASC));

#Add foreign key for parentCategory
ALTER TABLE `pairbasedchatroom`.`Categories` 
ADD COLUMN `parentCategory` INT NULL AFTER `categoryName`,
ADD INDEX `parentCategory_idx` (`parentCategory` ASC);
ALTER TABLE `pairbasedchatroom`.`Categories` 
ADD CONSTRAINT `parentCategory`
  FOREIGN KEY (`parentCategory`)
  REFERENCES `pairbasedchatroom`.`Categories` (`uuid`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
  
