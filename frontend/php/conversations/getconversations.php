<?php
include '../common/session.php';
$user = getUser();

include '../common/sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare(
    'SELECT id, topic, "true" FROM Conversations WHERE positionAUser = ?
    UNION
    SELECT id, topic, "false" FROM Conversations WHERE positionbUser = ?'
);
$sql->bind_param('ii', $user, $user);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    $sql->bind_result($id, $topic, $positionA);
    $results = array();
    while($sql->fetch()) {
        $entry["id"] = $id;
        $entry["topic"] = $topic;
        $entry["postionA"] = $positionA;
        array_push($results, $entry);
    }
    echo json_encode($results);
}
?>
