import subprocess
import time
import os

# Set CI mode for Yarn
os.environ["CI"] = "true"

print("Starting Twenty CRM Setup...")

# 1. Install dependencies
print("\n1. Installing dependencies...")
subprocess.run("yarn install", shell=True)

# 2. Start Docker server
print("\n2. Starting Docker server...")
subprocess.run("yarn twenty docker:start", shell=True)

# 3. Wait for Docker to be ready
print("\n3. Waiting 20 seconds for Docker to initialize...")
time.sleep(20)

# 4. Start development server
print("\n4. Starting development server...")
print("Open http://localhost:2020 in your browser.")
print("Login with: tim@apple.dev / tim@apple.dev")
print("Press Ctrl+C to stop the server.\n")

# Use 'yes' command to auto-answer all prompts, then run the dev server
subprocess.run("yes | yarn twenty dev", shell=True)
