<?php
include '../common/sqlconnect.php';
$conn = connectDB();

include '../common/session.php';
$user = getUser();

if($_POST["isPositionA"]) {
    $positionToFill = "positionAUser";
    $otherPostion = "positionBUser";
} else {
    $positionToFill = "positionBUser";
    $otherPostion = "positionAUser";
}

$sql = $conn->prepare("SELECT id FROM Conversations WHERE topic = ? AND $positionToFill IS NULL AND $otherPostion != ?");
$sql->bind_param('dd', $_POST["topic"],$user);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} else {
    $sql->bind_result($conversationId);
    if($sql->fetch()) {
        $conn->close(); 
        $conn = connectDB();
        
        $sql = $conn->prepare("UPDATE Conversations SET $positionToFill = ? WHERE id = ?");
        $sql->bind_param('dd', $user, $conversationId);
        $sql->execute();
        if($sql->error) {
            echo $sql->error;
        } else {
            echo "Paired into conversation.";
        }
    } else {
        $conn->close(); 
        $conn = connectDB();
        
        $sql = $conn->prepare("INSERT INTO Conversations(topic, $positionToFill) VALUES (?,?)");
        $sql->bind_param('ii', $_POST["topic"], $user);
        $sql->execute();
        if($sql->error) {
            echo $sql->error;
        } else {
            echo "Created new conversation.";
        }
        
    }
}

$conn->close();

?>
