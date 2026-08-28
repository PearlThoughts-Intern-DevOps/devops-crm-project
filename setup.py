# setup.py

import subprocess
import os

def run(command, cwd=None):
    print(f"Running: {command}")
    subprocess.run(command, shell=True, check=True, cwd=cwd)

try:
    # Install frontend dependencies
    if os.path.exists("frontend"):
        run("npm install", "frontend")

    # Install backend dependencies
    if os.path.exists("backend"):
        run("npm install", "backend")

    # Start services
    print("Setup completed successfully")

except Exception as e:
    print("Error:", e)