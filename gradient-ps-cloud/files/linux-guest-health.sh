#!/usr/bin/env bash

# This plugin checks the results of the ps-guest-health daemon

readonly OK=0
readonly NONOK=1
readonly UNKNOWN=2

readonly GUEST_OUTPUT="$1"
readonly CHECK="$2"

uptime_seconds=$(uptime | awk -F' ' '{print $3}' | awk -F':' '{print $1*3600 + $2*60}')

if [ ! -f "$GUEST_OUTPUT" ]; then
  if [ "$uptime_seconds" -gt 300 ]; then
    echo "Guest health output not found and uptime > 5 minutes"
    exit $NONOK
  else
    echo "Still waiting for initial guest health output"
    exit $UNKNOWN
  fi
fi

# update interval is 60 minutes on the health reporter
if find "$GUEST_OUTPUT" -mmin -61 | read -r; then
  echo "Guest health output too old"
  exit $NONOK
fi

error=$(jq -r "try .errors.\"$CHECK\" | join(\",\")" "$GUEST_OUTPUT")
if [ -n "$error" ]; then
  echo "$error"
  exit $NONOK
else
  echo "$CHECK reported no errors"
  exit $OK
fi
