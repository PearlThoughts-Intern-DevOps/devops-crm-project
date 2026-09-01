#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys
import time
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parent
REQUIRED_NODE_VERSION = "24.5.0"
REQUIRED_YARN_MAJOR = 4
TWENTY_URL = "http://localhost:2020"


def run_command(command, check=True):
    print(f"\n$ {' '.join(command)}")
    return subprocess.run(command, cwd=PROJECT_DIR, check=check)


def command_exists(command):
    return shutil.which(command) is not None


def check_project_directory():
    print("===== PROJECT DIRECTORY =====")

    package_file = PROJECT_DIR / "package.json"

    if not package_file.exists():
        print("ERROR: package.json not found.")
        print("Run this script from the project directory.")
        sys.exit(1)

    print(f"Project: {PROJECT_DIR}")


def check_node():
    print("\n===== NODE.JS =====")

    if not command_exists("node"):
        print("ERROR: Node.js is not installed.")
        sys.exit(1)

    result = subprocess.run(
        ["node", "--version"],
        capture_output=True,
        text=True,
        check=True,
    )

    version = result.stdout.strip()
    print(f"Node.js: {version}")

    if version != f"v{REQUIRED_NODE_VERSION}":
        print(
            f"WARNING: Project requires Node.js {REQUIRED_NODE_VERSION}, "
            f"but {version} is active."
        )
        print("Use:")
        print(f"  nvm use {REQUIRED_NODE_VERSION}")


def check_yarn():
    print("\n===== YARN =====")

    if not command_exists("yarn"):
        print("ERROR: Yarn is not installed.")
        sys.exit(1)

    result = subprocess.run(
        ["yarn", "--version"],
        capture_output=True,
        text=True,
        check=True,
    )

    version = result.stdout.strip()
    print(f"Yarn: {version}")

    try:
        major_version = int(version.split(".")[0])
    except ValueError:
        print("ERROR: Could not determine Yarn version.")
        sys.exit(1)

    if major_version < REQUIRED_YARN_MAJOR:
        print("ERROR: Yarn 4 or newer is required.")
        sys.exit(1)


def check_docker():
    print("\n===== DOCKER =====")

    if not command_exists("docker"):
        print("ERROR: Docker is not installed.")
        sys.exit(1)

    run_command(["docker", "--version"])

    result = subprocess.run(
        ["docker", "info"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    if result.returncode != 0:
        print("ERROR: Docker daemon is not running.")
        print("Start Docker and run this script again.")
        sys.exit(1)

    print("Docker daemon: running")


def install_dependencies():
    print("\n===== INSTALLING DEPENDENCIES =====")
    run_command(["yarn", "install", "--immutable"])


def check_twenty_server():
    print("\n===== TWENTY SERVER =====")

    result = subprocess.run(
        ["yarn", "twenty", "docker:status"],
        cwd=PROJECT_DIR,
        text=True,
    )

    if result.returncode == 0:
        print("Twenty server status checked.")


def start_twenty_server():
    print("\n===== STARTING TWENTY SERVER =====")

    result = subprocess.run(
        ["yarn", "twenty", "docker:status"],
        cwd=PROJECT_DIR,
        capture_output=True,
        text=True,
    )

    if "running (healthy)" in result.stdout:
        print("Twenty server is already running and healthy.")
        return

    print("Twenty server is not healthy. Starting it...")

    run_command(["yarn", "twenty", "docker:start"])


def sync_application():
    print("\n===== SYNCING APPLICATION =====")

    print("Running Twenty application sync...")
    run_command(["yarn", "twenty", "dev", "--once"])


def main():
    print("=" * 60)
    print("Twenty CRM - Local Setup Automation")
    print("=" * 60)

    check_project_directory()
    check_node()
    check_yarn()
    check_docker()
    install_dependencies()
    check_twenty_server()
    start_twenty_server()

    print("\nWaiting for Twenty server...")
    time.sleep(5)

    sync_application()

    print("\n" + "=" * 60)
    print("SETUP COMPLETED SUCCESSFULLY")
    print("=" * 60)
    print(f"Twenty URL: {TWENTY_URL}")
    print("Application synchronization completed.")


if __name__ == "__main__":
    main()
