<html>
<?php
    session_start();
?>

<?php

if($_POST["postedBySideA"]) {
    $postedByA = 1;
} else {
    $postedByA = 0;
}

include '../common/sqlconnect.php';
$conn = connectDB();
$sql = $conn->prepare('INSERT INTO Posts(conversation,postContent,postedBySideA) VALUES(?,?,?)');
$sql->bind_param('isi',$_POST["conversation"],$_POST["postContent"], $postedByA);
$sql->execute();

if($sql->error) {
    echo $sql->error;
}  else {
    echo "post created successfully.";
}

$conn->close();
?>
</html>
