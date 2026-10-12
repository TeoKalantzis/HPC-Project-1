#!/bin/bash

# Number of runs
RUNS=10
total_time=0

# Declare an array to store individual run times
declare -a times

echo "Running the Sobel filter $RUNS times..."
echo "----------------------------------------"

for ((i=1; i<=RUNS; i++))
do
    # Run the program and capture its output
    output=$(./sobel)
    
    # Extract the floating-point time value using awk
    t=$(echo "$output" | grep "Total time" | awk '{print $4}')
    
    echo "Run $i: $t seconds"
    
    # Store time in array and add to total
    times+=("$t")
    total_time=$(echo "$total_time + $t" | bc)
done

echo "----------------------------------------"

# Calculate the mean (total / RUNS) using bc -l for scale
mean_time=$(echo "scale=6; $total_time / $RUNS" | bc)

# Calculate standard deviation: sqrt( sum((t - mean)^2) / RUNS )
sum_sq_diff=0
for t in "${times[@]}"
do
    # Calculate difference: t - mean
    diff=$(echo "$t - $mean_time" | bc -l)
    # Square the difference: (t - mean)^2
    sq_diff=$(echo "$diff * $diff" | bc -l)
    # Accumulate sum of squared differences
    sum_sq_diff=$(echo "$sum_sq_diff + $sq_diff" | bc -l)
done

# Variance = sum of squared differences / RUNS
variance=$(echo "scale=6; $sum_sq_diff / $RUNS" | bc -l)

# Standard deviation = sqrt(variance)
# Note: bc -l doesn't have a built-in sqrt function, so we use Newton's method or awk/bc math trick. 
# Using awk for clean square root calculation:
std_dev=$(awk -v v="$variance" 'BEGIN { print sqrt(v) }')

echo "Results Summary:"
echo "----------------------------------------"
echo "Mean Time     : $mean_time seconds"
echo "Standard Dev  : $std_dev seconds"