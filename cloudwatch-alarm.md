# CloudWatch Alarms — Task 10

Two alarms were created for the Twenty CRM EC2 instance (`i-019ed83338e3971af`, region `us-east-1`) to monitor CPU and memory usage.

## 1. High CPU Alarm

Monitors the default `AWS/EC2` namespace metric `CPUUtilization`, dimensioned by `InstanceId`.

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "TwentyCRM-HighCPU" \
  --namespace "AWS/EC2" \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-019ed83338e3971af \
  --statistic Average \
  --period 60 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-description "Alarm when CPU exceeds 70%" \
  --region us-east-1
```

| Setting | Value |
|---|---|
| Namespace | `AWS/EC2` |
| Metric | `CPUUtilization` |
| Dimension | `InstanceId = i-019ed83338e3971af` |
| Statistic | Average |
| Period | 60 seconds |
| Threshold | > 70% |
| Evaluation periods | 2 (i.e. 2 consecutive minutes above threshold) |
| Comparison | GreaterThanThreshold |

## 2. High Memory Alarm

Monitors the custom `Twenty-CRM-EC2` namespace metric `mem_used_percent`, pushed by the CloudWatch Agent. Note this metric is dimensioned by `host` (the instance's hostname), not `InstanceId` — that's how the CloudWatch Agent tags its own custom metrics.

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "TwentyCRM-HighMemory" \
  --namespace "Twenty-CRM-EC2" \
  --metric-name mem_used_percent \
  --dimensions Name=host,Value=ip-172-31-21-200 \
  --statistic Average \
  --period 60 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-description "Alarm when memory exceeds 80%" \
  --region us-east-1
```

| Setting | Value |
|---|---|
| Namespace | `Twenty-CRM-EC2` (custom, via CloudWatch Agent) |
| Metric | `mem_used_percent` |
| Dimension | `host = ip-172-31-21-200` |
| Statistic | Average |
| Period | 60 seconds |
| Threshold | > 80% |
| Evaluation periods | 2 (i.e. 2 consecutive minutes above threshold) |
| Comparison | GreaterThanThreshold |

## Verifying the Alarms

```bash
aws cloudwatch describe-alarms \
  --alarm-names "TwentyCRM-HighCPU" "TwentyCRM-HighMemory" \
  --region us-east-1
```

## Result

Both alarms were confirmed working during load testing with `stress-ng`:
- `TwentyCRM-HighCPU` transitioned from `OK` → `INSUFFICIENT_DATA` (on creation) → `ALARM` (during a `stress-ng --cpu 2` run) → `OK` (a few minutes after the load stopped).
- `TwentyCRM-HighMemory` remained `OK` under normal load, ready to trigger under the same pattern during a `stress-ng --vm` memory-spike run.