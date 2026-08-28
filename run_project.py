import platform
import shutil
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

PORT = 2020
SERVER_URL = f"http://localhost:{PORT}"

# The script's own directory is treated as the project root.
# This avoids hard-coded user-specific paths.
PROJECT_ROOT = Path(__file__).resolve().parent
PACKAGE_JSON = PROJECT_ROOT / "package.json"


# ---------------------------------------------------------
# Output helpers
# ---------------------------------------------------------

def print_header() -> None:
    print("=" * 65)
    print("        Twenty CRM Local Setup Automation")
    print("=" * 65)


def print_status(message: str) -> None:
    print(f"\n[INFO] {message}")


def print_success(message: str) -> None:
    print(f"[SUCCESS] {message}")


def print_warning(message: str) -> None:
    print(f"[WARNING] {message}")


def print_error(message: str) -> None:
    print(f"[ERROR] {message}")


# ---------------------------------------------------------
# Command handling
# ---------------------------------------------------------

def get_command(command: str) -> str | None:
    """
    Find a command in PATH.

    On Windows, commands such as Yarn and npm may be exposed
    through .cmd launchers, so check those first.
    """

    if platform.system() == "Windows":
        windows_command = shutil.which(f"{command}.cmd")

        if windows_command:
            return windows_command

    return shutil.which(command)


def require_command(command: str) -> str:
    """
    Check whether a required command is available.
    Exit immediately if it is missing.
    """

    executable = get_command(command)

    if executable is None:
        print_error(
            f"{command} is not installed or is not available in PATH."
        )
        sys.exit(1)

    print_success(f"{command} is available.")
    return executable


# ---------------------------------------------------------
# Command execution
# ---------------------------------------------------------

def run_command(
    command: list[str],
    description: str,
) -> None:
    """
    Execute a command from the project root.

    Stops the script if the command fails.
    """

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
            f"{description} failed with exit code "
            f"{error.returncode}."
        )
        sys.exit(error.returncode)

    except FileNotFoundError:
        print_error(
            f"Command not found: {command[0]}"
        )
        sys.exit(1)


# ---------------------------------------------------------
# Version handling
# ---------------------------------------------------------

def get_version(command: str) -> str:
    """
    Return the installed version of a command.
    """

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

        output = (
            result.stdout.strip()
            or result.stderr.strip()
        )

        return output or "Version unavailable"

    except (
        subprocess.CalledProcessError,
        OSError,
    ):
        return "Unable to determine version"


# ---------------------------------------------------------
# Project validation
# ---------------------------------------------------------

def verify_project_root() -> None:
    """
    Verify that the script is running from the expected
    project root.
    """

    print_status("Checking project directory...")

    if not PACKAGE_JSON.exists():
        print_error("package.json was not found.")
        print_error(
            "Please run this script from the project root."
        )
        sys.exit(1)

    print_success(
        f"Project root verified: {PROJECT_ROOT}"
    )


# ---------------------------------------------------------
# Port handling
# ---------------------------------------------------------

def is_port_in_use(port: int) -> bool:
    """
    Check whether a TCP port is already occupied.
    """

    with socket.socket(
        socket.AF_INET,
        socket.SOCK_STREAM,
    ) as sock:
        sock.settimeout(1)
        return sock.connect_ex(
            ("127.0.0.1", port)
        ) == 0


# ---------------------------------------------------------
# Server health check
# ---------------------------------------------------------

def wait_for_server(
    url: str,
    retries: int = 15,
    delay: int = 2,
) -> bool:
    """
    Wait for the application server to become reachable.
    """

    for attempt in range(1, retries + 1):

        try:
            with urllib.request.urlopen(
                url,
                timeout=3,
            ) as response:

                # Any HTTP response means the server is alive.
                if 200 <= response.status < 500:
                    return True

        except urllib.error.HTTPError:
            # HTTP error still proves the server is reachable.
            return True

        except (
            urllib.error.URLError,
            TimeoutError,
            OSError,
        ):
            print(
                f"[INFO] Waiting for server... "
                f"attempt {attempt}/{retries}"
            )

            if attempt < retries:
                time.sleep(delay)

    return False


# ---------------------------------------------------------
# Docker engine check
# ---------------------------------------------------------

def check_docker_engine(
    docker_command: str,
) -> None:
    """
    Verify that Docker CLI is available and the Docker
    engine is actually running.
    """

    print_status("Checking Docker engine...")

    try:
        subprocess.run(
            [docker_command, "info"],
            cwd=PROJECT_ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True,
        )

        print_success("Docker engine is running.")

    except subprocess.CalledProcessError:
        print_error("Docker engine is not running.")
        print_error(
            "Please start Docker Desktop and run the script again."
        )
        sys.exit(1)


