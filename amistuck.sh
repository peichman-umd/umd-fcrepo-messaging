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
# threshold, the script emits an error message and exits with a nonzero status.
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 QUEUE_NAME [TIMEOUT]"
    exit 1
fi

QUEUE=$1
THRESHOLD=${2:-300}

URL="http://localhost:8161/api/jolokia/read/org.apache.activemq:brokerName=localhost,destinationName=$QUEUE,destinationType=Queue,type=Broker"
SIZE_FILE="/tmp/activemq/$QUEUE"

check_writable() {
    local file="${1:-}"
    if [[ -e "${file}" ]]; then
        # File exists — check direct write permission
        if [[ ! -w "${file}" ]]; then
            echo "File '${file}' exists but is not writable." >&2
            exit 1
        fi
    else
        # File does not exist — check parent directory
        local dir
        dir="$(dirname "${file}")"
        if [[ ! -d "${dir}" || ! -w "${dir}" ]]; then
            echo "File '${file}' does not exist and directory '${dir}' is not writable." >&2
            exit 1
        fi
    fi
}
check_writable "${SIZE_FILE}"

log() {
    local severity=$1
    local payload=$2
    local log_line="severity=${severity} ${payload}"
    if [ "$severity" == "warning" ] || [ "$severity" == "error" ]; then
        # for warnings and errors, send the log message to both:
        # the pod log (file descriptor 1 of pid 1)...
        echo "${log_line}"> /proc/1/fd/1
        # ...and the liveness probe failure message (STDERR)
        echo "${log_line}" >&2
    else
        # all other log levels just go to STDOUT
        echo "${log_line}"
    fi
}

current_size=$(curl -s -H 'Origin: http://localhost' "$URL" | grep -o -e '"QueueSize":[0-9]*' | cut -d: -f2)

# update state and exit early if there is no previous value to compare with
if [ ! -e "$SIZE_FILE" ]; then
    log info "queue=\"${QUEUE}\" msg=\"no previous size recorded, current size will be recorded\" elapsed=\"n/a\" last_size=\"n/a\" current_size=\"${current_size}\""
    # only when it is changed do we update the size file (to preserve the timestamp of the change)
    echo "$current_size" > "$SIZE_FILE"
    exit 0
fi

last_size=$(cat "$SIZE_FILE")
now=$(date +'%s')
last_change=$(stat -c'%Y' "$SIZE_FILE")
elapsed=$((now - last_change))

# exit early when the queue is empty
if (( current_size == 0 )); then
    log info "queue=\"${QUEUE}\" msg=\"queue is empty\" elapsed=\"${elapsed}\" last_size=\"${last_size}\" current_size=\"${current_size}\""
    exit 0
fi

# update state and exit early when the queue size is changing
if (( current_size != last_size )); then
    log info "queue=\"${QUEUE}\" msg=\"queue is changing, an updated size will be recorded\" elapsed=\"${elapsed}\" last_size=\"${last_size}\" current_size=\"${current_size}\""
    # only when it is changed do we update the size file (to preserve the timestamp of the change)
    echo "$current_size" > "$SIZE_FILE"
    exit 0
fi

# size remaining at a non-zero value longer than $THRESHOLD is NOT okay
if (( elapsed > THRESHOLD )); then
    log error "queue=\"${QUEUE}\" msg=\"queue has been stuck for greater than threshold ${THRESHOLD} seconds\" elapsed=\"${elapsed}\" last_size=\"${last_size:-n/a}\" current_size=\"${current_size}\""
    exit 1
fi

# if we get here, the queue is not changing but it hasn't exceeded the threshold yet
log warning "queue=\"${QUEUE}\" msg=\"queue is not changing, but threshold of ${THRESHOLD} seconds has not yet been exceeded\" elapsed=\"${elapsed}\" last_size=\"${last_size:-n/a}\" current_size=\"${current_size}\""
