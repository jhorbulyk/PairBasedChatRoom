<?php

include '../common/sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare('UPDATE Users SET username=?,email=?,password=? WHERE id=?');

include '../common/session.php';
$sql->bind_param('sssd', $_POST["username"],$_POST["email"],$_POST["password"],getUser());
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    echo "User updated successfully.";
}

$conn->close();

?>
