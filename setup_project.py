#!/usr/bin/env python3
"""
setup_project.py

Automates the local setup and startup of the Twenty CRM app.

Usage:
    python3 setup_project.py

Run this script from inside the cloned devops-crm-project repository,
or execute it directly from the project root.
"""

import shutil
import socket
import subprocess
import sys
import time
from pathlib import Path


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PROJECT_DIR = Path(__file__).resolve().parent
NVMRC_FILE = PROJECT_DIR / ".nvmrc"
PACKAGE_JSON = PROJECT_DIR / "package.json"

TWENTY_HOST = "localhost"
TWENTY_PORT = 2020
SERVER_TIMEOUT = 60


# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------

def info(message: str) -> None:
    print(f"[INFO] {message}")


def success(message: str) -> None:
    print(f"[OK] {message}")


def warning(message: str) -> None:
    print(f"[WARN] {message}")


def fail(message: str) -> None:
    print(f"[ERROR] {message}")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Run commands
# ---------------------------------------------------------------------------

def run_command(
    command: list[str],
    *,
    live_output: bool = False,
    check: bool = True,
) -> subprocess.CompletedProcess:
    """
    Run a command inside the project directory.

    live_output=True is used for interactive commands such as
    `yarn twenty dev`.
    """

    print(f"\n$ {' '.join(command)}")

    if live_output:
        result = subprocess.run(
            command,
            cwd=PROJECT_DIR,
        )
    else:
        result = subprocess.run(
            command,
            cwd=PROJECT_DIR,
            capture_output=True,
            text=True,
        )

    if check and result.returncode != 0:
        if not live_output:
            if result.stdout:
                print(result.stdout)
            if result.stderr:
                print(result.stderr)

        fail(
            f"Command failed with exit code {result.returncode}: "
            f"{' '.join(command)}"
        )

    return result


# ---------------------------------------------------------------------------
# Step 1: Verify project directory
# ---------------------------------------------------------------------------

def verify_project_directory() -> None:
    info("Checking project directory...")

    if not PACKAGE_JSON.exists():
        fail(
            f"package.json was not found in {PROJECT_DIR}. "
            "Run this script from the devops-crm-project directory."
        )

    if not NVMRC_FILE.exists():
        fail(
            f".nvmrc was not found in {PROJECT_DIR}. "
            "Unable to determine the required Node.js version."
        )

    success(f"Project root confirmed: {PROJECT_DIR}")


# ---------------------------------------------------------------------------
# Step 2: Check required tools
# ---------------------------------------------------------------------------

def check_required_tools() -> None:
    info("Checking required tools...")

    required_tools = ["node", "yarn", "docker"]

    missing_tools = [
        tool for tool in required_tools
        if shutil.which(tool) is None
    ]

    if missing_tools:
        fail(
            "Missing required tools: "
            + ", ".join(missing_tools)
            + ". Please install them before running the script."
        )

    success("Node.js, Yarn, and Docker are installed.")


# ---------------------------------------------------------------------------
# Step 3: Check Node.js version
# ---------------------------------------------------------------------------

def check_node_version() -> None:
    required_version = NVMRC_FILE.read_text().strip()

    result = run_command(
        ["node", "--version"],
        check=False,
    )

    actual_version = result.stdout.strip()

    if result.returncode != 0:
        fail("Unable to determine the installed Node.js version.")

    actual_version = actual_version.lstrip("v")

    if actual_version != required_version:
        fail(
            f"Node.js version mismatch. "
            f"Project requires {required_version}, "
            f"but {actual_version} is currently active.\n"
            f"If you use NVM, run:\n"
            f"    nvm install\n"
            f"    nvm use"
        )

    success(f"Node.js version matches .nvmrc: {actual_version}")


# ---------------------------------------------------------------------------
# Step 4: Display versions
# ---------------------------------------------------------------------------

def show_versions() -> None:
    info("Environment versions:")

    commands = [
        ["node", "--version"],
        ["yarn", "--version"],
        ["docker", "--version"],
    ]

    for command in commands:
        result = run_command(command, check=False)

        output = result.stdout.strip() or result.stderr.strip()

        if result.returncode == 0:
            print(f"  {' '.join(command[:1])}: {output}")
        else:
            warning(f"Could not determine version for {' '.join(command)}")


