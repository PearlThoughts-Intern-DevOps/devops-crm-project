Task 8: AWS Observability

Name: Nagendra Madasu
Task: Task 8 – AWS Observability
Date: 3 September 2026

1. Objective

The objective of this task is to explore AWS Observability services and understand how they are used for monitoring applications, infrastructure, logs, metrics, and traces.

The main services explored are:

Amazon CloudWatch
AWS CloudTrail
AWS X-Ray
Amazon Managed Service for Prometheus
Amazon Managed Grafana
2. Amazon CloudWatch

Amazon CloudWatch is an AWS monitoring service used to monitor applications and AWS resources.

Key Features
Metrics – Monitor CPU, network, requests, etc.
Logs – Collect and analyze application and system logs.
Alarms – Trigger alerts when metrics cross a threshold.
Dashboards – Display monitoring information visually.
Example
EC2 → CloudWatch → Metrics → Alarm → Notification

Learning: CloudWatch is mainly used for monitoring AWS infrastructure and applications.

3. AWS CloudTrail

AWS CloudTrail records activities and API calls performed in an AWS account.

It helps identify:

Who performed an action
What action was performed
When it happened
Which resource was affected
Example

If an EC2 instance is deleted, CloudTrail can help identify who deleted it and when.

Learning: CloudTrail is mainly used for auditing, security, and tracking AWS account activity.

4. AWS X-Ray

AWS X-Ray is used for tracing requests through applications and distributed services.

It helps identify:

Slow services
Application errors
Request latency
Service dependencies
Example
User → API → Service → Database
              ↓
            X-Ray

Learning: X-Ray is useful for troubleshooting microservices and distributed applications.

5. Amazon Managed Service for Prometheus

Amazon Managed Service for Prometheus is a managed monitoring service based on Prometheus.

It is commonly used for:

Kubernetes monitoring
Amazon EKS monitoring
Container metrics
Application metrics
Example
EKS → Prometheus → Metrics

Learning: Managed Prometheus is useful for monitoring Kubernetes and container environments.

6. Amazon Managed Grafana

Amazon Managed Grafana is used to create dashboards and visualize monitoring data.

It can visualize data from services such as CloudWatch and Managed Prometheus.

Example
CloudWatch
     |
Prometheus
     |
     v
Grafana Dashboard

Learning: Grafana provides a centralized visual representation of monitoring data.

7. Other AWS Observability Services

I also explored the purpose of other AWS observability-related services:

Service	Purpose
CloudWatch Application Signals	Application performance monitoring
CloudWatch Synthetics	Automated application testing
CloudWatch RUM	Real-user monitoring
Container Insights	Container monitoring
ADOT	Metrics and trace collection
OpenSearch	Log analysis and search
DevOps Guru	Operational issue detection
AWS Config	Configuration and compliance monitoring
8. Key Learnings
CloudWatch is used for metrics, logs, alarms, and dashboards.
CloudTrail is used for AWS activity auditing.
X-Ray is used for distributed tracing.
Managed Prometheus is useful for Kubernetes monitoring.
Managed Grafana is used for visualization and dashboards.
Combining metrics, logs, and traces provides better application observability.
9. Conclusion

Through this task, I explored the major AWS Observability services and understood how they help DevOps teams monitor infrastructure, applications, and cloud environments.

The main services I focused on were CloudWatch, CloudTrail, X-Ray, Managed Prometheus, and Managed Grafana.
