<?php 

    exec('cat data/fail.txt',$result);
    header('Content-Type: application/json; charset=UTF-8');

    echo "[";
    $x = 0;
    $max = count($result)-1;
    foreach ($result as $a)
    {    
        echo json_encode( explode(',',$result[$x]) );
        echo ($x==$max)?'':',';
        unset($result[$x],$a);
        $x++;
    }
    echo ']';
