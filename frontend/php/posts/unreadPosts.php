
<html>
<!--Get Number of Unread Posts
Find All conversations that a user is participating in.
For each conversation find all posts where the author is the other user and the unread flag is true.-->
<?php
    session_start();
?>

<?php

include 'sqlconnect.php';
$conn = connectDB();
$userid =$_SESSION["userId"];
$total = 0;
$sql = $conn->prepare('SELECT Conversations.id FROM Conversations 
INNER JOIN Posts 
ON  Conversations.id = Posts.id WHERE Conversations.positionAUser=? AND Posts.postedBySideA=0 AND Posts.seenByOtherUser=0');
$sql->bind_param('i',userid);
$sql->execute();

$sql->bind_result($id);

if($sql->error) {
    echo $sql->error;
} 

$total += count($id);

$conn->close();

$conn = connectDB();
$sql = $conn->prepare('SELECT Conversations.id FROM Conversations 
INNER JOIN Posts 
ON  Conversations.id = Posts.id WHERE Conversations.positionBUser=? AND Posts.postedBySideA=1 AND Posts.seenByOtherUser=0');
$sql->bind_param('i',userid);
$sql->execute();

$sql->bind_result($id2);

if($sql->error) {
    echo $sql->error;
} 
$total += count($id2);
$conn->close();
?>
</html>