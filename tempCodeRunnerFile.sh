logfile="$HOME/Desktop/TWX/disk.log"
mkdir -p "$(dirname "$logfile")"

trap "echo '[$(date)] ERROR: script failed' | tee -a $logfile" ERR

partition="${1:-/dev/sda2}"

disk_size=$(df -h "$partition" | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$disk_size" -gt 80 ]; then
    echo "[$(date)] $partition - ${disk_size}% used - WARNING" | tee -a "$logfile"
else
    echo "[$(date)] $partition - ${disk_size}% used - SAFE: Congratulations Xaynnn" | tee -a "$logfile"
fi