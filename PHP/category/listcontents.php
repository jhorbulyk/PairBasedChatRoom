<?php
include '../common/sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare(
    'SELECT id, name, "categories" FROM Categories WHERE parent = ? UNION SELECT id, name, "topic"'
);
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
?>
