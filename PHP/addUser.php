<?php

//connecting to the database 
function connectDB() {
    $servername = "localhost";
	$username = "root";
	$password = "tester";
	$dbname = "pairbasedchatroom";

	// Create connection
	$conn = new mysqli($servername, $username, $password, $dbname);
	// Check connection
	if ($conn->connect_error) {
		die("Connection failed: " . $conn->connect_error);
	}
	
	return $conn;
}

$conn = connectDB();
$sql = "INSERT INTO Users (password, email,username)
VALUES ('Simon','sluo@hotmail.com','sluo')";

if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}?>