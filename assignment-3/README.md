# Assignment 3 — Linux High Load Troubleshooting (AWS Free Tier)

## Overview
A client reported that their Linux server had an extremely high load average.  
Example output observed:

```
12:20:50 up 1 day, 10:52, 6 users, load average: 44.28, 33.34, 30.44
```

This repository contains my analysis of the issue, the tools used in diagnosis, and the steps followed to identify the root cause.

---

## Steps Performed

### 1. Checked System Load & CPU
Commands:
```
uptime
top -b -n1 | head -n20
nproc
```
What I looked for:
- 1/5/15 min load averages  
- CPU usage breakdown  
- High `%wa` (I/O wait)  
- Compare load average with number of CPU cores  

---

### 2. Checked High CPU & Memory Processes
```
ps -eo pid,cmd,%cpu,%mem --sort=-%cpu | head
ps -eo pid,cmd,%cpu,%mem --sort=-%mem | head
```
Purpose:
- Identify runaway processes  
- Detect memory-heavy processes causing swap  

---

### 3. Investigated Disk I/O (Most common reason for high load)
```
iostat -xz 1 3
sudo iotop -o -P -b -n 5
vmstat 1 5
```
What I looked for:
- `%iowait` (should be low normally)  
- High latency (`await`)  
- Processes doing highest read/write operations  

---

### 4. Checked Memory & Swap
```
free -m
cat /proc/meminfo | egrep "MemAvailable|SwapTotal|SwapFree"
```
Purpose:
- Detect low memory situations  
- Identify swap usage that slows system performance  

---

### 5. Checked Disk Space & Inodes
```
df -h
df -i
```
Reasons:
- Full disks freeze services  
- Inode exhaustion blocks file creation  

---

### 6. Reviewed Kernel Logs
```
dmesg | tail -n 50
journalctl -k -n 100
```
Purpose:
- Detect filesystem errors  
- Disk failures  
- Kernel warnings  

---

### 7. Checked Network Load
```
ss -tunp
iftop
```
Purpose:
- Identify excessive connections  
- Detect traffic spikes  

---

## Diagnosis Summary (Example)
- Load average extremely high (44) on a 2-CPU machine  
- I/O wait (`%wa`) was above 80%  
- Disk latency (`await`) over 600ms  
- `iotop` showed a backup script consuming all disk bandwidth  

### ✔ Root Cause  
Heavy disk I/O caused by a background backup script leading to processes being blocked.

### ✔ Fix Applied  
- Stopped the script  
- Scheduled backup during non-peak hours  
- Recommended using faster EBS volumes (gp3)  

---

## Files Included
- **SOLUTION.md** → full step-by-step troubleshooting write-up  
- **scripts/collect_diagnostics.sh** → script to collect system logs & diagnostics  
- **report/FINDINGS.md** → formatted findings to submit  

---

## Author
MR.KUNDAN UMESH SONAWANE 

