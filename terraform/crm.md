Twenty CRM Docker Storage Verification
1. Check Current Storage

Check whether the Twenty CRM container is running:

docker ps

Check which storage backend the container is configured to use:

docker inspect twenty-app-dev | grep -E 'STORAGE_TYPE|STORAGE_S3_NAME|STORAGE_S3_REGION|STORAGE_S3_ENDPOINT'
STORAGE_TYPE=local → Local storage
STORAGE_TYPE=S3 → S3 storage
2. Stop and Remove Existing Container

Stop the container:

docker stop twenty-app-dev

Remove the container:

docker rm twenty-app-dev

These commands remove the container but do not remove the Docker volumes.

3. Run Twenty CRM with S3 Storage
docker run -d \
  --name twenty-app-dev \
  -p 2020:2020 \
  -v twenty-app-dev-data:/data/postgres \
  -v twenty-app-dev-storage:/app/packages/twenty-server/.local-storage \
  -e SERVER_URL=http://localhost:2020 \
  -e NODE_PORT=2020 \
  -e PG_DATABASE_URL=postgres://twenty:twenty@localhost:5432/default \
  -e REDIS_URL=redis://localhost:6379 \
  -e STORAGE_TYPE=S3 \
  -e STORAGE_S3_NAME=rohith-crm-storaage \
  -e STORAGE_S3_REGION=us-east-1 \
  -e STORAGE_S3_ENDPOINT=https://s3.us-east-1.amazonaws.com \
  -e APP_SECRET=twenty-app-dev-secret-not-for-production \
  -e APP_VERSION=v2.39.5 \
  -e NODE_ENV=development \
  -e DISABLE_DB_MIGRATIONS=true \
  -e DISABLE_CRON_JOBS_REGISTRATION=true \
  -e IS_BILLING_ENABLED=false \
  -e SIGN_IN_PREFILLED=true \
  -e APPLICATION_LOG_DRIVER=CONSOLE \
  twentycrm/twenty-app-dev:latest

Important S3 settings:

STORAGE_TYPE=S3
STORAGE_S3_NAME=rohith-crm-storaage
STORAGE_S3_REGION=us-east-1
STORAGE_S3_ENDPOINT=https://s3.us-east-1.amazonaws.com

These configure Twenty CRM to use the S3 bucket for file storage.

4. Verify Container and S3 Configuration

Check that the container is running:

docker ps

Check the storage configuration:

docker inspect twenty-app-dev | grep -E 'STORAGE_TYPE|STORAGE_S3_NAME|STORAGE_S3_REGION|STORAGE_S3_ENDPOINT'

Expected:

STORAGE_TYPE=S3
STORAGE_S3_NAME=rohith-crm-storaage
STORAGE_S3_REGION=us-east-1
STORAGE_S3_ENDPOINT=https://s3.us-east-1.amazonaws.com
5. Verify S3 Files

List all objects in the S3 bucket:

aws s3 ls s3://rohith-crm-storaage --recursive
--recursive meaning
aws
 ↓
AWS CLI

s3
 ↓
S3 service

ls
 ↓
List objects

s3://rohith-crm-storaage
 ↓
Target bucket

--recursive
 ↓
List files inside all folders/prefixes

After uploading a file/image through Twenty CRM, run:

aws s3 ls s3://rohith-crm-storaage --recursive
