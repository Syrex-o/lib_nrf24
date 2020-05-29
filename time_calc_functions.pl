## Sprinkler Functions

sub autoTimes($$$){
    my($totalAmount, $sprinkler, $interval) = @_;
    
    for(my $i = (substr $sprinkler, -1) + 1; $i <= $totalAmount; $i++){
        if($i <= $totalAmount){
            my $currentVal = ReadingsVal("Sprinkler".($i - 1), "interval".$interval, "");
            # start and end of setted sprinkler
            my $startMin = timeToMin(substr $currentVal, 0,5);
            my $endMin = timeToMin(substr $currentVal, 6,5);

            my $nextVal = ReadingsVal("Sprinkler".$i, "interval".$interval, "");
            # duration of next sprinkler / checking if time goes through 00:00
            my $dur = duration($nextVal, 1);

            my $newStart = $endMin + 1 >= 1440 ?  ($endMin + 1) - 1440 : $endMin + 1;
            my $newEnd = $newStart + $dur >= 1440 ? ($newStart + $dur) - 1440 : $newStart + $dur;
            my $newTime = timeConclude(minToTime($newStart), minToTime($newEnd));

            fhem("set Sprinkler$i interval$interval $newTime");
        }
    }
    # update smart times
    smartTimes($totalAmount, $interval, substr $sprinkler, -1);
}

sub smartTimes($$$){
    my($totalAmount, $interval, $startPoint) = @_;
    
    # check temperature state
    my $percentage = 1;
    if(ReadingsVal("SmartSprinkler", "enabled", "") eq "true"){
        if(ReadingsVal("Wetter", "fc0_tempMin", "") <= ReadingsVal("SmartSprinkler", "lowTemp", "")){
            $percentage = 1 - ( ReadingsVal("SmartSprinkler", "lowPercentage", "") / 100);
        }
        if(ReadingsVal("Wetter", "fc0_tempMax", "") >= ReadingsVal("SmartSprinkler", "highTemp", "")){
            $percentage = 1 + ( ReadingsVal("SmartSprinkler", "highPercentage", "") / 100);
        }
    }
    for(my $i = $startPoint; $i <= $totalAmount; $i++){
        my $currentVal = ReadingsVal("Sprinkler".$i, "interval".$interval, "");
        my $dur = duration($currentVal, $percentage);
        my $smartStart = 0;
        my $smartEnd = 0;
        if($i == 1){
            # setting first Sprinkler smart time
             $smartStart = substr ReadingsVal("Sprinkler".$i, "interval".$interval, ""), 0, 5;
             $smartEnd = minToTime(timeToMin($smartStart) + $dur >= 1440 ? (timeToMin($smartStart) + $dur) - 1440 : timeToMin($smartStart) + $dur);
        }else{
            # eval last smart end
            my $lastEnd = ReadingsVal("Sprinkler".($i - 1), "smartEnd".$interval, "");
            $smartStart = minToTime(timeToMin($lastEnd) + 1 >= 1440 ? (timeToMin($lastEnd) + 1) - 1440 : timeToMin($lastEnd) + 1);
            $smartEnd = minToTime(timeToMin($smartStart) + $dur >= 1440 ? (timeToMin($smartStart) + $dur) - 1440 : timeToMin($smartStart) + $dur);
        }
        fhem("set Sprinkler$i smartStart$interval $smartStart");
        fhem("set Sprinkler$i smartEnd$interval $smartEnd");
    }
}

sub setManualTimes($){
    my($totalAmount) = @_;
    my $duration = 30;
    my $local = substr POSIX::strftime( '%T', localtime(time()) ), 0, 5;
    my $start = 0;
    my $end = 0;
    my $combined = 0;
    for(my $i = 1; $i <= $totalAmount; $i++){
        if($i == 1){
            # setting first manual time
            $start = $local;
            $end = minToTime(timeToMin($start) + $duration >= 1440 ? (timeToMin($start) + $duration) - 1440 : timeToMin($start) + $duration);
        }else{
            my $lastEnd = substr ReadingsVal("Sprinkler".($i - 1), "manualTime", ""), 6, 5;
                $start = minToTime(timeToMin($lastEnd) + 1 >= 1440 ? (timeToMin($lastEnd) + 1) - 1440 : timeToMin($lastEnd) + 1);
            $end = minToTime(timeToMin($start) + $duration >= 1440 ? (timeToMin($start) + $duration) - 1440 : timeToMin($start) + $duration);
        }
        $combined = timeConclude($start, $end);
        fhem("set Sprinkler$i manualTime $combined");
        fhem("set Sprinkler$i mode 3");
    }
}

# Helper Functions

sub duration($$){
    # needs time input
    my($timespec, $multiplier) = @_;
    return floor(
        (
            timeToMin(substr $timespec, 6,5) < timeToMin(substr $timespec, 0,5) ? 
            (1440 - timeToMin(substr $timespec, 0,5)) + timeToMin(substr $timespec, 6,5) :
            timeToMin(substr $timespec, 6,5) - timeToMin(substr $timespec, 0,5)
        ) * $multiplier
    );
}

sub timeToMin($){
    my $hours = int(substr $_[0], 0, 2);
    my $mins = int(substr $_[0], 3, 2);
    return ($hours * 60) + $mins;
}

sub minToTime($){
    my ($min) = @_;
    my $h = floor(int(($min / 60) >= 24) ? int($min / 60) -24 : int($min / 60));
    $h = $h < 10 ? "0".$h : $h;
    my $m = floor($min % 60) < 10 ? "0".floor($min % 60) : floor($min % 60);
    return $h.":".$m;
}

sub timeConclude($$){
    return $_[0].'-'.$_[1];
}

sub resetManualTimes($){
    my($totalAmount) = @_;
    for(my $i = 1; $i <= $totalAmount; $i++){
        fhem("set Sprinkler$i manualTime 00:00-00:00");
    }
}
