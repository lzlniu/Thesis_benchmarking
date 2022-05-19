#!/usr/bin/awk -f
{ x+=$2 ; y+=$2^2 }
END{print sqrt(y/NR-(x/NR)^2)}
