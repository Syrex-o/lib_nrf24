(Wetter:wind|SmartSprinkler):.* {
    my $rain = ReadingsVal("Wetter","fc0_rain", "");
    my $wind = ( ReadingsVal("Wetter","fc0_wind00", "") + ReadingsVal("Wetter","fc0_wind03", "") + ReadingsVal("Wetter","fc0_wind06", "") + ReadingsVal("Wetter","fc0_wind06", "") + ReadingsVal("Wetter","fc0_wind09", "") + ReadingsVal("Wetter","fc0_wind12", "") + ReadingsVal("Wetter","fc0_wind15", "") + ReadingsVal("Wetter","fc0_wind18", "") + ReadingsVal("Wetter","fc0_wind21", "") ) / 8;
    my $maxTemp = ReadingsVal("Wetter", "fc0_tempMax", "");
    my $minTemp = ReadingsVal("Wetter", "fc0_tempMin", "");
    my $mail = ReadingsVal("SmartSprinkler", "winterProtect", "");
    my $offWind = ReadingsVal("SmartSprinkler", "wind", "");
    my $offRain = ReadingsVal("SmartSprinkler", "rain", "");
    my $tooWindy = ($wind >= ReadingsVal("SmartSprinkler", "windOff", "")) ? "true" : "false";
    my $tooRainy = ($rain >= ReadingsVal("SmartSprinkler", "rainOff", "")) ? "true" : "false";
    { fhem("set WetterInfo rain $rain") };
    { fhem("set WetterInfo wind $wind") };
    { fhem("set WetterInfo maxTemp $maxTemp") };
    { fhem("set WetterInfo minTemp $minTemp") };
    if($offWind eq "true"){
        { fhem("set WetterInfo tooWindy $tooWindy") };
    }
    if($offWind eq "false"){
        { fhem("set WetterInfo tooWindy false") };
    }
    if($offRain eq "true"){
        { fhem("set WetterInfo tooRainy $tooRainy") };
    }
    if($offRain eq "false"){
        { fhem("set WetterInfo tooRainy false") };
    }
}
