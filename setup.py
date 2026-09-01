import subprocess
import sys


def run_command(command):
    print(f"\nRunning: {command}")

    result = subprocess.run(
        command,
        shell=True
    )

    if result.returncode != 0:
        print("Command failed.")
        sys.exit(result.returncode)


def main():
    print("Starting Twenty CRM local setup...")

    # Check Docker
    run_command("docker --version")

    # Start Twenty CRM
    run_command("corepack yarn twenty docker:start")

    # Check Twenty CRM status
    run_command("corepack yarn twenty docker:status")

    print("\nTwenty CRM setup completed successfully!")
    print("Open: http://localhost:2020")


if __name__ == "__main__":
    main()