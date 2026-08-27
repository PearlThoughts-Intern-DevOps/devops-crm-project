import subprocess
import sys


def run_command(command):
    print(f"\nRunning: {' '.join(command)}")

    result = subprocess.run(command, shell=True)

    if result.returncode != 0:
        print("Command failed.")
        sys.exit(result.returncode)


def main():
    print("Starting CRM project setup...")

    # Install project dependencies
    run_command("corepack yarn install")

    # Start Docker/Twenty services
    run_command("corepack yarn twenty docker:start")

    print("\nCRM setup completed successfully!")
    print("Open http://localhost:2020 in your browser.")


if __name__ == "__main__":
    main()