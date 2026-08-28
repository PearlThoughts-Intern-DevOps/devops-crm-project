import subprocess
import sys
import urllib.request


def run_command(command):
    print(f"\n>>> {' '.join(command)}")
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as error:
        print(f"\nCommand failed with exit code {error.returncode}.")
        sys.exit(error.returncode)


def check_server():
    url = "http://localhost:2020"

    print(f"\n>>> Checking Twenty server at {url}")

    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            if response.status < 400:
                print(f"Twenty server is reachable (HTTP {response.status}).")
                return True
    except Exception as error:
        print(f"Twenty server is not reachable: {error}")

    return False


def main():
    print("======================================")
    print(" Twenty App Local Setup Automation")
    print("======================================")

    print("\n[1/3] Installing project dependencies...")
    run_command(["yarn", "install"])

    print("\n[2/3] Starting the local Twenty server...")
    run_command(["yarn", "twenty", "docker:start"])

    print("\n[3/3] Verifying the Twenty server...")
    if not check_server():
        print("\nSetup failed: Twenty server is not reachable.")
        sys.exit(1)

    print("\n======================================")
    print(" Setup completed successfully!")
    print("======================================")
    print("\nRun the following command to start the app:")
    print("  yarn twenty dev")


if __name__ == "__main__":
    main()