# ---------------------------------------------------------------------------
# Step 5: Check Docker daemon
# ---------------------------------------------------------------------------

def check_docker_running() -> None:
    info("Checking Docker daemon...")

    result = run_command(
        ["docker", "info"],
        check=False,
    )

    if result.returncode != 0:
        fail(
            "Docker is installed but the Docker daemon is not running. "
            "Start Docker and run this script again."
        )

    success("Docker daemon is running.")


# ---------------------------------------------------------------------------
# Step 6: Install dependencies
# ---------------------------------------------------------------------------

def install_dependencies() -> None:
    info("Installing project dependencies...")

    run_command(
        ["yarn", "install"],
        live_output=True,
    )

    success("Project dependencies are installed.")


# ---------------------------------------------------------------------------
# Step 7: Check whether Twenty is already running
# ---------------------------------------------------------------------------

def is_port_open(
    host: str = TWENTY_HOST,
    port: int = TWENTY_PORT,
) -> bool:
    """
    Return True when a TCP connection can be established.
    """

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(1)
        return sock.connect_ex((host, port)) == 0


def check_twenty_server() -> bool:
    info("Checking whether the Twenty server is already running...")

    if is_port_open():
        success(
            f"Twenty server is already reachable at "
            f"http://{TWENTY_HOST}:{TWENTY_PORT}"
        )
        return True

    info("Twenty server is not currently running.")
    return False


# ---------------------------------------------------------------------------
# Step 8: Start Twenty server
# ---------------------------------------------------------------------------

def start_twenty_server() -> None:
    info("Starting the local Twenty server...")

    run_command(
        ["yarn", "twenty", "docker:start"],
        live_output=True,
    )

    success("Twenty server startup command completed.")


# ---------------------------------------------------------------------------
# Step 9: Wait for Twenty server
# ---------------------------------------------------------------------------

def wait_for_twenty_server() -> None:
    info(
        f"Waiting for Twenty server on "
        f"http://{TWENTY_HOST}:{TWENTY_PORT}..."
    )

    start_time = time.time()

    while time.time() - start_time < SERVER_TIMEOUT:
        if is_port_open():
            success(
                f"Twenty server is ready at "
                f"http://{TWENTY_HOST}:{TWENTY_PORT}"
            )
            return

        time.sleep(1)

    fail(
        f"Twenty server did not become reachable within "
        f"{SERVER_TIMEOUT} seconds."
    )


# ---------------------------------------------------------------------------
# Step 10: Start development server and sync application
# ---------------------------------------------------------------------------

def start_twenty_dev() -> None:
    print()
    print("=" * 60)
    print("Starting Twenty development mode")
    print("=" * 60)
    print()
    info(
        "The `yarn twenty dev` command may request authentication "
        "during first-time setup."
    )
    info(
        "Complete the authentication prompt if it appears."
    )
    print()

    # Do NOT capture output here.
    # The command can require interactive user input.
    result = subprocess.run(
        ["yarn", "twenty", "dev"],
        cwd=PROJECT_DIR,
    )

    if result.returncode != 0:
        fail(
            "The Twenty development server exited with an error. "
            "Review the output above."
        )

    success("Twenty development process completed.")


# ---------------------------------------------------------------------------
# Step 11: Main
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 60)
    print("      Twenty CRM App - Automated Local Setup")
    print("=" * 60)
    print()

    verify_project_directory()
    check_required_tools()
    check_node_version()
    show_versions()
    check_docker_running()

    install_dependencies()

    if not check_twenty_server():
        start_twenty_server()
        wait_for_twenty_server()

    start_twenty_dev()

    print()
    print("=" * 60)
    success("Application setup and synchronization completed.")
    print()
    print(f"Twenty CRM: http://{TWENTY_HOST}:{TWENTY_PORT}")
    print("Development credentials:")
    print("  Email:    tim@apple.dev")
    print("  Password: tim@apple.dev")
    print("=" * 60)


if __name__ == "__main__":
    main()