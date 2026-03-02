#!/usr/bin/env bash
set -euo pipefail

# Pingward MCP Skill Installer
# Adds Pingward MCP server configuration to your project

MCP_URL="https://mcp.pingward.com/mcp"
MCP_FILE=".mcp.json"

echo "Pingward MCP Skill Installer"
echo "============================"
echo ""

# Check for existing .mcp.json
if [ -f "$MCP_FILE" ]; then
    # Check if pingward is already configured
    if grep -q '"pingward"' "$MCP_FILE" 2>/dev/null; then
        echo "Pingward is already configured in $MCP_FILE"
        exit 0
    fi

    echo "Found existing $MCP_FILE — adding Pingward server..."

    # Use python/node to merge JSON if available, otherwise instruct manual setup
    if command -v python3 &>/dev/null; then
        python3 -c "
import json, sys
with open('$MCP_FILE', 'r') as f:
    config = json.load(f)
if 'mcpServers' not in config:
    config['mcpServers'] = {}
config['mcpServers']['pingward'] = {
    'type': 'url',
    'url': '$MCP_URL',
    'headers': {'X-Api-Key': '\${PINGWARD_API_KEY}'}
}
with open('$MCP_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
"
        echo "Added Pingward to existing $MCP_FILE"
    elif command -v node &>/dev/null; then
        node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('$MCP_FILE', 'utf8'));
if (!config.mcpServers) config.mcpServers = {};
config.mcpServers.pingward = {
    type: 'url',
    url: '$MCP_URL',
    headers: {'X-Api-Key': '\${PINGWARD_API_KEY}'}
};
fs.writeFileSync('$MCP_FILE', JSON.stringify(config, null, 2) + '\n');
"
        echo "Added Pingward to existing $MCP_FILE"
    else
        echo "Cannot auto-merge JSON (no python3 or node found)."
        echo "Please add the following to your $MCP_FILE manually:"
        echo ""
        echo '  "pingward": {'
        echo '    "type": "url",'
        echo "    \"url\": \"$MCP_URL\","
        echo '    "headers": { "X-Api-Key": "${PINGWARD_API_KEY}" }'
        echo '  }'
        exit 1
    fi
else
    echo "Creating $MCP_FILE..."
    cat > "$MCP_FILE" << 'EOF'
{
  "mcpServers": {
    "pingward": {
      "type": "url",
      "url": "https://mcp.pingward.com/mcp",
      "headers": {
        "X-Api-Key": "${PINGWARD_API_KEY}"
      }
    }
  }
}
EOF
    echo "Created $MCP_FILE"
fi

echo ""
echo "Next steps:"
echo "  1. Set your API key:  export PINGWARD_API_KEY=\"aw_your_key_here\""
echo "  2. Get a key at:      https://pingward.com/settings?tab=api-keys"
echo "  3. Or register via:   curl -X POST https://api.pingward.com/api/auth/register"
echo ""
echo "Done!"
