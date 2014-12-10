<?php
include '../common/sqlconnect.php';
$conn = connectDB();

if($_POST["categoryToMove"]) {
    $insertInto = "categoryToMove";
    $insertValue = $_POST["categoryToMove"];
} else {
    $insertInto = "topicToMove";
    $insertValue = $_POST["topicToMove"];
}

if($_POST["newCategory"]) {
    $sql = $conn->prepare("INSERT INTO SuggestionsToChange($insertInto, newCategory) VALUES (?,?)");
    $sql->bind_param('dd', $insertValue, $_POST["newCategory"]);
} else {
    $sql = $conn->prepare("INSERT INTO SuggestionsToChange($insertInto) VALUES (?)");
    $sql->bind_param('d', $insertValue);
}
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    echo "Change suggestion created successfully.";
}

$conn->close();
?>
