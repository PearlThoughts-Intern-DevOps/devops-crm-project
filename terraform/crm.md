TWENTY CRM – S3 STORAGE VERIFICATION

1. CHECK AWS IAM ROLE

aws sts get-caller-identity

Expected:
EC2S3AccessRole


2. CHECK S3 BUCKET

aws s3 ls s3://rohith-crm-storaage --recursive


3. TEST EC2 → S3 ACCESS

echo "CRM S3 test" > /tmp/test.txt

aws s3 cp /tmp/test.txt s3://rohith-crm-storaage/test.txt

aws s3 ls s3://rohith-crm-storaage --recursive


4. REMOVE MANUAL TEST FILE

aws s3 rm s3://rohith-crm-storaage/test.txt

aws s3 ls s3://rohith-crm-storaage --recursive


5. CHECK TWENTY CONTAINER

docker ps -a

docker inspect twenty-app-dev \
--format '{{range .Config.Env}}{{println .}}{{end}}' \
| grep -E 'STORAGE|S3'


6. CHECK TWENTY STORAGE ENVIRONMENT

docker exec twenty-app-dev sh -c \
'env | sort | grep -Ei "STORAGE|S3|AWS"'


7. CHECK TWENTY S3 CONFIGURATION

docker exec twenty-app-dev sh -c \
'find /app -type f \( -name "*.js" -o -name "*.ts" \) 2>/dev/null | \
xargs grep -nE "STORAGE_TYPE|STORAGE_S3|S3_BUCKET|S3_NAME" 2>/dev/null | head -100'


8. TWENTY S3 CONFIGURATION

STORAGE_TYPE=S3

STORAGE_S3_NAME=rohith-crm-storaage

STORAGE_S3_REGION=us-east-1

STORAGE_S3_ENDPOINT=https://s3.us-east-1.amazonaws.com


9. CHECK TWENTY LOGS

docker logs twenty-app-dev --tail 100


10. LOGIN TO TWENTY CRM

Open:

http://54.242.102.193:2020

Login:

Email:
tim@apple.dev

Password:
tim@apple.dev


11. UPLOAD FILE THROUGH TWENTY CRM

Upload an image/file through the Twenty CRM interface.

Do NOT use aws s3 cp for this test.

The purpose is to verify that Twenty itself writes the file to S3.


12. VERIFY TWENTY → S3

aws s3 ls s3://rohith-crm-storaage --recursive


13. EXPECTED RESULT

The S3 bucket should contain files similar to:

20202020-1c25-4d02-bf25-6aeccf7ea419/de704230-063c-40c5-968c-1ce955620472/core-picture/9beb7c03-d670-4812-9b80-ef16fcaa6549.png

20202020-1c25-4d02-bf25-6aeccf7ea419/de704230-063c-40c5-968c-1ce955620472/core-picture/a46d5eaa-11f1-4190-a864-e46d763d4870.png

20202020-1c25-4d02-bf25-6aeccf7ea419/de704230-063c-40c5-968c-1ce955620472/core-picture/ccff6f65-9366-41cd-8d6c-f341d5082eac.jpg


FINAL ARCHITECTURE

Twenty CRM
     ↓
S3 Storage Driver
     ↓
EC2S3AccessRole
     ↓
Amazon S3
     ↓
rohith-crm-storaage
     ↓
CRM uploaded files


FINAL RESULT

EC2 → S3 was successfully tested using aws s3 cp.

Twenty CRM → S3 was then verified by uploading files through the Twenty CRM application and checking the S3 bucket with:

aws s3 ls s3://rohith-crm-storaage --recursive

The PNG and JPG objects appearing in the bucket confirm that Twenty CRM is using S3 for file storage.
