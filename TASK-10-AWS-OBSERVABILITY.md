Task 10 – AWS Observability with CloudWatch
Objective

Implemented AWS CloudWatch monitoring for the Twenty CRM application running on an EC2 instance.

Implementation
1. EC2 & Twenty CRM
Launched an EC2 instance using Amazon Linux 2023.
Connected to the instance using SSH.
Deployed Twenty CRM using Docker.
Verified all containers were running and healthy.
Verified the application using curl and browser.
2. CloudWatch Agent

Installed and configured Amazon CloudWatch Agent.

Collected:

CPU utilization
Memory utilization
Disk utilization

Custom namespace:

TwentyCRM/EC2

3. CloudWatch Dashboard

Created a dashboard named:

TwentyCRM-Observability

The dashboard displays CPU, Memory, and Disk metrics for the EC2 instance.

4. CloudWatch Alarms

Created alarms for:

Memory: mem_used_percent > 80%
Disk: disk_used_percent > 80%

SNS notifications were not configured because the provided IAM user did not have SNS permissions.

5. Testing
Accessed Twenty CRM and generated application activity.
Verified CPU, Memory, and Disk metrics in CloudWatch.
Verified the CloudWatch Dashboard and alarms.
Issues & Solutions

SNS Permission Issue:
The IAM user did not have permission to list SNS topics, so the alarm was configured without notification actions.

Initial Insufficient Data:
New alarms initially showed Insufficient data while CloudWatch collected enough metric data.

Conclusion

Successfully implemented AWS Observability for Twenty CRM using EC2 and CloudWatch. CPU, Memory, and Disk monitoring, dashboard visualization, and alarms were configured and tested.