# ---------------------------------------------------------
# Start Twenty server
# ---------------------------------------------------------

def start_twenty_server(
    yarn_command: str,
) -> None:
    """
    Start the local Twenty server if port 2020 is free.
    """

    print_status(
        f"Checking whether port {PORT} is available..."
    )

    if is_port_in_use(PORT):

        print_warning(
            f"Port {PORT} is already in use."
        )

        print_status(
            "Checking whether the existing server responds..."
        )

        if wait_for_server(SERVER_URL):
            print_success(
                f"Existing Twenty server is responding at "
                f"{SERVER_URL}"
            )
            return

        print_error(
            f"Port {PORT} is occupied, but the Twenty server "
            "is not responding."
        )
        print_error(
            "Stop the process using the port and run the script again."
        )
        sys.exit(1)

    print_success(
        f"Port {PORT} is available."
    )

    print_status(
        "Starting the local Twenty server..."
    )

    try:
        # This command starts the Docker-based local Twenty server.
        process = subprocess.Popen(
            [
                yarn_command,
                "twenty",
                "docker:start",
            ],
            cwd=PROJECT_ROOT,
        )

        # Give the startup process some time to initialize.
        time.sleep(3)

        # If the command terminates immediately with an error,
        # report the failure.
        if process.poll() is not None:
            if process.returncode != 0:
                print_error(
                    "Twenty server failed to start."
                )
                sys.exit(process.returncode)

        print_success(
            "Twenty server start command initiated."
        )

    except FileNotFoundError:
        print_error(
            "Unable to execute the Twenty server start command."
        )
        sys.exit(1)


# ---------------------------------------------------------
# Main workflow
# ---------------------------------------------------------

def main() -> None:

    print_header()

    # -----------------------------------------------------
    # 1. Verify project root
    # -----------------------------------------------------

    verify_project_root()

    # -----------------------------------------------------
    # 2. Check required tools
    # -----------------------------------------------------

    print_status("Checking required tools...")

    node = require_command("node")
    yarn = require_command("yarn")
    docker = require_command("docker")

    # -----------------------------------------------------
    # 3. Display dependency versions
    # -----------------------------------------------------

    print_status("Checking dependency versions...")

    print(
        f"Node.js : {get_version('node')}"
    )

    print(
        f"Yarn    : {get_version('yarn')}"
    )

    print(
        f"Docker  : {get_version('docker')}"
    )

    # Keep variables intentionally referenced so the
    # command paths remain explicit in this workflow.
    _ = node

    # -----------------------------------------------------
    # 4. Install project dependencies
    # -----------------------------------------------------

    run_command(
        [
            yarn,
            "install",
        ],
        "Installing project dependencies",
    )

    # -----------------------------------------------------
    # 5. Check Docker engine
    # -----------------------------------------------------

    check_docker_engine(docker)

    # -----------------------------------------------------
    # 6. Start Twenty server
    # -----------------------------------------------------

    start_twenty_server(yarn)

    # -----------------------------------------------------
    # 7. Health check
    # -----------------------------------------------------

    print_status(
        f"Checking application health at {SERVER_URL}..."
    )

    if wait_for_server(SERVER_URL):
        print_success(
            f"Twenty server is healthy at {SERVER_URL}"
        )
    else:
        print_error(
            "Twenty server did not become healthy within "
            "the expected time."
        )
        sys.exit(1)

    # -----------------------------------------------------
    # 8. Display local URL
    # -----------------------------------------------------

    print("\n" + "=" * 65)
    print_success(
        "Local Twenty server setup completed successfully."
    )
    print(f"Application URL: {SERVER_URL}")
    print("=" * 65)

    # -----------------------------------------------------
    # 9. Start application development/synchronization
    # -----------------------------------------------------

    print_status(
        "Starting Twenty application development sync..."
    )

    try:
        subprocess.run(
            [
                yarn,
                "twenty",
                "dev",
            ],
            cwd=PROJECT_ROOT,
            check=True,
        )

    except KeyboardInterrupt:
        print()
        print_status(
            "Development process stopped by the user."
        )

    except subprocess.CalledProcessError as error:
        print_error(
            "Application development sync failed with "
            f"exit code {error.returncode}."
        )
        sys.exit(error.returncode)


# ---------------------------------------------------------
# Entry point
# ---------------------------------------------------------

if __name__ == "__main__":
    main()