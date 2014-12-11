<?php
include '../common/session.php';
$user = getUser();

include '../common/sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare(
    'SELECT name, statementA, statementB FROM Topics WHERE id = ?'
);
$sql->bind_param('i', $_POST["topic"]);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    $sql->bind_result($name, $statementA, $statementB);
    $sql->fetch();
    $entry["name"] = $name;
    $entry["statementA"] = $statementA;
    $entry["statementB"] = $statementB;
    echo json_encode($entry);
}
?>
