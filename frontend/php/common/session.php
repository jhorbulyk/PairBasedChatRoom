<?php
    session_start();
?>

<?php
    function getUser() {
        return $_SESSION["userId"];
    }
?>
