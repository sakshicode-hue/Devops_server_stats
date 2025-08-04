#!/bin/bash

# calculate and display CPU usage
show_cpu_usage() {
    echo -e "\n=== CPU Usage ==="
    local cpu_usage=$(mpstat | awk '$3 ~ /[0-9.]+/ {print 100 - $12}')
    printf "Current CPU Usage: %.2f%%\n" "$cpu_usage"
    echo -e "Visual: [$(printf '#%.0s' $(seq 1 $(echo "$cpu_usage / 2" | bc -l)))]$(printf ' %.0s' $(seq 1 $((50 - $(echo "$cpu_usage / 2" | bc -l)))))"
}

# calculate and display memory usage
show_memory_usage() {
    echo -e "\n=== Memory Usage ==="
    read total used free <<< $(free | awk 'NR==2{printf "%s %s %s", $2, $3, $4}')
    local used_percentage=$(echo "scale=2; $used * 100 / $total" | bc)
    printf "Memory Used: %s, Memory Free: %s, Usage Percentage: %.2f%%\n" "$used" "$free" "$used_percentage"
    echo -e "Visual: [$(printf '#%.0s' $(seq 1 $(echo "$used_percentage / 2" | bc -l)))]$(printf ' %.0s' $(seq 1 $((50 - $(echo "$used_percentage / 2" | bc -l)))))"
}

# calculate and display disk usage
show_disk_usage() {
    echo -e "\n=== Disk Usage ==="
    local disk_info=$(df -h | awk '$NF=="/"{printf "%s %s %s", $3, $4, $5}')
    read used free percentage <<< $disk_info
    printf "Disk Used: %s, Disk Free: %s, Usage Percentage: %s\n" "$used" "$free" "$percentage"
    echo -e "Visual: [$(printf '#%.0s' $(echo "${percentage%?} / 2" | bc -l))]$(printf ' %.0s' $(seq 1 $((50 - ${percentage%?} / 2))))"
}

# top 5 CPU-consuming processes
list_top_cpu_processes() {
    echo -e "\n=== Top 5 Processes by CPU Usage ==="
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
}

# top 5 memory-consuming processes
list_top_memory_processes() {
    echo -e "\n=== Top 5 Processes by Memory Usage ==="
    ps -eo pid,comm,%mem --sort=-%mem | head -n 6
}

# additional server stats
gather_additional_stats() {
    echo -e "\n=== Additional Stats ==="
    echo "Operating System: $(lsb_release -d | cut -f2-)"
    echo "System Uptime: $(uptime -p)"
    echo "Load Average (1, 5, 15 mins): $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
    echo "Currently Logged In Users: $(who | wc -l)"
    echo "Failed Login Attempts: $(grep "Failed password" /var/log/auth.log | wc -l)"
}

show_cpu_usage
show_memory_usage
show_disk_usage
list_top_cpu_processes
list_top_memory_processes
gather_additional_stats