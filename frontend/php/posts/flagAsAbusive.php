<html>
<?php
    session_start();
?>

<?php

include 'sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare('UPDATE Posts SET flaggedAsAbusive = 1,seenByOtherUser=1 WHERE id=?');
$sql->bind_param('i',$_POST["id"]);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} 

$conn->close();
?>
</html>