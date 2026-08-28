#!/usr/bin/env python3

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parent.parent / "crm-project"
APP_URL = "http://localhost:2020"
CONTAINER_NAME = "twenty-app-dev"


def info(message: str) -> None:
    print(f"\n[INFO] {message}")


def success(message: str) -> None:
    print(f"[OK] {message}")


def error(message: str) -> None:
    print(f"[ERROR] {message}")


def fail(message: str, exit_code: int = 1) -> None:
    error(message)
    sys.exit(exit_code)


def run_command(
    command: list[str],
    description: str,
    *,
    capture_output: bool = False,
) -> subprocess.CompletedProcess[str]:
    info(description)

    try:
        return subprocess.run(
            command,
            cwd=PROJECT_DIR,
            check=True,
            text=True,
            capture_output=capture_output,
        )
    except FileNotFoundError:
        fail(f"Command not found: {command[0]}")
    except subprocess.CalledProcessError as exc:
        fail(
            f"Command failed with exit code {exc.returncode}: "
            f"{' '.join(command)}",
            exc.returncode,
        )

    raise RuntimeError("Unreachable")


def check_project_directory() -> None:
    required_files = (
        "package.json",
        "SETUP.md",
        ".nvmrc",
    )

    missing = [
        filename
        for filename in required_files
        if not (PROJECT_DIR / filename).exists()
    ]

    if missing:
        fail(
            "Invalid CRM project directory.\n"
            f"Expected: {PROJECT_DIR}\n"
            f"Missing: {', '.join(missing)}"
        )

    success(f"CRM project directory verified: {PROJECT_DIR}")


def check_tools() -> None:
    info("Checking required tools...")

    for tool in ("node", "npm", "yarn", "docker"):
        if shutil.which(tool) is None:
            fail(f"Required tool not found: {tool}")

        success(f"{tool} is installed")


def get_command_output(command: list[str]) -> str:
    try:
        result = subprocess.run(
            command,
            cwd=PROJECT_DIR,
            check=True,
            text=True,
            capture_output=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        fail(f"Unable to run {' '.join(command)}: {exc}")

    output = (result.stdout or result.stderr).strip()

    if not output:
        fail(f"Command returned no version information: {' '.join(command)}")

    return output


def display_versions() -> None:
    info("Dependency versions:")

    print(f"Node.js: {get_command_output(['node', '--version'])}")
    print(f"npm:     {get_command_output(['npm', '--version'])}")
    print(f"Yarn:    {get_command_output(['yarn', '--version'])}")
    print(f"Docker:  {get_command_output(['docker', '--version'])}")


def verify_node_version() -> None:
    nvmrc = (PROJECT_DIR / ".nvmrc").read_text(encoding="utf-8").strip()
    installed = get_command_output(["node", "--version"])

    expected = f"v{nvmrc}"

    if installed != expected:
        fail(
            f"Node.js version mismatch. "
            f"Required: {expected}; found: {installed}"
        )

    success(f"Node.js version matches .nvmrc: {installed}")


def check_docker_engine() -> None:
    info("Checking Docker Engine...")

    try:
        subprocess.run(
            ["docker", "info"],
            cwd=PROJECT_DIR,
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        fail(
            "Docker Engine is not available. "
            "Start Docker Desktop and try again."
        )

    success("Docker Engine is available")


def install_dependencies() -> None:
    run_command(
        ["yarn", "install"],
        "Installing project dependencies...",
    )
    success("Project dependencies installed.")


def start_docker_services() -> None:
    info("Starting the local Twenty Docker environment...")

    try:
        result = subprocess.run(
            ["yarn", "twenty", "docker:start"],
            cwd=PROJECT_DIR,
            text=True,
            capture_output=True,
        )
    except FileNotFoundError:
        fail("Unable to execute Yarn.")

    if result.stdout:
        print(result.stdout, end="")

    if result.stderr:
        print(result.stderr, end="", file=sys.stderr)

    # The repository can report a readiness/seeding warning even while
    # the application container remains running. Therefore, verify the
    # actual Docker container state instead of relying only on the exit code.
    container = subprocess.run(
        [
            "docker",
            "inspect",
            "--format={{.State.Status}}",
            CONTAINER_NAME,
        ],
        cwd=PROJECT_DIR,
        text=True,
        capture_output=True,
    )

    status = container.stdout.strip()

    if status == "running":
        success(f"Twenty container '{CONTAINER_NAME}' is running.")

        if result.returncode != 0:
            info(
                "The startup command returned a warning/error, "
                "but the Twenty container is running."
            )

        return

    if result.returncode != 0:
        fail(
            "Twenty Docker startup failed and the expected container "
            f"'{CONTAINER_NAME}' is not running."
        )

    fail(
        f"Twenty Docker startup completed, but container "
        f"'{CONTAINER_NAME}' is not running."
    )


def apply_application_manifest() -> None:
    info("Applying and synchronizing the local Twenty application...")

    try:
        result = subprocess.run(
            ["yarn", "twenty", "apply"],
            cwd=PROJECT_DIR,
            check=False,
            text=True,
        )
    except FileNotFoundError:
        fail("Unable to execute Yarn.")

    if result.returncode != 0:
        fail(
            "Twenty application synchronization failed. "
            "Check the output above for details."
        )

    success("Twenty application synchronized successfully.")


def main() -> None:
    print("=" * 64)
    print("        CRM Local Setup Automation")
    print("=" * 64)

    check_project_directory()
    check_tools()
    display_versions()
    verify_node_version()
    check_docker_engine()
    install_dependencies()
    start_docker_services()

    print()
    print("[INFO] The local Twenty server should be available at:")
    print(f"       {APP_URL}")

    apply_application_manifest()

    print()
    success(f"Setup complete. Open {APP_URL} in your browser.")
    print("=" * 64)


if __name__ == "__main__":
    main()

