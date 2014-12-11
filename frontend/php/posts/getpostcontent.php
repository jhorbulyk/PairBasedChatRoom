<?php
include '../common/sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare(
    "SELECT postedBySideA, postContent FROM Posts WHERE conversation = ? ORDER BY creationTime DESC"
);
$sql->bind_param('i', $_POST["conversation"]);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    $sql->bind_result($postedByA, $content);
    $results = array();
    while($sql->fetch()) {
        $entry["content"] = $content;
        $entry["postedByA"] = $postedByA;
        array_push($results, $entry);
    }
    echo json_encode($results);
}
?>
