# FINDINGS — Linux High Load Issue Investigation

## Overview
This document summarizes the findings from analyzing a Linux server that reported a very high load average.  
Diagnostic commands were executed to determine whether the issue was caused by CPU, memory, disk I/O, or network load.

---

## System Snapshot (Example)
```
12:20:50 up 1 day, 10:52, 6 users, load average: 44.28, 33.34, 30.44
```

**vCPUs:** 2  
**Load:** Extremely high relative to CPU count

---

## Key Diagnostic Observations

### ✔ CPU & Load
- High load average far above available CPU cores  
- CPU idle time very low  
- `%wa` (I/O wait) extremely high (~80%)  

### ✔ Disk I/O (Primary Issue)
- `iostat` showed:
  - High latency (`await` = 600–800 ms)
  - High utilization on main disk  
- `iotop` identified a script (`backup.sh`) causing continuous heavy writes  
- Many processes were in a **blocked** state because of disk saturation  

### ✔ Memory & Swap
- Memory usage normal  
- No major swap activity  
- Not the cause of the load spike  

### ✔ Disk Space & Inodes
- Sufficient free space  
- No inode exhaustion  
- No filesystem freeze due to disk full  

### ✔ Kernel Logs
- No kernel panics  
- No filesystem corruption  
- Some warnings related to slow disk response times  

### ✔ Network
- No abnormal inbound/outbound traffic  
- No signs of DDoS or connection flooding  

---

## Root Cause

**Heavy disk I/O caused by a background backup process**, leading to extremely high disk wait time (`%iowait`).  
As a result, multiple processes were blocked, causing the overall system load to rise above 40.

---

## Immediate Fix Applied
1. Identified the backup process consuming disk bandwidth  
2. Stopped the process:
   ```bash
   sudo kill <PID>
   ```
3. System load dropped back to normal levels  

---

## Final Recommendations

### 🔹 Short-Term
- Run backup jobs during off-peak hours  
- Limit I/O usage using `ionice` if needed  

### 🔹 Long-Term
- Move I/O-heavy workloads to a separate EBS volume  
- Upgrade disk to **gp3** or higher IOPS class  
- Configure CloudWatch alerts for:
  - High load average  
  - High `%iowait`  
  - High disk utilization  
- Enable `sysstat` for daily historical performance logs  

---

## Conclusion
The root cause of the high load was traced to disk bottlenecking caused by a backup script.  
By analyzing CPU, memory, disk I/O, logs, and network connections, the issue was isolated and resolved effectively.

