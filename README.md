# whk - Webhook Manager

A professional Linux CLI tool for managing webhooks with advanced features.

## Features

- Create, list, delete, and trigger webhooks
- Store webhooks in a local file (`~/.whk/webhooks`) in `name|url` format
- Support optional custom JSON payloads for triggers
- Trigger multiple webhooks at once
- Support optional headers per webhook
- Log every action with timestamp into `~/.whk/logs/whk.log`
- Schedule webhook triggers using cron
- Validate webhook URLs before saving
- Dry-run mode to simulate triggers without sending requests
- Fully interactive CLI with clear prompts and error handling

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/whk.git
cd whk

# Install using make
make install
```

This will:
- Copy the `whk` executable to `/usr/local/bin/`
- Create the data directory at `~/.whk/`

## Usage

```bash
# Create a new webhook
whk create

# List all webhooks
whk list

# Delete a webhook
whk delete

# Trigger a webhook
whk trigger WEBHOOK_NAME

# Schedule a webhook trigger
whk schedule

# Dry run a webhook (simulate without sending request)
whk dry-run WEBHOOK_NAME

# Show help
whk help
```

## Commands

| Command   | Description                           |
|-----------|---------------------------------------|
| create    | Create a new webhook                  |
| list      | List all saved webhooks               |
| delete    | Delete a webhook by name              |
| trigger   | Trigger a webhook with optional JSON  |
| schedule  | Schedule a webhook using cron         |
| dry-run   | Simulate a trigger without sending    |
| help      | Display help page                     |

## Data Storage

Webhooks are stored in `~/.whk/webhooks` with the format:
```
name|url|headers
```

Logs are stored in `~/.whk/logs/whk.log`

## Testing

Run the test suite with:
```bash
make test
```

## Uninstallation

```bash
make uninstall
```

Note: This will not remove your data directory (`~/.whk/`).

## Requirements

- Bash
- curl
- Standard Linux tools (awk, grep, sed)

## License

MIT