import subprocess
import sys


def run_command(command):
    print(f"\n>>> Running: {command}")
    result = subprocess.run(command, shell=True)

    if result.returncode != 0:
        print(f"Command failed: {command}")
        sys.exit(result.returncode)


def main():
    print("Starting DevOps CRM local setup...")

    run_command("yarn install")
    run_command("yarn twenty docker:start")
    run_command("yarn twenty docker:status")

    print("\nSetup completed successfully!")
    print("Run 'yarn twenty dev' to start the application.")


if __name__ == "__main__":
    main()
