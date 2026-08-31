import shutil
import subprocess
import sys
import time
import urllib.request


def check_command(command):
    """Check if a required command is available on the system."""
    return shutil.which(command) is not None


def run_command(command):
    """Run a terminal command and stop if it fails."""
    print(f"\nRunning: {' '.join(command)}")

    result = subprocess.run(command)

    # A return code of 0 means the command completed successfully.
    if result.returncode != 0:
        print(f"\nCommand failed: {' '.join(command)}")
        sys.exit(result.returncode)


def check_prerequisites():
    """Check that the required tools are installed."""
    print("\nChecking prerequisites...")

    required_commands = ["node", "yarn", "docker"]

    for command in required_commands:
        if check_command(command):
            print(f"[OK] {command} is installed")
        else:
            print(f"[ERROR] {command} is not installed")
            print(f"Please install {command} before running this setup.")
            sys.exit(1)


def install_dependencies():
    """Install all Node.js dependencies required by the project."""
    print("\nInstalling project dependencies...")

    # yarn install reads package.json and installs the project's dependencies.
    run_command(["yarn", "install"])


def start_twenty():
    """Start the local Twenty CRM server using Docker."""
    print("\nStarting Twenty server...")

    # The Twenty CLI manages the Docker container for the local server.
    result = subprocess.run(
        ["yarn", "twenty", "docker:start"]
    )

    if result.returncode != 0:
        print("\n[ERROR] Twenty server failed to start.")
        print("Check the server logs using:")
        print("yarn twenty docker:logs")
        sys.exit(result.returncode)


def check_twenty_server():
    """Wait for the Twenty server to become available."""
    print("\nChecking Twenty server...")

    # Twenty runs locally on port 2020 according to the project setup.
    url = "http://localhost:2020"

    # The server can take a little time to start, so try several times
    # instead of immediately assuming that the startup has failed.
    for attempt in range(10):
        try:
            response = urllib.request.urlopen(url, timeout=5)

            if response.status == 200:
                print("[OK] Twenty server is running")
                return

        except Exception:
            # The server may still be starting, so try again.
            pass

        print(f"Waiting for Twenty server... ({attempt + 1}/10)")
        time.sleep(3)

    print("\n[ERROR] Twenty server is not responding.")
    print("Check the Docker logs using:")
    print("yarn twenty docker:logs")
    sys.exit(1)


def start_development():
    """Start the Twenty development environment."""
    print("\nStarting Twenty development environment...")
    print("Press Ctrl+C to stop the development server.\n")

    # twenty dev builds and syncs the local app with the Twenty server.
    # This command keeps running while we work on the application.
    run_command(["yarn", "twenty", "dev"])


def main():
    """Run the complete local setup and startup process."""
    print("======================================")
    print("      DevOps CRM Local Setup")
    print("======================================")

    # Check the environment before making any changes.
    check_prerequisites()

    # Install dependencies needed by the project.
    install_dependencies()

    # Start the local CRM server.
    start_twenty()

    # Make sure the server is actually reachable before continuing.
    check_twenty_server()

    # Start the development and synchronization process.
    start_development()


# Run the setup only when this file is executed directly.
if __name__ == "__main__":
    main()
