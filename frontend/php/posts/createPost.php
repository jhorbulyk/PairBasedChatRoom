<html>
<?php
    session_start();
?>

<?php

include 'sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare('INSERT INTO Posts(conversation,postContent,postedBySideA) VALUES(?,?,?)');
$sql->bind_param('i,s,i',$_POST["conversation"],$_POST["postContent"],$_POST["postedBySideA"]);
$sql->execute();

if($sql->error) {
    echo $sql->error;
} 

$conn->close();
?>
</html>