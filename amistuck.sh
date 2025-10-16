#!/bin/bash

# This script is intended for use as a liveness probe of an ActiveMQ server.
# It expects the name of a queue to monitor and an optional threshold value
# in seconds (defaults to 300). The script uses the Jolokia API endpoint to
# find the current size of the queue. If that size differs from a previously
# recorded size, or there is no previously recorded size (such as during the
# first # execution of the script), it simply records the current size of
# the queue and exits normally.
#
# If, however, the current size is the same as the previously recorded size
# (and it is not 0), then the script compares the current time to the last
# time the size was recorded as changing. If that value is greater than the
# threshold, the script emits a status message to STDOUT and exits with a
# nonzero status.

QUEUE=$1
THRESHOLD=${2:-300}

URL="http://localhost:8161/api/jolokia/read/org.apache.activemq:brokerName=localhost,destinationName=$QUEUE,destinationType=Queue,type=Broker"
SIZE_FILE="/tmp/activemq/$QUEUE"

last_size=$(cat "$SIZE_FILE" 2>/dev/null)
current_size=$(curl -s -H 'Origin: http://localhost' "$URL" | grep -o -e '"QueueSize":[0-9]*' | cut -d: -f2)

if [ -z "$last_size" ]; then
  # no size recorded yet; record the size and exit success
  echo "$current_size" > "$SIZE_FILE"
  exit 0
else
  if (( current_size != last_size )); then
    # size changed; record the new size and exit success
    echo "$current_size" > "$SIZE_FILE"
    exit 0
  else
    if (( current_size == 0 )); then
      # remaining at 0 is fine
      exit 0
    else
      # size remaining at a non-zero value longer than $THRESHOLD is NOT okay
      now=$(date +'%s')
      last_change=$(stat -c'%Y' "$SIZE_FILE")
      elapsed=$((now - last_change))
      if (( elapsed > THRESHOLD )); then
        error="Queue ${QUEUE} has been stuck at ${last_size} for ${elapsed} seconds (threshold is ${THRESHOLD} seconds)"
        # send the error message to both the pod log (file descriptor 1 of pid 1)...
        echo "$error" > /proc/1/fd/1
        # ...and the liveness probe failure message (STDERR)
        echo "$error" >&2
        exit 1
      fi
    fi
  fi
fi
