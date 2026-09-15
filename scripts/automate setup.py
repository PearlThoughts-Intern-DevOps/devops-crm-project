import re
import shutil
import subprocess
import sys
from pathlib import Path


def fail(message):
    print(f"\nERROR: {message}")
    sys.exit(1)


def run_command(command):
    print(f"\nRunning: {' '.join(command)}")
    result = subprocess.run(command)

    if result.returncode != 0:
        fail(f"Command failed: {' '.join(command)}")


def check_command(command, name):
    if shutil.which(command) is None:
        fail(f"{name} is not installed or not available in PATH.")


def check_node():
    check_command("node", "Node.js")

    nvmrc = Path(".nvmrc")

    if not nvmrc.exists():
        fail(".nvmrc file not found.")

    required_version = nvmrc.read_text().strip()

    result = subprocess.run(
        ["node", "--version"],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        fail("Unable to determine the Node.js version.")

    installed_version = result.stdout.strip()
    match = re.fullmatch(r"v(\d+\.\d+\.\d+)", installed_version)

    if not match:
        fail(f"Unable to parse Node.js version: {installed_version}")

    print(f"Node.js required: {required_version}")
    print(f"Node.js installed: {installed_version}")

    if match.group(1) != required_version:
        fail(
            f"Node.js version mismatch. "
            f"Required {required_version}, "
            f"but found {match.group(1)}."
        )

    print("Node.js version check: OK")


def check_yarn():
    check_command("yarn", "Yarn")

    result = subprocess.run(
        ["yarn", "--version"],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        fail("Unable to determine the Yarn version.")

    print(f"Yarn version: {result.stdout.strip()}")
    print("Yarn check: OK")


def check_docker():
    check_command("docker", "Docker")

    result = subprocess.run(
        ["docker", "info"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    if result.returncode != 0:
        fail("Docker is installed, but the Docker daemon is not running.")

    print("Docker check: OK")


def check_prerequisites():
    print("\nChecking prerequisites...")

    check_node()
    check_yarn()
    check_docker()

    print("\nAll required prerequisites are available.")


def main():
    print("Starting local CRM setup...")

    check_prerequisites()

    run_command(["yarn", "install"])
    run_command(["yarn", "twenty", "docker:start"])

    print("\nStarting the development server...")
    run_command(["yarn", "twenty", "dev"])


if __name__ == "__main__":
    main()