import os
import shutil
import subprocess
import sys
import time


def run_command(command, check=True):
    print(f"\n>>> Running: {command}")

    result = subprocess.run(
        command,
        shell=True,
        text=True,
    )

    if check and result.returncode != 0:
        print(f"\nERROR: Command failed with exit code {result.returncode}")
        sys.exit(result.returncode)

    return result


def check_command(command, name):
    if shutil.which(command) is None:
        print(f"ERROR: {name} is not installed or not available in PATH.")
        return False

    print(f"✓ {name} found")
    return True


def main():
    print("=" * 60)
    print("Twenty CRM Local Setup Automation")
    print("=" * 60)
	
    docker_cli = "/mnt/wsl/docker-desktop/cli-tools/usr/bin/docker"

    if os.path.exists(docker_cli):
        os.environ["PATH"] = (
            os.path.dirname(docker_cli)
            + os.pathsep
            + os.environ["PATH"]
    )
    # Check required tools
    print("\n[1/6] Checking required tools...")

    if not check_command("node", "Node.js"):
        sys.exit(1)

    if not check_command("yarn", "Yarn"):
        sys.exit(1)

    if not check_command("docker", "Docker"):
        sys.exit(1)

    # Check Node.js version
    print("\n[2/6] Checking Node.js version...")
    run_command("node --version")

    # Check Yarn version
    print("\n[3/6] Checking Yarn version...")
    run_command("yarn --version")

    # Check Docker
    print("\n[4/6] Checking Docker...")
    docker_check = run_command("docker version", check=False)

    if docker_check.returncode != 0:
        print("ERROR: Docker is installed but the Docker server is unavailable.")
        print("Please start Docker Desktop and try again.")
        sys.exit(1)

    # Install dependencies
    print("\n[5/6] Installing project dependencies...")
    run_command("yarn install")

    # Start Twenty server
    print("\n[6/6] Starting Twenty CRM...")
    run_command("yarn twenty docker:start", check=False)

    print("\nChecking Twenty server status...")

    for attempt in range(12):
        status = subprocess.run(
            "yarn twenty docker:status",
            shell=True,
            text=True,
            capture_output=True,
        )

        print(status.stdout)

        if status.returncode == 0 and "healthy" in status.stdout.lower():
            print("\n" + "=" * 60)
            print("Twenty CRM is running successfully!")
            print("URL: http://localhost:2020")
            print("Login: tim@apple.dev")
            print("Password: tim@apple.dev")
            print("=" * 60)
            return

        print(f"Waiting for server... ({attempt + 1}/12)")
        time.sleep(5)

    print("\nERROR: Twenty server did not become healthy.")
    print("Run the following command to inspect the logs:")
    print("yarn twenty docker:logs")
    sys.exit(1)


if __name__ == "__main__":
    main()
