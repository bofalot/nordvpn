#!/bin/bash

[[ -z "$PRIMARY" ]] && PRIMARY=p2p
[[ -z "$SECONDARY" ]] && SECONDARY=uk

function check {
  [[ $( curl -m 10 -s https://api.nordvpn.com/vpn/check | jq -r '.["status"]' ) == "Protected" ]]
}

function disconnect {
  nordvpn d
}

function connect {
  nordvpn c $1
}

function checkAndConnect {
  check
  CONNECTED=$?
  if [[ CONNECTED -eq 0 ]]
  then
    exit 0
  else
    disconnect
    connect $1
  fi
}

checkAndConnect "$PRIMARY"
checkAndConnect "$SECONDARY"

check
CONNECTED=$?
if [[ CONNECTED -eq 0 ]]
then
  exit 0
else
  echo "Failed to connect to both $PRIMARY and $SECONDARY servers" >&2
  exit 1
fi
