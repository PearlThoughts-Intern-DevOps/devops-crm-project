# Task 5 - Issues and Solutions

## Issue 1: Docker Compose initially reported no services to build

### Problem

The first version of `docker-compose.yml` used only an existing `image:` definition.

Running:

`docker compose build`

returned:

`No services to build`

### Solution

Updated the Compose configuration to include a separate `app-deployer` service built from the project's `Dockerfile`.

### Result

Docker Compose was able to build the custom deployer image successfully.

---

## Issue 2: The first Docker runtime configuration could not connect to Redis

### Problem

The initial Compose configuration attempted to run the Twenty image with environment settings that expected Redis and PostgreSQL but did not reproduce the image's complete all-in-one setup.

The container reported Redis connection errors such as:

`ECONNREFUSED 127.0.0.1:6379`

### Solution

Inspected the `twenty-app-dev` image and confirmed that it is an all-in-one development image containing PostgreSQL, Redis, the Twenty server, and the worker.

The Compose configuration was changed to use this image directly for the Twenty server and its required persistent volumes.

### Result

The Twenty server started successfully and returned:

`HTTP/1.1 200 OK`

---

## Issue 3: The application package was copied into the image but not installed

### Problem

The initial Dockerfile created `my-app-0.1.0.tgz` and copied it into the runtime image, but copying the package alone did not install the application into Twenty.

### Solution

Implemented a separate `app-deployer` service.

The deployer:

1. Builds the application package.
2. Waits for the Twenty server.
3. Configures a Twenty remote using an API key.
4. Publishes the application privately to the local Twenty registry.
5. Installs the published application into the local Twenty server.

### Result

The application was successfully published and installed automatically.

---

## Issue 4: Twenty CLI did not support the `--quiet` option

### Problem

The deployment container stopped with:

`error: unknown option '--quiet'`

### Solution

Removed the unsupported `--quiet` option from the `twenty remote:add` command.

### Result

The remote was configured successfully using the API key.

---

## Issue 5: The deployer container could not build the application

### Problem

The deployment container initially reported:

`Cannot build application, please export default defineApplication() to define an application`

The container did not contain all of the source/configuration files required by the Twenty CLI.

### Solution

Updated the Dockerfile to copy the application source, public assets, TypeScript configuration files, package configuration, dependencies, and generated build output required by the Twenty CLI.

### Result

The deployer successfully built the application package and proceeded to publishing.

---

## Issue 6: Application version could not be redeployed

### Problem

After `my-app` version `0.1.0` had already been deployed, Twenty rejected another deployment of the same version:

`version must be higher than the currently deployed version 0.1.0`

### Solution

Updated the application version in `package.json` from:

`0.1.0`

to:

`0.1.1`

A later automated Docker build produced the next package version as needed.

### Result

The newer application version was successfully published and installed.

---

## Issue 7: Page layout mismatch during application installation

### Problem

Application installation initially failed because the page layout used `VERTICAL_LIST` while the widget used a grid position.

### Solution

Changed the page layout mode to:

`layoutMode: PageLayoutTabLayoutMode.GRID,`

### Result

The application was successfully installed into the local Twenty server.

---

## Issue 8: API authentication

### Problem

The local Twenty CLI remote authentication became invalid during testing.

### Solution

Created a fresh Twenty API key and stored it in the local `.env` file instead of using a hard-coded key.

The `.env` file is excluded by `.gitignore`.

### Result

The Docker deployer authenticated successfully using the `TWENTY_API_KEY` environment variable.

---

## Final Verification

The final Docker Compose workflow successfully:

- Built the application image.
- Started the Twenty server.
- Waited for the server to become available.
- Built the CRM application package.
- Published `my-app`.
- Installed the application.
- Served the application on port `2020`.

Final deployment result:

`[OK] Application installed.`

`[INFO] Deployment completed successfully.`

The CRM application was accessible at:

`http://localhost:2020`

