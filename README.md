# pihole

# Pi-hole Network Inventory

Pi-hole Network Inventory is a Bash script that extracts historical device information directly from the Pi-hole FTL database.

The script generates easy-to-read reports showing:

* Hostnames discovered by Pi-hole
* Current and historical IP addresses
* MAC addresses
* Device manufacturers (vendor lookup from Pi-hole)
* Days since a device was last seen
* Device grouping by MAC address
* Device grouping by hostname
* Support for multiple subnets and changing IP addresses

This provides a historical view of devices that have appeared on your network, including systems that may no longer be online.

## Requirements

* Pi-hole v6 (or compatible FTL database schema)
* Bash
* SQLite access through `pihole-FTL sqlite3`
* `column`, `sort`, `awk`, and standard GNU utilities

## Usage

```bash
chmod +x pihole-network-inventory.sh
./pihole-network-inventory.sh
```

The script reads data directly from `/etc/pihole/pihole-FTL.db` and does not modify the database.

## Quick Install

Download the latest version directly from GitHub, make it executable, and run it:

```bash
curl -O https://raw.githubusercontent.com/my-digital-life/pihole/main/pihole-census.sh
chmod +x pihole-census.sh
./pihole-census.sh
```

Or as a one-liner:

```bash
curl -O https://raw.githubusercontent.com/my-digital-life/pihole/main/pihole-census.sh && chmod +x pihole-census.sh && ./pihole-census.sh
```

> **Note:** This script must be run on a Pi-hole system and requires access to the Pi-hole FTL database (`/etc/pihole/pihole-FTL.db`).

```
```
