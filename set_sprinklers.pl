(Sprinkler.*:state):.* {
    # set sprinklers based on mode (0 = interval ended normally / no callback needed (reset), 1 = interval1, 2 = interval2, 3 = manualTime)
    # Sprinklers  GPIOS:
    my @GPIOtranslate = (2, 3, 4, 5, 6, 7);
    my $mode = ReadingsVal("$NAME", "mode", "");
    my $duration = 0;
    my $time = 0;
    my $num = substr $NAME, -1;
    my $totalAmount = int(ReadingsVal("SmartSprinkler", "sprinklerAmount", ""));
    if($EVTPART1 eq "true"){
        # reset all others
        for(my $i = 1; $i <= $totalAmount; $i++){
            if($i != $num){
                if(ReadingsVal("Sprinkler$i", "callbackState", "") eq "true"){
                    fhem("set Sprinkler$i callbackState false");
                }
            }
        }
        # seconds passed in current min
        my $pastSecs = int(substr POSIX::strftime( '%T', localtime(time()) ), 6, 8);
        if($mode eq "1" or $mode eq "2"){
            my $local = substr POSIX::strftime( '%T', localtime(time()) ), 0, 5;
            $time = $local."-".ReadingsVal("$NAME", "smartEnd$mode", "");
            $duration = (duration($time, 1) * 60) - $pastSecs;
            if(ReadingsVal("SmartSprinkler", "enabled", "") eq "true" and ReadingsVal("WetterInfo", "tooRainy", "") eq "false" and ReadingsVal("WetterInfo", "tooWindy", "") eq "false"){
                {system("sudo python3 /opt/fhem/NRF24L01/sendSwitch.py $GPIOtranslate[int((substr $NAME, -1) -1 )] 1 $duration $NAME&")};
            }
            if(ReadingsVal("SmartSprinkler", "enabled", "") eq "false"){
                {system("sudo python3 /opt/fhem/NRF24L01/sendSwitch.py $GPIOtranslate[int((substr $NAME, -1) -1 )] 1 $duration $NAME&")};
            }
        }
        if($mode eq "3" and ReadingsVal("SmartSprinkler", "manualMode", "") eq "true"){
            # run Interval
            $duration = (30 * 60) - $pastSecs;
            {system("sudo python3 /opt/fhem/NRF24L01/sendSwitch.py $GPIOtranslate[int((substr $NAME, -1) -1 )] 1 $duration $NAME&")};
        }
    }
    if($EVTPART1 eq "false"){
        if($mode eq "0"){
            fhem("set $NAME callbackState false");
        }else{
            {system("sudo python3 /opt/fhem/NRF24L01/sendSwitch.py $GPIOtranslate[int((substr $NAME, -1) -1 )] 0 $duration $NAME&")};
        }
        # reset manual time
        if(ReadingsVal("$NAME", "manualTime", "") ne "00:00-00:00"){
            fhem("set $NAME manualTime 00:00-00:00");
        }
        my $isManual = 0;
        for(my $i = 1; $i <= $totalAmount; $i++){
            if(ReadingsVal("Sprinkler$i", "manualTime", "") ne "00:00-00:00"){
                $isManual = 1;
                last;
            }
        }
        if($isManual){
            fhem("set SmartSprinkler manualMode true");
        }else{
            fhem("set SmartSprinkler manualMode false");
        }
    }
}
