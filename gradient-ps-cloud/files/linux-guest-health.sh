#!/usr/bin/env bash

# This plugin checks the results of the ps-guest-health daemon

readonly OK=0
readonly NONOK=1
readonly UNKNOWN=2

readonly GUEST_OUTPUT="$1"
readonly CHECK="$2"

if [ ! -f "$GUEST_OUTPUT" ]; then
  echo "No guest health output found"
  exit $UNKNOWN
fi

error=$(jq -r "try .errors.\"$CHECK\" | join(\",\")" "$GUEST_OUTPUT")
if [ -n "$error" ]; then
  echo "$error"
  exit $NONOK
else
  echo "$CHECK reported no errors"
  exit $OK
fi