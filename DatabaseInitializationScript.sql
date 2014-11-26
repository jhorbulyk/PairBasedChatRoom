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

#Create Conversations Table
CREATE TABLE `pairbasedchatroom`.`Conversations` (
  `uuid` INT NOT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE INDEX `uuid_UNIQUE` (`uuid` ASC));
  
#Add foreign key
ALTER TABLE `pairbasedchatroom`.`Conversations` 
ADD COLUMN `topics.uuid` INT NOT NULL AFTER `uuid`,
ADD COLUMN `positionAUser.uuid` INT NOT NULL AFTER `topics.uuid`,
ADD COLUMN `positionBUser.uuid` INT NOT NULL AFTER `positionAUser.uuid`,
ADD INDEX `topics.uuid_idx` (`topics.uuid` ASC),
ADD INDEX `positionAUser.uuid_idx` (`positionAUser.uuid` ASC),
ADD INDEX `positionBUser.uuid_idx` (`positionBUser.uuid` ASC);
ALTER TABLE `pairbasedchatroom`.`Conversations` 
ADD CONSTRAINT `topics.uuid`
  FOREIGN KEY (`topics.uuid`)
  REFERENCES `pairbasedchatroom`.`Topics` (`uuid`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION,
ADD CONSTRAINT `positionAUser.uuid`
  FOREIGN KEY (`positionAUser.uuid`)
  REFERENCES `pairbasedchatroom`.`Users` (`uuid`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION,
ADD CONSTRAINT `positionBUser.uuid`
  FOREIGN KEY (`positionBUser.uuid`)
  REFERENCES `pairbasedchatroom`.`Users` (`uuid`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
