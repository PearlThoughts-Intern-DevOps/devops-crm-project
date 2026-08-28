# DevOps CRM Project – Setup & Automation Documentation

## Project Repository

**Repository:** PearlThoughts-Intern-DevOps/devops-crm-project

## Objective

The objective of this task was to clone the repository, understand the project structure, run the application locally, automate the setup process using Python, and create a Pull Request with the implemented changes.

---

# Setup Steps

## 1. Clone the Repository

```bash
git clone <repository-url>
cd devops-crm-project
```

## 2. Explore the Project Structure

Reviewed the repository structure to identify:

- Frontend application
- Backend application
- Configuration files
- Dependency files
- Environment variables

## 3. Install Dependencies

Installed all required project dependencies.

```bash
npm install
```

## 4. Run the Application

Started the required services and verified that the application was running successfully.

Example:

```bash
npm start
```

or

```bash
docker-compose up
```

(Depending on the project requirements.)

## 5. Verify the Application

Verified that:

- The application started successfully.
- No startup errors occurred.
- Required services were accessible.
- Dependencies were installed correctly.

---

# Automation Steps

## Python Automation Script

A Python script (`script.py`) was created to automate the local setup and startup process.

### Tasks Automated

- Dependency installation
- Environment preparation
- Application startup
- Validation checks

### Script Execution

```bash
python script.py
```

### Output

```text
Setup completed successfully
```

### Benefits

- Reduced manual effort.
- Faster project setup.
- Consistent and repeatable execution process.

---

# Issues Faced and Solutions

## Issue 1: setup.py File Not Found

### Error

```text
python: can't open file 'setup.py': [Errno 2] No such file or directory
```

### Cause

The automation file was named `script.py`, but the command executed was:

```bash
python setup.py
```

### Solution

Executed the correct file:

```bash
python script.py
```

### Result

The script executed successfully and displayed:

```text
Setup completed successfully
```

---

## Issue 2: Understanding the Project Structure

### Cause

The project contained multiple folders and configuration files that needed to be understood before execution.

### Solution

Reviewed:

- Project folders
- Dependency files
- Configuration files
- Startup commands

### Result

Successfully identified the components required for local setup.

---

## Issue 3: Dependency Verification

### Cause

Dependencies needed to be installed before running the application.

### Solution

Installed all required dependencies and verified successful installation.

### Result

The application started without dependency-related issues.

---

# Git Workflow

## Create a Branch

```bash
git checkout -b dinesh-murali
```

## Verify Branch

```bash
git branch
```

## Add Changes

```bash
git add .
```

## Commit Changes

```bash
git commit -m "Added Python automation script and setup documentation"
```

## Push Changes

```bash
git push origin dinesh-murali
```

## Create Pull Request

Created a Pull Request from:

```text
dinesh-murali → main
```

---

# Loom Video Demonstration

The Loom video includes:

1. Repository overview
2. Project structure walkthrough
3. Local setup process
4. Application execution
5. Python automation script explanation
6. Automation script execution
7. Issues faced and resolutions
8. Branch creation
9. Git push process
10. Pull Request creation

## Loom Video Link

Paste your Loom video URL here:

```text
https://www.loom.com/share/your-video-id
```

---

# Conclusion

The DevOps CRM Project was successfully cloned, explored, executed locally, and automated using a Python script. The setup process, automation workflow, encountered issues, and their resolutions were documented. All changes were pushed to a dedicated branch and submitted through a Pull Request for review.