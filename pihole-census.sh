#!/bin/bash

DAYS=360
DB="/etc/pihole/pihole-FTL.db"

echo
echo "=== DEVICES SEEN IN LAST $DAYS DAYS (GROUPED BY MAC) ==="
echo

(
sudo pihole-FTL sqlite3 -separator '|' "$DB" "
SELECT
    COALESCE(MAX(NULLIF(na.name,'')),'Unknown') AS hostname,
    n.hwaddr,
    COALESCE(NULLIF(n.macVendor,''),'Unknown') AS vendor,
    MAX(na.lastSeen) AS lastseen
FROM network n
JOIN network_addresses na
    ON n.id = na.network_id
WHERE na.lastSeen > strftime('%s','now') - ($DAYS * 86400)
  AND na.ip GLOB '[0-9]*.[0-9]*.[0-9]*.[0-9]*'
  AND na.ip NOT LIKE '127.%'
GROUP BY n.hwaddr;
" | while IFS='|' read -r HOST MAC VENDOR LASTSEEN
do

    IPS=$(
        sudo pihole-FTL sqlite3 "$DB" "
        SELECT DISTINCT na.ip
        FROM network_addresses na
        JOIN network n
            ON n.id=na.network_id
        WHERE n.hwaddr='$MAC'
          AND na.ip GLOB '[0-9]*.[0-9]*.[0-9]*.[0-9]*'
          AND na.ip NOT LIKE '127.%'
        " | sort -V | paste -sd ',' -
    )

    LOWEST_IP=$(echo "$IPS" | tr ',' '\n' | sort -V | head -1)

    SORTKEY=$(echo "$LOWEST_IP" | awk -F. '
    {
        printf "%03d%03d%03d%03d\n",$1,$2,$3,$4
    }')

    DAYSAGO=$(awk -v now="$(date +%s)" -v last="$LASTSEEN" '
    BEGIN {
        printf "%.1f",(now-last)/86400
    }')

    echo "$SORTKEY|$HOST|$IPS|$MAC|$VENDOR|$DAYSAGO"

done | sort -t'|' -k1,1n | cut -d'|' -f2-
) | (
echo "Hostname|IPs|MAC|Vendor|DaysAgo"
cat
) | column -t -s '|'

echo
echo "=== HOSTNAMES SEEN IN LAST $DAYS DAYS (GROUPED BY HOSTNAME) ==="
echo

(
sudo pihole-FTL sqlite3 "$DB" "
SELECT DISTINCT
    COALESCE(NULLIF(name,''),'Unknown')
FROM network_addresses
WHERE ip GLOB '[0-9]*.[0-9]*.[0-9]*.[0-9]*'
  AND ip NOT LIKE '127.%'
" | sort -f | while read -r HOST
do

    IPS=$(
        sudo pihole-FTL sqlite3 "$DB" "
        SELECT DISTINCT ip
        FROM network_addresses
        WHERE COALESCE(NULLIF(name,''),'Unknown')='$HOST'
          AND ip GLOB '[0-9]*.[0-9]*.[0-9]*.[0-9]*'
          AND ip NOT LIKE '127.%'
        " | sort -V | paste -sd ',' -
    )

    MACS=$(
        sudo pihole-FTL sqlite3 "$DB" "
        SELECT DISTINCT n.hwaddr
        FROM network n
        JOIN network_addresses na
            ON n.id = na.network_id
        WHERE COALESCE(NULLIF(na.name,''),'Unknown')='$HOST'
        " | sort | paste -sd ',' -
    )

    echo "$HOST|$IPS|$MACS"

done
) | (
echo "Hostname|IPs Seen|MACs Seen"
cat
) | column -t -s '|'
