\# Docker Containerization - Twenty CRM



\## 1. Overview



This project containerizes the Twenty CRM application using Docker and Docker Compose.



The Docker setup contains three services:



\- Twenty CRM application

\- PostgreSQL database

\- Redis



Docker Compose is used to build, configure, network, and run all services together.



\---



\## 2. Project Docker Files



The following Docker-related files were created:



\- `Dockerfile`

\- `.dockerignore`

\- `.env.example`

\- `docker-compose.yml`

\- `DOCKER.md`



\---



\## 3. Application Structure



The project is a Twenty application using:



\- Node.js 24.5.0

\- Yarn 4.13.0

\- Twenty SDK 2.35.1

\- React

\- TypeScript

\- Vitest

\- PostgreSQL

\- Redis



The application package is built using the Twenty CLI.



The build command used was:



```bash

yarn twenty dev:build --tarball

