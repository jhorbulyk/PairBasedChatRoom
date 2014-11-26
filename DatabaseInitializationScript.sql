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
CREATE TABLE Users (
    uuid BIGINT NOT NULL UNIQUE PRIMARY KEY,
    email CHAR(20) NOT NULL UNIQUE,
    password CHAR(20) NOT NULL,
    username CHAR(20) NOT NULL UNIQUE
);

# Triggers to handle integrety constraints on updates and insertions
# Creation
DELIMITER //
CREATE TRIGGER NewUser BEFORE INSERT ON Users
FOR EACH ROW
BEGIN 
    # Generate UUID if not created
    IF (NEW.uuid = 0) THEN
        SET NEW.uuid = UUID_SHORT();
    END IF;
    # Reject empty passwords
    If (LENGTH(NEW.password) = 0) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Password can not be empty.';
    END IF; 
    # Reject empty usernames
    If (LENGTH(NEW.username) = 0) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Username can not be empty.';
    END IF; 
    # The email address must be valid
    IF(NEW.email NOT REGEXP '^[[:alnum:]]+@[[:alpha:]]+[[.full-stop.]][[:alpha:]]{2,3}$') THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Email is not valid.';
    END IF;
END;

# Ensure validity
CREATE PROCEDURE validateUser(password
CREATE TRIGGER NewUser BEFORE INSERT ON Users
FOR EACH ROW
BEGIN 
    # Reject empty passwords
    If (LENGTH(NEW.password) = 0) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Password can not be empty.';
    END IF; 
    # Reject empty usernames
    If (LENGTH(NEW.username) = 0) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Username can not be empty.';
    END IF; 
    # The email address must be valid
    IF(NEW.email NOT REGEXP '^[[:alnum:]]+@[[:alpha:]]+[[.full-stop.]][[:alpha:]]{2,3}$') THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Email is not valid.';
    END IF;
END;
//
DELIMITER ;
