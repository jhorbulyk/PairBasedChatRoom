<?php
include '../common/sqlconnect.php';
$currentparent = $_POST["parent"];
$results = array();

while($currentparent > -1) { 
    $conn = connectDB();
    $sql = $conn->prepare(
        'SELECT parent.id, parent.name FROM Categories child JOIN Categories parent ON child.parent = parent.id WHERE child.id = ?'
    );
    $sql->bind_param('d', $currentparent);
    $sql->execute();

    if($sql->error) {
        echo $sql->error;
    } else {
        $sql->bind_result($currentparent, $name);
        if($sql->fetch()) {
            $entry["id"] = $currentparent;
            $entry["name"] = $name;
        } else {
            $currentparent = -1;
            $entry["id"] = NULL;
            $entry["name"] = "Root";
        }
        array_push($results, $entry);
    }
    $conn->close();
}
echo json_encode($results);
?>
