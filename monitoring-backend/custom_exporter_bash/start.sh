#!/bin/bash
echo "Starting custom bash exporter on port 9999"
while true; do
  PING_RESULT=$(ping -c 1 google.com | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
  if [ -z "$PING_RESULT" ]; then
    PING_RESULT=-1
  fi

  METRIC="custom_ping_latency_ms{host=\"google.com\"} $PING_RESULT"

  echo -e "HTTP/1.1 200 OK\nContent-Type: text/plain\n\n# HELP custom_ping_latency_ms Ping latency to a host.\n# TYPE custom_ping_latency_ms gauge\n$METRIC" | nc -l -p 9999 > /dev/null
done
