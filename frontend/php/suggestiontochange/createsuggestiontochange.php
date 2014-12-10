<?php
include '../common/sqlconnect.php';
$conn = connectDB();

if($_POST["newCategory"] != 0) {
    $sql = $conn->prepare('INSERT INTO SuggestionsToChange(categoryToMove, topicToMove, newCategory) VALUES (?,?,?)');
    $sql->bind_param('ddd', $_POST["categoryToMove"],$_POST["topicToMove"], $_POST["newCategory"]);
} else {
    $sql = $conn->prepare('INSERT INTO SuggestionsToChange(categoryToMove, topicToMove, newCategory) VALUES (?,?, NULL)');
    $sql->bind_param('dd', $_POST["categoryToMove"],$_POST["topicToMove"]);
}
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    echo "Change suggestion created successfully.";
}

$conn->close();
?>
