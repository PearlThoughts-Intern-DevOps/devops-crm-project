import subprocess
import sys

req_node_version = "v24.5.0"

def run_command(command):
    print(f"\n>>> Running: {command}")
    result = subprocess.run(command, shell=True)

    if result.returncode != 0:
        print(f"\n Command failed: {command}")
        sys.exit(result.returncode)

def check_command(command, name):
    result =  subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,)

    if result.returncode != 0:
        print(f"{name} is not installed")
        sys.exit(1)

    return result.stdout.strip()


def main():
    print("Devops CRM Local Setup")

    node_version = check_command("node --version", "Node.js")
    print(f"Node.js version: {node_version}")

    if node_version !=req_node_version:
        print(f"Error: node.js {req_node_version} is required,"
                f"But {node_version} is installed.")
        sys.exit(1)

    yarn_version = check_command("yarn --version", "Yarn")
    print(f"Yarn Version: {yarn_version}")

    check_command("docker --version", "Docker")
    print("Docker is available.")

    print("\n installing proj dependencies")
    run_command("yarn install")

    print("\n starting twenty docker server")
    run_command("yarn twenty docker:start")

    print("\n starting twenty dev server")
    run_command("yarn twenty dev")


if __name__ == "__main__":
    main()
