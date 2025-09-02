# whk - Webhook Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A professional Linux CLI tool for managing webhooks with advanced features.

## Description

`whk` is a command-line interface tool designed for Linux systems that simplifies the management of webhooks. It allows developers and system administrators to create, list, delete, and trigger webhooks directly from the terminal. With features like scheduling, custom payloads, and detailed logging, `whk` is a powerful tool for automating HTTP callbacks in development and production environments.

## Key Features

- Create, list, delete, and trigger webhooks from the command line
- Store webhooks in a local file (`~/.whk/webhooks`) in `name|url` format
- Support optional custom JSON payloads for webhook triggers
- Trigger multiple webhooks at once
- Support optional headers per webhook
- Comprehensive logging with timestamps (`~/.whk/logs/whk.log`)
- Schedule webhook triggers using cron
- Validate webhook URLs before saving
- Dry-run mode to simulate triggers without sending requests
- Fully interactive CLI with clear prompts and error handling

## Technologies Used

- Bash (primary implementation language)
- curl (for sending HTTP requests)
- Standard Linux tools (awk, grep, sed)

## Installation

```bash
# Clone the repository
git clone https://github.com/AR-92/whk.git
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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some feature'`)
5. Push to the branch (`git push origin feature/your-feature-name`)
6. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

- GitHub: [AR-92](https://github.com/AR-92)