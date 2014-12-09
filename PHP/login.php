<?php
    session_start();
?>

<?php

include 'sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare('SELECT id, email, password FROM Users WHERE email = ? AND password=?');
$sql->bind_param('ss', $_POST["email"], $_POST["password"]);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    $sql->bind_result($id, $email, $password);
    if($sql->fetch()) {
        $_SESSION["userId"] = $id;
        echo "Logged In successfully.";
    } else {
        echo "Invalid Username/password.";
    }
}

$conn->close();

?>
