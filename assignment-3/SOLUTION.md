# SOLUTION — Linux High Load Troubleshooting

## Introduction
This document describes my detailed troubleshooting process for a Linux server that was reporting an extremely high load average.  
The goal was to diagnose whether the issue was caused by CPU saturation, memory pressure, heavy disk I/O, or network traffic.

A sample output from the affected system:

```
12:20:50 up 1 day, 10:52, 6 users, load average: 44.28, 33.34, 30.44
```

---

# 1. Checked System Load & CPU Usage

### Commands used:
```bash
uptime
top -b -n1 | head -n20
nproc
```

### What I looked for:
- Load average values  
- Number of CPU cores  
- CPU breakdown in top  
- `%wa` (I/O wait), `%id` (idle)  

---

# 2. Checked CPU & Memory Heavy Processes

### Commands:
```bash
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head
```

What I looked for:
- High CPU usage  
- High memory usage  
- Unexpected processes  

---

# 3. Investigated Disk I/O

### Commands:
```bash
iostat -xz 1 3
sudo iotop -o -P -b -n 5
vmstat 1 5
```

What I looked for:
- High `%iowait`  
- High latency (`await`)  
- Processes causing heavy disk reads/writes  
- Blocked tasks  

---

# 4. Checked Memory & Swap

### Commands:
```bash
free -m
cat /proc/meminfo | egrep 'MemAvailable|SwapTotal|SwapFree'
```

What I looked for:
- Low free memory  
- High swap usage  

---

# 5. Checked Disk Space & Inodes

### Commands:
```bash
df -h
df -i
```

Looked for:
- Full disk partitions  
- Inode exhaustion  

---

# 6. Reviewed Kernel Logs

### Commands:
```bash
dmesg | tail -n 200
journalctl -k -n 200
```

Looked for:
- Disk failures  
- I/O errors  
- Filesystem issues  

---

# 7. Checked Network Load

### Commands:
```bash
ss -tunp
iftop
```

Looked for:
- Many active connections  
- Heavy incoming/outgoing traffic  

---

# 8. Example Root Cause

- Load average > 40  
- `%wa` > 80%  
- High disk `await` time  
- `iotop` showed a backup script doing massive I/O  

**Root Cause:** Disk I/O saturation by a backup script.

---

# 9. Fix Applied

### Immediate:
- Stopped the script  
- Cleared blocked processes  

### Long-Term:
- Scheduled backup at off-peak hours  
- Suggested faster EBS volume (gp3)  
- Added performance alarms  

---

# 10. Conclusion
The extremely high load average was traced to high disk I/O wait caused by a background job.  
By analyzing CPU, memory, disk, logs, and network, the root cause was identified and resolved.

