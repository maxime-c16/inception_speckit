#!/bin/sh
# T050: Unit test for Makefile targets
set -e
MAKEFILE=../../Makefile
if ! grep -q '^up:' "$MAKEFILE"; then echo 'Missing up target'; exit 1; fi
if ! grep -q '^down:' "$MAKEFILE"; then echo 'Missing down target'; exit 1; fi
if ! grep -q '^test:' "$MAKEFILE"; then echo 'Missing test target'; exit 1; fi
if ! grep -q '^clean:' "$MAKEFILE"; then echo 'Missing clean target'; exit 1; fi
echo 'All required Makefile targets found.'
make -f "$MAKEFILE" --dry-run up | grep -q 'docker-compose up' || { echo 'up target does not call docker-compose up'; exit 1; }
echo 'Makefile unit tests passed.'
