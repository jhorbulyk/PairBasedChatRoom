<?php
    session_start();
?>

<?php

include 'sqlconnect.php';
$conn = connectDB();
$sql = "INSERT INTO Users (password, email,username)
VALUES ('Simon','sluo@hotmail.com','sluo')";

if ($conn->query($sql) === TRUE) {
    $_SESSION["userId"] = $conn->insert_id;
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}?>
