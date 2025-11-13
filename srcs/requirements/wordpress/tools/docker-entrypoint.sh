#!/bin/sh
set -e

# Run the setup script
/usr/local/bin/setup-wordpress.sh

# Start PHP-FPM
exec php-fpm7.4 -F
