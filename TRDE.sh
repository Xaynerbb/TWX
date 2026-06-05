#!/bin/bash

clear
echo "🧠 INITIALIZING TERMINAL REALITY DISTORTION ENGINE..."
sleep 1

echo "🔌 Connecting to system kernel..."
sleep 1

echo "⚠️ WARNING: Unstable system environment detected"
sleep 1

echo "📡 Syncing with pseudo-network nodes..."
sleep 1

echo "--------------------------------------"

EVENTS=(
"Unauthorized access attempt detected"
"CPU spike in sector 7"
"Memory leak stabilized"
"Ghost process spawned and terminated"
"Firewall negotiated unknown packet"
"Kernel is thinking..."
"User activity being profiled"
)

for i in {1..15}
do
  RAND_EVENT=${EVENTS[$RANDOM % ${#EVENTS[@]}]}
  TIMESTAMP=$(date +"%H:%M:%S")

  echo "[$TIMESTAMP] $RAND_EVENT"

  # chaos delay
  sleep 0.5

  # random glitch effect
  if (( RANDOM % 5 == 0 )); then
    echo ">>> SYSTEM GLITCH <<<"
    sleep 0.3
  fi
done

echo "--------------------------------------"
echo "🧠 SYSTEM STATUS: UNSTABLE BUT FUNCTIONAL"
echo "🧾 Generating fake diagnostics report..."
sleep 2

echo "
CPU Usage: 87%
RAM Stability: fluctuating
Network Integrity: compromised (but ignored)
Kernel Mood: suspicious
Threat Level: undefined
"

echo "✅ TRDE SESSION COMPLETE"
