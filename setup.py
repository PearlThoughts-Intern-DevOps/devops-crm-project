import platform
import subprocess
import sys


def run_command(command):
    """Run a command and stop if it fails."""
    print(f"\n[INFO] Running: {' '.join(command)}")

    executable = command[0]

    # On Windows, Yarn is usually provided through a .cmd shim.
    if platform.system() == "Windows" and executable == "yarn":
        executable = "yarn.cmd"

    subprocess.run([executable, *command[1:]], check=True)


def main():
    print("=" * 60)
    print("CRM PROJECT - LOCAL SETUP AUTOMATION")
    print("=" * 60)

    print("\n[STEP 1] Installing project dependencies...")
    run_command(["yarn", "install"])

    print("\n[STEP 2] Starting Twenty Docker server...")
    run_command(["yarn", "twenty", "docker:start"])

    print("\n[STEP 3] Checking Twenty server status...")
    run_command(["yarn", "twenty", "docker:status"])

    print("\n[STEP 4] Starting the development server...")
    print("[INFO] Keep this terminal open while using the application.")
    run_command(["yarn", "twenty", "dev"])


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print(f"\n[ERROR] Command failed with exit code {error.returncode}.")
        sys.exit(error.returncode)
    except KeyboardInterrupt:
        print("\n[INFO] Automation stopped by the user.")
        sys.exit(130)