#!/bin/sh
# T032: Performance test for WordPress with/without Redis
#!/bin/sh
# T040: Performance test for WordPress
set -e
URL="https://localhost"
echo "Running performance test on $URL..."
# Use curl to measure response time (ab is not always available)
RESULT=$(curl -k -o /dev/null -s -w "%{time_total}" "$URL")
echo "WordPress homepage response time: $RESULT seconds"
MAX_TIME=2.0
if awk "BEGIN {exit !($RESULT < $MAX_TIME)}"; then
	echo "Performance test passed: response time < $MAX_TIME s"
	exit 0
else
	echo "Performance test failed: response time >= $MAX_TIME s"
	exit 1
fi
