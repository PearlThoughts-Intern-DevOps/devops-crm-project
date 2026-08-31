# Task 5 - Docker Containerization

## Summary

1. Studied the Twenty CRM application structure and its dependencies.
2. Created a multi-stage Dockerfile using Node.js 24 Alpine.
3. Added a `.dockerignore` file to exclude unnecessary files from the Docker build context.
4. Created `docker-compose.yml` to run the application with the required Twenty server service.
5. Configured ports, environment variables, networking, restart policy, and health checks.
6. Used a non-root user in the application container for better security.
7. Built the Docker image successfully using Docker Compose.
8. Ran the containers and verified their status and application connectivity.
9. Faced runtime permission and service connectivity issues and resolved them by fixing container permissions and configuring the services on a shared Docker network.
10. Verified the application locally through `http://localhost:2020`.