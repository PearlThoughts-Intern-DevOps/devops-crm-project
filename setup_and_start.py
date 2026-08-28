import os
import shutil
import subprocess
import sys
import time
import urllib.request
import urllib.error


PROJECT_URL = "http://localhost:2020"
MAX_RETRIES = 12
RETRY_DELAY = 5


def run_command(command, check=True):
    """Run a command and return the result."""

    print(f"\nRunning: {' '.join(command)}")

    result = subprocess.run(
        command,
        check=False
    )

    if check and result.returncode != 0:
        print(
            f"\nERROR: Command failed with exit code "
            f"{result.returncode}"
        )
        sys.exit(result.returncode)

    return result


def check_command(command, name):
    """Check whether a required command is available."""

    if shutil.which(command) is None:
        print(f"ERROR: {name} is not installed or not available in PATH.")
        sys.exit(1)

    print(f"✓ {name} is available")


def check_docker_health():
    """Check whether Docker is running correctly."""

    print("\nChecking Docker health...")

    result = subprocess.run(
        ["docker", "info"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False
    )

    if result.returncode != 0:
        print("ERROR: Docker is installed but not running.")
        sys.exit(1)

    print("✓ Docker is running correctly")


def wait_for_application():
    """Wait until the Twenty application is reachable."""

    print("\nChecking application health...")

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = urllib.request.urlopen(
                PROJECT_URL,
                timeout=5
            )

            if response.status < 500:
                print(
                    f"✓ Application health check passed "
                    f"(HTTP {response.status})"
                )
                return True

        except urllib.error.URLError:
            pass
        except Exception:
            pass

        print(
            f"Waiting for application... "
            f"Attempt {attempt}/{MAX_RETRIES}"
        )

        time.sleep(RETRY_DELAY)

    print("\nERROR: Application health check failed.")
    return False


def main():

    print("=" * 60)
    print("Twenty CRM Local Setup and Startup Automation")
    print("=" * 60)

    # Step 1: Check required tools
    print("\n[1/5] Checking required tools...")

    check_command("node", "Node.js")
    check_command("docker", "Docker")

    yarn_command = "yarn.cmd" if os.name == "nt" else "yarn"
    check_command(yarn_command, "Yarn")

    # Step 2: Check Docker health
    print("\n[2/5] Checking Docker...")

    check_docker_health()

    # Step 3: Install dependencies
    print("\n[3/5] Installing dependencies...")

    run_command([yarn_command, "install"])

    # Step 4: Start Twenty
    print("\n[4/5] Starting Twenty server...")

    run_command([
        yarn_command,
        "twenty",
        "docker:start"
    ])

    # Step 5: Verify application health
    print("\n[5/5] Verifying application health...")

    run_command([
        yarn_command,
        "twenty",
        "docker:status"
    ])

    if not wait_for_application():
        sys.exit(1)

    print("\n" + "=" * 60)
    print("SETUP COMPLETED SUCCESSFULLY")
    print("=" * 60)
    print(f"\nApplication URL: {PROJECT_URL}")


if __name__ == "__main__":
    main()