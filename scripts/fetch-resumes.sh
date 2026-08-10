#!/bin/bash
# Fetch BOSS直聘 resume emails from join@kig.land mailbox
# Usage: ./fetch-resumes.sh [--days 3] [--max 50]

DAYS=3
MAX=50
MAILBOX="join@kig.land"

while [[ $# -gt 0 ]]; do
  case $1 in
    --days) DAYS="$2"; shift 2 ;;
    --max) MAX="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

START_DATE=$(date -v-${DAYS}d +%Y-%m-%dT00:00:00+08:00 2>/dev/null || date -d "${DAYS} days ago" +%Y-%m-%dT00:00:00+08:00)

echo "Fetching resumes from last ${DAYS} days..."

lark-cli mail +triage \
  --mailbox "$MAILBOX" \
  --filter "{\"folder\":\"inbox\",\"from\":[\"cv@service.bosszhipin.com\"],\"time_range\":{\"start_time\":\"${START_DATE}\"}}" \
  --max "$MAX" \
  --format json
