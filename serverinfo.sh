#! /bin/bash

if [ "$#" -lt 1 ]; then
  echo "usage: $(basename $0) serverip [username]"
  exit 1
fi

host=$1
user=$USER
[ "$#" -gt 1 ] && user=$2

cpuskip=('Architecture' 'CPU op-mode' 'On-line CPU' 'Byte' 'Vendor ID' 'CPU family' 'Model' 'Stepping' 'BogoMIPS')
cpugrep='grep -v'
for exp in "${cpuskip[@]}"; do
  cpugrep+=" -e '^$exp'"
done

cpu="lscpu | $cpugrep; echo"
mem="free -g | head -n2; echo"
disk="df -h /home; echo"
gcc="gcc --version | head -n1"
os="cat /etc/*release"

ssh $user@$host "$cpu; $mem; $disk; $gcc; $os; uptime"
