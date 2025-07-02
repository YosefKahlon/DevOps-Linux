#!/bin/bash

VM_IP="$1"

if curl -s --connect-timeout 5 http://$VM_IP > /dev/null; then
  echo "Web app is accessible at $VM_IP"
else
  echo "Web app is not responding at $VM_IP"
fi