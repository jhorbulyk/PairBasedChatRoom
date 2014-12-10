<html>
<?php
    session_start();
?>

<?php

include 'sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare('UPDATE Posts SET postContent=?, seenByOtherUser=0 WHERE id=?');
$sql->bind_param('s,i',$_POST["postContent"],$_POST["id"]);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} 

$conn->close();
?>
</html>