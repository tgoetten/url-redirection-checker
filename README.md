# URL Redirection Checker

This Bash script checks the redirection of a given URL and provides information about the final URL, HTTP status code, and the server.

## Usage

```bash
./redirect_checker.sh <url> [username] [password]
```

- `<url>`: The URL to check for redirection.
- `[username]`: (Optional) Username for basic authentication.
- `[password]`: (Optional) Password for basic authentication.

If the username and password are provided, the script uses them for Basic Authentication.

## Features

- Supports basic authentication.
- Displays information about redirection, HTTP code, and server.
- Handles up to 10 redirects.

## Example

```bash
./redirect_checker.sh https://example.com
```

or

```bash
./redirect_checker.sh https://example.com your_username your_password
```

## Notes

- The script uses the `curl` command for making HTTP requests.
- Make sure to replace "your_username" and "your_password" with your actual credentials.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
