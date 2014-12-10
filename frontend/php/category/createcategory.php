<?php
include '../common/sqlconnect.php';
$conn = connectDB();

if($_POST["parent"]) {
    $sql = $conn->prepare('INSERT INTO Categories(name, parent) VALUES (?,?)');
    $sql->bind_param('sd', $_POST["name"],$_POST["parent"]);
} else {
    $sql = $conn->prepare('INSERT INTO Categories(name) VALUES (?)');
    $sql->bind_param('s', $_POST["name"]);
}
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    echo "Category created successfully.";
}

$conn->close();

?>
