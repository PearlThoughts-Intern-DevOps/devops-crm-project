import platform
import shutil
import socket
import subprocess
import sys
import time
import urllib.request
from pathlib import Path


PORT = 2020
PROJECT_ROOT = Path(__file__).resolve().parent
PACKAGE_JSON = PROJECT_ROOT / "package.json"


def print_status(message: str) -> None:
    print(f"\n[INFO] {message}")


def print_success(message: str) -> None:
    print(f"[SUCCESS] {message}")


def print_error(message: str) -> None:
    print(f"[ERROR] {message}")


def get_command(command: str) -> str | None:
    """
    Resolve a command in a cross-platform way.

    On Windows, package-manager commands such as Yarn may be
    available through a .cmd launcher.
    """
    if platform.system() == "Windows":
        windows_command = shutil.which(f"{command}.cmd")
        if windows_command:
            return windows_command

    return shutil.which(command)


def require_command(command: str) -> str:
    executable = get_command(command)

    if executable is None:
        print_error(f"{command} is not installed or not available in PATH.")
        sys.exit(1)

    print_success(f"{command} is available.")
    return executable


def run_command(
    command: list[str],
    description: str,
) -> None:
    print_status(description)

    try:
        subprocess.run(
            command,
            cwd=PROJECT_ROOT,
            check=True,
        )
        print_success(f"{description} completed.")

    except subprocess.CalledProcessError as error:
        print_error(
            f"{description} failed with exit code {error.returncode}."
        )
        sys.exit(error.returncode)

    except FileNotFoundError:
        print_error(f"Command not found: {command[0]}")
        sys.exit(1)


def get_version(command: str) -> str:
    executable = get_command(command)

    if executable is None:
        return "Not installed"

    try:
        result = subprocess.run(
            [executable, "--version"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=True,
        )

        output = (result.stdout or result.stderr).strip()
        return output or "Version unavailable"

    except (subprocess.CalledProcessError, OSError):
        return "Unable to determine version"


def is_port_in_use(port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        return sock.connect_ex(("127.0.0.1", port)) == 0


def wait_for_server(
    url: str,
    retries: int = 15,
    delay: int = 2,
) -> bool:
    for attempt in range(1, retries + 1):
        try:
            with urllib.request.urlopen(url, timeout=3) as response:
                if 200 <= response.status < 500:
                    return True

        except Exception:
            print(
                f"[INFO] Waiting for server... "
                f"attempt {attempt}/{retries}"
            )
            time.sleep(delay)

    return False


def main() -> None:
    print("=" * 60)
    print("      Twenty CRM Local Setup Automation")
    print("=" * 60)

    # ---------------------------------------------------------
    # 1. Verify project directory
    # ---------------------------------------------------------

    print_status("Checking project directory...")

    if not PACKAGE_JSON.exists():
        print_error("package.json was not found.")
        print_error(
            "Please run this script from the Twenty app project root."
        )
        sys.exit(1)

    print_success(f"Project root verified: {PROJECT_ROOT}")

    # ---------------------------------------------------------
    # 2. Check required tools
    # ---------------------------------------------------------

    print_status("Checking required tools...")

    node = require_command("node")
    yarn = require_command("yarn")
    docker = require_command("docker")

    # ---------------------------------------------------------
    # 3. Display dependency versions
    # ---------------------------------------------------------

    print_status("Checking dependency versions...")

    print(f"Node.js : {get_version('node')}")
    print(f"Yarn    : {get_version('yarn')}")
    print(f"Docker  : {get_version('docker')}")

    # ---------------------------------------------------------
    # 4. Install dependencies
    # ---------------------------------------------------------

    run_command(
        [yarn, "install"],
        "Installing project dependencies",
    )

    # ---------------------------------------------------------
    # 5. Check Docker engine
    # ---------------------------------------------------------

    print_status("Checking Docker engine...")

    try:
        subprocess.run(
            [docker, "info"],
            cwd=PROJECT_ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True,
        )

        print_success("Docker engine is running.")

    except subprocess.CalledProcessError:
        print_error("Docker engine is not running.")
        print_error("Please start Docker Desktop and run the script again.")
        sys.exit(1)

    # ---------------------------------------------------------
    # 6. Start local Twenty server
    # ---------------------------------------------------------

    server_url = f"http://localhost:{PORT}"

    if is_port_in_use(PORT):
        print_success(f"Port {PORT} is already in use.")

        if wait_for_server(server_url):
            print_success("Existing Twenty server is responding.")

        else:
            print_error(
                f"Port {PORT} is occupied, but the Twenty server "
                "is not responding."
            )
            sys.exit(1)

    else:
        print_status("Starting local Twenty server...")

        try:
            subprocess.run(
                [yarn, "twenty", "docker:start"],
                cwd=PROJECT_ROOT,
                check=True,
            )

            print_success("Twenty server start command completed.")

        except subprocess.CalledProcessError as error:
            print_error(
                "Failed to start Twenty server. "
                f"Exit code: {error.returncode}"
            )
            sys.exit(error.returncode)

    # ---------------------------------------------------------
    # 7. Health check
    # ---------------------------------------------------------

    print_status("Checking Twenty server health...")

    if wait_for_server(server_url):
        print_success(
            f"Twenty server is responding at {server_url}"
        )

    else:
        print_error(
            "Twenty server did not respond within the expected time."
        )
        sys.exit(1)

    # ---------------------------------------------------------
    # 8. Start application development sync
    # ---------------------------------------------------------

    print_status("Starting application development sync...")

    try:
        subprocess.run(
            [yarn, "twenty", "dev"],
            cwd=PROJECT_ROOT,
            check=True,
        )

    except KeyboardInterrupt:
        print("\n[INFO] Development process stopped by user.")

    except subprocess.CalledProcessError as error:
        print_error(
            "Application development command failed. "
            f"Exit code: {error.returncode}"
        )
        sys.exit(error.returncode)

    # ---------------------------------------------------------
    # 9. Final result
    # ---------------------------------------------------------

    print("\n" + "=" * 60)
    print_success("Local Twenty setup completed successfully.")
    print(f"Application URL: {server_url}")
    print("=" * 60)


if __name__ == "__main__":
    main()