#!/usr/bin/awk -f
{ x+=$3 ; y+=$3^2 }
END{print sqrt(y/NR-(x/NR)^2)}
