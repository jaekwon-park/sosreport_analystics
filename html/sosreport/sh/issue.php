<?php 
header('Content-Type: application/json; charset=UTF-8');
echo json_encode(shell_exec('cat data/lsb_release.txt')) ;
