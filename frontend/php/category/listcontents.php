<?php
include '../common/sqlconnect.php';
$conn = connectDB();
if($_POST["parent"]) {
    $sql = $conn->prepare(
        'SELECT id, name, "categories" FROM Categories WHERE parent = ? UNION SELECT id, name, "topic" FROM Topics WHERE category = ?'
    );
    $sql->bind_param('ss', $_POST["parent"], $_POST["parent"]);
} else {
    $sql = $conn->prepare(
        'SELECT id, name, "categories" FROM Categories WHERE parent IS NULL UNION SELECT id, name, "topic" FROM Topics WHERE category IS NULL'
    );
}
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    $sql->bind_result($id, $name, $type);
    $results = array();
    while($sql->fetch()) {
        $entry["id"] = $id;
        $entry["name"] = $name;
        $entry["type"] = $type;
        array_push($results, $entry);
    }
    echo json_encode($results);
}
?>
