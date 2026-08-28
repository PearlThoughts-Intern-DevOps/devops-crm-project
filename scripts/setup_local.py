#!/usr/bin/env python3
"""
setup.py - Automates local setup and startup of the devops-crm-project (Twenty CRM).

What it does, mirroring the manual steps in SETUP.md:
  1. Checks that Node.js, Yarn, and Docker are installed (and prints versions).
  2. Runs `yarn install` to install project dependencies.
  3. Runs `yarn twenty docker:start` to start the local Twenty server.
  4. Polls `yarn twenty docker:status` until the server reports healthy.
  5. Opens http://localhost:2020 in the default browser.

Usage:
    python setup.py

No shell scripts are used - all commands are invoked directly via subprocess.
"""

import subprocess
import sys
import shutil
import time
import webbrowser


APP_URL = "http://localhost:2020"
STATUS_POLL_INTERVAL_SECONDS = 5
STATUS_POLL_TIMEOUT_SECONDS = 180  # 3 minutes


def resolve_executable(name: str) -> str:
    """
    Resolve a command name to a real executable path.

    On Windows, tools like Yarn/npm are shipped as .cmd/.bat shims, and
    Python's subprocess (with shell=False) does not automatically search
    PATHEXT the way cmd.exe/PowerShell do. shutil.which() *does* perform
    that resolution correctly, so we use it here to avoid false
    "not found" errors for tools that actually work fine interactively.
    """
    resolved = shutil.which(name)
    return resolved if resolved else name


def print_step(message: str) -> None:
    print(f"\n{'=' * 70}\n{message}\n{'=' * 70}")


def run_command(command: list[str], description: str, check: bool = True) -> subprocess.CompletedProcess:
    """Run a command and stream its output live. Exits the script on failure if check=True."""
    resolved_command = [resolve_executable(command[0])] + command[1:]
    print(f"\n>> {description}")
    print(f">> Running: {' '.join(command)}\n")
    try:
        result = subprocess.run(resolved_command, check=check, shell=False)
        return result
    except FileNotFoundError:
        print(f"ERROR: Command not found: {command[0]}. Is it installed and on your PATH?")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"ERROR: '{description}' failed with exit code {e.returncode}.")
        sys.exit(e.returncode)


def get_version_output(command: list[str]) -> str | None:
    """Return the stdout of a version-check command, or None if the tool isn't found."""
    resolved_command = [resolve_executable(command[0])] + command[1:]
    try:
        result = subprocess.run(resolved_command, capture_output=True, text=True, check=True, shell=False)
        return result.stdout.strip()
    except (FileNotFoundError, subprocess.CalledProcessError):
        return None


def check_prerequisites() -> None:
    print_step("STEP 1: Checking prerequisites (Node.js, Yarn, Docker)")

    checks = {
        "Node.js": ["node", "--version"],
        "Yarn": ["yarn", "--version"],
        "Docker": ["docker", "--version"],
        "Docker Compose": ["docker", "compose", "version"],
    }

    missing = []
    for name, cmd in checks.items():
        version = get_version_output(cmd)
        if version is None:
            print(f"  [MISSING] {name} was not found on PATH.")
            missing.append(name)
        else:
            print(f"  [OK] {name}: {version}")

    if missing:
        print(f"\nERROR: The following required tools are missing: {', '.join(missing)}")
        print("Please install them before running this script again.")
        sys.exit(1)

    # Basic check that Docker daemon is actually running (not just installed).
    docker_info = subprocess.run(
        [resolve_executable("docker"), "info"], capture_output=True, text=True, shell=False
    )
    if docker_info.returncode != 0 or "Server:" not in docker_info.stdout:
        print("\nERROR: Docker CLI is installed, but the Docker daemon does not appear to be running.")
        print("Please start Docker Desktop and try again.")
        sys.exit(1)
    print("  [OK] Docker daemon is running.")


def install_dependencies() -> None:
    print_step("STEP 2: Installing project dependencies (yarn install)")
    run_command(
        ["yarn", "install", "--network-timeout", "300000"],
        "yarn install (with extended network timeout for slow/unstable connections)",
    )


def start_docker_server() -> None:
    print_step("STEP 3: Starting the local Twenty server (yarn twenty docker:start)")
    run_command(["yarn", "twenty", "docker:start"], "yarn twenty docker:start")


def wait_for_healthy_status() -> None:
    print_step("STEP 4: Waiting for the Twenty server to become healthy")

    elapsed = 0
    while elapsed < STATUS_POLL_TIMEOUT_SECONDS:
        result = subprocess.run(
            [resolve_executable("yarn"), "twenty", "docker:status"],
            capture_output=True,
            text=True,
            shell=False,
        )
        output = result.stdout + result.stderr
        print(output.strip())

        if "healthy" in output.lower():
            print("\n[OK] Server is healthy!")
            return

        print(f"Not healthy yet. Retrying in {STATUS_POLL_INTERVAL_SECONDS}s "
              f"(elapsed: {elapsed}s / timeout: {STATUS_POLL_TIMEOUT_SECONDS}s)...")
        time.sleep(STATUS_POLL_INTERVAL_SECONDS)
        elapsed += STATUS_POLL_INTERVAL_SECONDS

    print(f"\nERROR: Server did not report healthy within {STATUS_POLL_TIMEOUT_SECONDS} seconds.")
    print("Check the output above, or run 'yarn twenty docker:status' manually to investigate.")
    sys.exit(1)


def open_browser() -> None:
    print_step("STEP 5: Opening the application in your browser")
    print(f">> Opening {APP_URL}")
    print(">> Login credentials: tim@apple.dev / tim@apple.dev")
    try:
        webbrowser.open(APP_URL)
    except Exception as e:
        print(f"Could not auto-open browser ({e}). Please open {APP_URL} manually.")


def main() -> None:
    print_step("devops-crm-project: Automated Local Setup & Startup")
    check_prerequisites()
    install_dependencies()
    start_docker_server()
    wait_for_healthy_status()
    open_browser()

    print_step("SETUP COMPLETE")
    print(f"The application is running at {APP_URL}")
    print("Login: tim@apple.dev / tim@apple.dev")
    print("\nTo check status at any time: yarn twenty docker:status")
    print("To stop the server:          yarn twenty docker:stop")


if __name__ == "__main__":
    main()