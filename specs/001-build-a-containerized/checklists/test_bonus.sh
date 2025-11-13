#!/bin/bash

echo "=========================================="
echo "INCEPTION BONUS SERVICES SHOWCASE"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source environment variables
if [ -f "srcs/.env" ]; then
    export $(grep -v '^#' srcs/.env | xargs)
elif [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "ERROR: .env file not found"
    exit 1
fi

# 1. Redis
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. REDIS - Object Cache"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
REDIS_KEYS=$(docker exec redis redis-cli -a "$REDIS_PASSWORD" DBSIZE 2>/dev/null | grep -v Warning)
REDIS_PING=$(docker exec redis redis-cli -a "$REDIS_PASSWORD" PING 2>/dev/null | grep -v Warning)

if [ "$REDIS_PING" = "PONG" ]; then
    echo -e "${GREEN}✓${NC} Redis is running and authenticated"
    echo "   Cached keys: $REDIS_KEYS"
    echo "   Access: docker exec -it redis redis-cli -a \$REDIS_PASSWORD"
else
    echo -e "${RED}✗${NC} Redis authentication failed"
fi
echo ""

# 2. FTP
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. FTP SERVER - File Transfer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
FTP_STATUS=$(docker exec ftp ps aux | grep vsftpd | grep -v grep | wc -l)
if [ "$FTP_STATUS" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} FTP service is running"
    echo "   Port: 21"
    echo "   Passive ports: 21000-21010"
    echo "   Connect: ftp localhost (user: $FTP_USER)"
    
    # Test FTP connection
    if command -v nc &> /dev/null; then
        if nc -zv localhost 21 2>&1 | grep -q succeeded; then
            echo -e "${GREEN}✓${NC} Port 21 is accessible"
        fi
    fi
else
    echo -e "${RED}✗${NC} FTP service not running"
fi
echo ""

# 3. Adminer
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. ADMINER - Database Management"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ADMINER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081)
if [ "$ADMINER_STATUS" = "200" ]; then
    echo -e "${GREEN}✓${NC} Adminer is accessible"
    echo "   URL: http://localhost:8081"
    echo "   Server: mariadb"
    echo "   User: $MYSQL_USER"
    echo "   Database: $MYSQL_DATABASE"
else
    echo -e "${RED}✗${NC} Adminer not responding (HTTP $ADMINER_STATUS)"
fi
echo ""

# 4. Static Site
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. STATIC WEBSITE - Non-PHP Site"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
STATIC_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$STATIC_STATUS" = "200" ]; then
    echo -e "${GREEN}✓${NC} Static website is accessible"
    echo "   URL: http://localhost:8080"
    STATIC_TITLE=$(curl -s http://localhost:8080 | grep -o '<title>[^<]*</title>' | sed 's/<[^>]*>//g')
    if [ -n "$STATIC_TITLE" ]; then
        echo "   Page title: $STATIC_TITLE"
    fi
else
    echo -e "${RED}✗${NC} Static site not responding (HTTP $STATIC_STATUS)"
fi
echo ""

# 5. Portainer
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. PORTAINER - Container Management"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PORTAINER_API=$(curl -s http://localhost:9000/api/status 2>/dev/null)
PORTAINER_VERSION=$(echo "$PORTAINER_API" | grep -o '"Version":"[^"]*"' | cut -d'"' -f4)
PORTAINER_ID=$(echo "$PORTAINER_API" | grep -o '"InstanceID":"[^"]*"' | cut -d'"' -f4)

if [ -n "$PORTAINER_VERSION" ]; then
    echo -e "${GREEN}✓${NC} Portainer is running"
    echo "   URL: http://localhost:9000"
    echo "   Version: $PORTAINER_VERSION"
    echo "   Instance ID: ${PORTAINER_ID:0:8}..."
    echo "   Manages: Docker containers, images, volumes, networks"
else
    echo -e "${RED}✗${NC} Portainer not responding"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUMMARY - All Bonus Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL=5
WORKING=0

if [ "$REDIS_PING" = "PONG" ]; then ((WORKING++)); echo -e "${GREEN}✓${NC} Redis"; else echo -e "${RED}✗${NC} Redis"; fi
if [ "$FTP_STATUS" -gt 0 ]; then ((WORKING++)); echo -e "${GREEN}✓${NC} FTP"; else echo -e "${RED}✗${NC} FTP"; fi
if [ "$ADMINER_STATUS" = "200" ]; then ((WORKING++)); echo -e "${GREEN}✓${NC} Adminer"; else echo -e "${RED}✗${NC} Adminer"; fi
if [ "$STATIC_STATUS" = "200" ]; then ((WORKING++)); echo -e "${GREEN}✓${NC} Static Site"; else echo -e "${RED}✗${NC} Static Site"; fi
if [ -n "$PORTAINER_VERSION" ]; then ((WORKING++)); echo -e "${GREEN}✓${NC} Portainer"; else echo -e "${RED}✗${NC} Portainer"; fi

echo ""
echo "Status: $WORKING/$TOTAL bonus services operational"
echo ""

if [ "$WORKING" -eq "$TOTAL" ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}   ALL BONUS SERVICES ARE WORKING! ✓${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}   Some services need attention${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

echo ""
echo "Quick Access Commands:"
echo "  Redis CLI:     docker exec -it redis redis-cli -a \$REDIS_PASSWORD"
echo "  FTP Connect:   ftp localhost"
echo "  Adminer:       firefox http://localhost:8081"
echo "  Static Site:   firefox http://localhost:8080"
echo "  Portainer:     firefox http://localhost:9000"
echo ""
