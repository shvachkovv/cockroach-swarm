#!/bin/bash

set -eu

if [ "${1-}" = "shell" ]; then
  shift
  exec /bin/sh "$@"
else
  OWN_IP=$(cat /etc/hostname | xargs getent ahostsv4 | awk 'NR==1{print $1}')
  PCOUNT=$(nslookup tasks.${SNAME} | grep Address | wc -l)
  if [ $PCOUNT -lt 2 ]; then
    # Initialize the cluster
    exec /cockroach/cockroach "$@" --advertise-addr=${OWN_IP} --listen-addr=${OWN_IP}
  else
    # Join existing cluster
    LIST=$(nslookup tasks.cockroach | awk '/Address/ && !/#53/ && !/'${OWN_IP}'/ {print $2}' | sed -e :a -e '$!N; s/\n/,/; ta')
    exec /cockroach/cockroach "$@" --join=${LIST} --advertise-addr=${OWN_IP}
  fi
fi