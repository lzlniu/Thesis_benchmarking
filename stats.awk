#!/usr/bin/awk -f
{ 
    sum += $2
    y += $2^2
    nums[NR] = $2  # We store the input records
}
END {
    if (NR == 0) exit  #To avoid division by zero
 
    asort(nums)  #  Here, we sort the array that
                 #+ contains the stored input
 
    median = (NR % 2 == 0) ?  #  Let's be carefull with the
                              #+ short-if syntax
        ( nums[NR / 2] + nums[(NR / 2) + 1] ) / 2 \
        :
        nums[int(NR / 2) + 1]
 
    #  We used "(NR / 2) + 1", instead "NR/2 + 1", just for
    #+ the sake of clarity; to be more verbose
 
    mean = sum/NR
    
    std = sqrt( y / NR - (sum / NR)^2 )
    # output
    printf \
        "min = %s, max = %s, median = %s, mean = %s std = %s\n",\
        nums[1],\
        nums[NR],\
        median,\
        mean,
	std
}
