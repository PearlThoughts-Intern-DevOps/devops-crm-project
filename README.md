# Task 3 - Twenty CRM Local Setup & Automation

## ⚙️ 1. Setup Steps

I started by cloning the Twenty CRM repo and reading through the docs to get a feel for how the app is structured. 

Next, I got my dev environment ready by making sure Node.js, Yarn, Docker, and Python were good to go. Once that was sorted, I installed the project dependencies and spun up the local server using Docker. 

Finally, I booted up the app in development mode, opened it in my browser, and confirmed everything was syncing and running smoothly.

---

## 🤖 2. Automation Steps

Once I got the manual setup working, I wrote a Python script to automate the whole process. The goal was to make starting the local environment painless and skip redundant installs. 

Here is what the script actually does:

*   Checks if the right system tools are installed.
*   Looks for existing project dependencies (and skips the install step if they are already there).
*   Installs any missing dependencies.
*   Checks if the Twenty CRM server is currently running.
*   Automatically starts the server if it's down.
*   Fires up the dev environment only after the server is ready.
*   Cleans everything up and shuts down properly when I close the app.

---

## 🐛 3. Issues Faced

### Issue 1 — Misreading the Server Status
At first, my script couldn't reliably tell if the server was actually running. It would look at the status and think the server was ready, even when it was stopped.

### Issue 2 — Connection Failures
If the main server was down, the dev environment would just fail to connect to it entirely. 

### Issue 3 — Messy Shutdowns
Initially, when I stopped the dev environment (like hitting Ctrl+C), it threw a big Python error and left the Twenty CRM server running in the background.

---

## ✅ 4. Solutions

### Solution 1 — Better Server Detection
I updated the script to actively check if the server is reachable, rather than just relying on a basic status command. 

### Solution 2 — Automatic Server Startup
I added a safety check. Now, the script verifies the server is up before trying to start the dev environment. If the server is offline, the script boots it up first.

### Solution 3 — Graceful Shutdown
I added proper exit handling. Now, if I kill the script, it safely terminates the dev environment and shuts down the CRM server so nothing is left running in the background.

---
## 5. Verification

After running the final script, everything worked exactly as expected:

*   The automation fired up Twenty CRM without any errors.
*   The app was live at **http://localhost:2020**.
*   The CRM interface loaded up perfectly, confirming the local setup is solid.
