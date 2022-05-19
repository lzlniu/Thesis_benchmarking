#!/usr/bin/awk -f
{ sum += $3 }
END { if (NR > 0) print sum / NR }
