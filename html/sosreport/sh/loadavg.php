<?php 
    
    exec('cat data/cpu_count.txt',$resultNumberOfCores);
    header('Content-Type: application/json; charset=UTF-8');
    $numberOfCores = $resultNumberOfCores[0];

    exec('cat data/load_average.txt',$resultLoadAvg);
    header('Content-Type: application/json; charset=UTF-8');

    $loadAvg = explode(',',$resultLoadAvg[0]);

    echo json_encode(
        array_map(
            "convertToPercentage",
            $loadAvg,
            array_fill(0, count($loadAvg), $numberOfCores)
        )
    );
    
    function convertToPercentage($value, $numberOfCores){
        return array($value, (int)($value * 100 / $numberOfCores));
    }
