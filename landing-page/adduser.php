<?php
    session_start();
?>

<?php

include 'sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare('INSERT INTO Users (username,email,password) VALUES (?,?,?)');
$sql->bind_param('sss', $_POST["username"],$_POST["email"],$_POST["password"]);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    $_SESSION["userId"] = $sql->insert_id;
}

$conn->close();
header("Location: http://localhost/amit/landing-page/index.html"); /* Redirect browser */
?>
