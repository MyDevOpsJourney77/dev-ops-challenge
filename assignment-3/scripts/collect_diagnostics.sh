#!/bin/bash
# collect_diagnostics.sh
# Script to gather diagnostic information from a Linux server
# Run this script as root or with sudo.

set -e

OUTDIR="/tmp/diagnostics"
mkdir -p "$OUTDIR"

echo "=== Collecting System Diagnostics ==="
echo "All outputs will be saved to: $OUTDIR"
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s)
fi

echo "Detected OS: $OS"
echo ""

# Install required packages
echo "Installing required tools..."

if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    apt update -y || true
    apt install -y sysstat iotop iftop dstat htop net-tools || true

elif [[ "$OS" == "amzn" || "$OS" == "centos" || "$OS" == "rhel" ]]; then
    yum install -y sysstat iotop iftop dstat htop net-tools || true

else
    echo "Unsupported OS for automatic package installation"
    echo "Please manually install: sysstat, iotop, iftop, dstat, htop"
fi

echo "Tools installed!"
echo ""

# System Snapshot
echo "Saving system snapshot..."
uptime > "$OUTDIR/uptime.txt"
nproc > "$OUTDIR/nproc.txt"
cat /proc/loadavg > "$OUTDIR/loadavg.txt"

# Top & PS outputs
top -b -n1 > "$OUTDIR/top.txt"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu > "$OUTDIR/ps_cpu.txt"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem > "$OUTDIR/ps_mem.txt"

# Disk I/O
if command -v iostat >/dev/null; then
    iostat -xz 1 3 > "$OUTDIR/iostat.txt"
fi

if command -v iotop >/dev/null; then
    timeout 10 iotop -o -P -b -n 5 > "$OUTDIR/iotop.txt" || true
fi

vmstat 1 5 > "$OUTDIR/vmstat.txt"
free -m > "$OUTDIR/free_mem.txt"
cat /proc/meminfo > "$OUTDIR/proc_meminfo.txt"

# Disk usage
df -h > "$OUTDIR/df_h.txt"
df -i > "$OUTDIR/df_i.txt"

# Kernel logs
dmesg | tail -n 200 > "$OUTDIR/dmesg_tail.txt"

# Network
ss -tunp > "$OUTDIR/ss_tunp.txt"

if command -v iftop >/dev/null; then
    timeout 8 iftop -t -s 1 -n -P > "$OUTDIR/iftop.txt" || true
fi

# Tar the directory
tar -czf /tmp/diagnostics.tar.gz -C /tmp diagnostics

echo ""
echo "Diagnostics collection complete!"
echo "Files saved to: $OUTDIR"
echo "Archive created at: /tmp/diagnostics.tar.gz"
