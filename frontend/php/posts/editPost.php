<html>
<?php
    session_start();
?>

<?php

include 'sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare('UPDATE Posts SET postContent=?, seenByOtherUser=? WHERE conversation=?'.
	'AND creationTime=? AND postedBySideA=?');
$sql->bind_param('s,i,i,s,i',$_POST["postContent"],$_POST["seenByOtherUser"],
$_POST["postedBySideA"], $_POST["conversation"], $_POST["creationTime"],$_POST["postedBySideA"]);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} 

$conn->close();
?>
</html>