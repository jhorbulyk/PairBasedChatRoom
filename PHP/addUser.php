<?php

include 'sqlconnect.php';
$conn = connectDB();
$sql = "INSERT INTO Users (password, email,username)
VALUES ('Simon','sluo@hotmail.com','sluo')";

if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}?>
