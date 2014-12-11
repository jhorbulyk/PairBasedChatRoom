<?php
include '../common/sqlconnect.php';
$conn = connectDB();

if($_POST["category"]) {
    $sql = $conn->prepare('INSERT INTO Topics(name, statementA, statementB, category) VALUES (?,?,?,?)');
    $sql->bind_param('sssd', $_POST["name"], $_POST["statementA"], $_POST["statementB"], $_POST["category"]);
} else {
    $sql = $conn->prepare('INSERT INTO Topics(name, statementA, statementB) VALUES (?,?,?)');
    $sql->bind_param('sss', $_POST["name"], $_POST["statementA"], $_POST["statementB"]);
}
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    echo $sql->insert_id;
}

$conn->close();

?>
