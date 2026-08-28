import subprocess
import time
import sys
import urllib.request


URL = "http://localhost:2020"


def run_command(command):
    """Run a command and return the result."""
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            shell=True
        )
        return result.returncode, result.stdout, result.stderr
    except Exception as error:
        print(f"Error running command: {error}")
        return 1, "", str(error)


def check_docker():
    print("Checking Docker...")

    code, output, error = run_command("docker info")

    if code != 0:
        print("Docker is not running or is not installed.")
        print(error)
        sys.exit(1)

    print("Docker is available.")


def check_twenty():
    print("Checking Twenty CRM status...")

    code, output, error = run_command(
        "corepack yarn twenty docker:status"
    )

    print(output)

    return "healthy" in output.lower()


def start_twenty():
    print("Starting Twenty CRM...")

    code, output, error = run_command(
        "corepack yarn twenty docker:start"
    )

    if code != 0:
        print("Failed to start Twenty CRM.")
        print(error)
        sys.exit(1)

    print(output)


def wait_for_application():
    print("Waiting for Twenty CRM to become available...")

    for attempt in range(30):
        try:
            response = urllib.request.urlopen(URL, timeout=3)

            if response.status == 200:
                print("Twenty CRM is running successfully!")
                print(f"URL: {URL}")
                return

        except Exception:
            pass

        print(f"Waiting... ({attempt + 1}/30)")
        time.sleep(5)

    print("Twenty CRM did not become available in time.")
    sys.exit(1)


def main():
    print("=" * 50)
    print("Twenty CRM Local Setup Automation")
    print("=" * 50)

    check_docker()

    if check_twenty():
        print("Twenty CRM is already running.")
    else:
        start_twenty()

    wait_for_application()

    print("=" * 50)
    print("Setup completed successfully!")
    print(f"Open: {URL}")
    print("=" * 50)


if __name__ == "__main__":
    main()