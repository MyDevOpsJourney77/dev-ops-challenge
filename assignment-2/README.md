## Assignment 2 — Top 8 IP Address Counter

### Objective
The security team requested a simple tool to analyse web-server logs and identify the **top 8 IP addresses** generating the most hits.  
The task was to:

- Work with the given log file  
- Extract IP addresses  
- Count how many times each IP appears  
- Display only the top 8 results  
- Create an executable script **with no file extension** (named `count`)

---

### Files Included

---

### Script Description (`count`)
The script uses standard Linux utilities (`awk`, `sort`, `uniq`, `head`) to process the log file.

---

### How to Run the Script
Make sure you are inside the `assignment-2` folder.

```bash
chmod +x count     # make script executable (already done)
./count            # run the script

