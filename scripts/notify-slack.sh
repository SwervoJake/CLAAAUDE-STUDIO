#!/usr/bin/env bash
# ManyMoons Studio — Claude Code hook notification script
# Called by .claude/settings.json hooks on Stop and Notification events.
#
# Setup: Set SLACK_WEBHOOK_URL below after creating an incoming webhook in Slack:
#   Slack → Your workspace → Apps → Incoming Webhooks → Add New Webhook → #studio-agents
#
# Or set it as an env var: export SLACK_WEBHOOK_URL="https://hooks.slack.com/..."

SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

EVENT="${1:-unknown}"     # "stop" or "notification"
TITLE="${2:-Blueprint}"
BODY="${3:-Session event}"

# Only send if webhook is configured
if [ -z "$SLACK_WEBHOOK_URL" ]; then
  # Fall back to desktop notification if available
  if command -v notify-send &>/dev/null; then
    notify-send "ManyMoons — $TITLE" "$BODY"
  fi
  exit 0
fi

# Build payload
PAYLOAD=$(cat <<EOF
{
  "text": "*[ManyMoons / $EVENT]* $TITLE",
  "attachments": [
    {
      "color": "#4A90D9",
      "text": "$BODY"
    }
  ]
}
EOF
)

curl -s -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  > /dev/null 2>&1

exit 0
