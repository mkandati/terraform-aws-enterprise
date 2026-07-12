# Production Incident Scenarios

This document contains realistic production incidents that a Cloud Architect or Senior DevOps Engineer may encounter while operating AWS environments.

Each scenario includes:

* Symptoms
* Investigation
* Root Cause
* Resolution
* Lessons Learned
* Production Best Practices

The scenarios are based on the architecture implemented in this project and expanded to reflect enterprise operational practices.

---

# Incident 1

## Users report that the application is unavailable.

### Symptoms

* Website is inaccessible.
* EC2 instances are running.
* Auto Scaling Group shows the desired number of instances.
* CloudWatch reports no EC2 status check failures.

### Investigation

1. Check the Application Load Balancer.
2. Review Target Group health.
3. Verify the web server process.
4. Check Security Groups.
5. Review CloudWatch alarms.
6. Examine application logs.

### Root Cause

The Apache (`httpd`) service stopped unexpectedly.

Although the EC2 instance remained in the **Running** state, the ALB marked it as unhealthy because the application was no longer responding to health checks.

### Resolution

* Restart the Apache service if appropriate.
* Investigate why the service stopped.
* Review application logs.
* If recovery fails, allow the Auto Scaling Group to replace the instance.

### Lessons Learned

Infrastructure health and application health are different.

An EC2 instance can be healthy while the application running on it is unavailable.

---

# Incident 2

## Auto Scaling keeps launching replacement instances.

### Symptoms

* New EC2 instances are launched repeatedly.
* Instances never remain healthy.
* Target Group shows continuous failures.

### Investigation

1. Review User Data execution.
2. Check application startup logs.
3. Verify Security Groups.
4. Confirm the health check path.
5. Review Launch Template configuration.

### Root Cause

Possible causes include:

* Broken User Data script
* Incorrect application configuration
* Invalid AMI
* Incorrect health check path

### Resolution

Correct the underlying configuration issue before allowing additional replacements.

Repeated replacement without fixing the cause increases cost without restoring service.

### Lessons Learned

Auto Scaling restores capacity—not application correctness.

---

# Incident 3

## ALB Target Group shows one unhealthy target.

### Symptoms

* One target is unhealthy.
* Website still responds.
* CloudWatch Alarm enters the ALARM state.
* SNS notification is received.

### Investigation

1. Verify the application service.
2. Review Target Group health details.
3. Check application logs.
4. Compare the unhealthy instance with the healthy instance.

### Root Cause

The application process stopped on one instance.

### Resolution

Restore the application or replace the instance if necessary.

### Lessons Learned

Multi-Availability Zone deployment prevented a customer-visible outage.

---

# Incident 4

## CloudWatch Alarm remains in "Insufficient Data."

### Symptoms

* Alarm never changes to OK or ALARM.
* Metric graph appears empty.

### Investigation

1. Confirm the metric exists.
2. Verify the namespace.
3. Check the alarm period.
4. Wait for sufficient datapoints.
5. Validate the resource is actively publishing metrics.

### Root Cause

Insufficient metric datapoints immediately after alarm creation.

### Resolution

Allow CloudWatch to collect enough data before evaluating the alarm.

### Lessons Learned

"Insufficient Data" is often a normal initial state rather than an indication of misconfiguration.

---

# Incident 5

## CloudWatch Dashboard suddenly shows a spike in Request Count.

### Symptoms

* ALB Request Count increases sharply.
* CPU utilization remains stable.

### Investigation

1. Confirm whether traffic is expected.
2. Review ALB access logs (if enabled).
3. Examine WAF metrics.
4. Check Auto Scaling activity.
5. Review HTTP status codes.

### Root Cause

Possible causes include:

* Marketing campaign
* Scheduled load testing
* Automated health checks
* Malicious traffic

### Resolution

Determine whether scaling is required or whether traffic filtering should be adjusted.

### Lessons Learned

Not every traffic spike is an attack, and not every attack causes high CPU utilization.

---

# Incident 6

## SNS notifications are not being received.

### Symptoms

* CloudWatch Alarm enters the ALARM state.
* No email notification is received.

### Investigation

1. Verify the SNS subscription is confirmed.
2. Confirm the alarm action references the correct SNS topic.
3. Check subscription status.
4. Test SNS independently.

### Root Cause

The email subscription was never confirmed.

### Resolution

Confirm the subscription and retest the notification flow.

### Lessons Learned

Always validate alert delivery—not just alarm creation.

---

# Incident 7

## Terraform reports configuration drift.

### Symptoms

* `terraform plan` shows unexpected changes.
* No Terraform code was modified.

### Investigation

1. Review recent AWS Console activity.
2. Compare Terraform configuration with deployed resources.
3. Review CloudTrail for manual changes.

### Root Cause

A resource was modified directly in the AWS Console.

### Resolution

Determine whether the manual change should be retained.

* If yes, update Terraform.
* If no, allow Terraform to reconcile the infrastructure.

### Lessons Learned

Terraform should remain the single source of truth.

---

# Incident 8

## Users receive HTTP 502 Bad Gateway errors.

### Symptoms

* ALB is reachable.
* EC2 instances are running.
* Application fails intermittently.

### Investigation

1. Review Target Group health.
2. Check application logs.
3. Verify backend port configuration.
4. Review web server logs.
5. Confirm application startup completed successfully.

### Root Cause

The backend application failed to return valid responses.

### Resolution

Correct the application issue and verify successful health checks before returning traffic.

### Lessons Learned

Load balancers route traffic—they do not repair application failures.

---

# Incident 9

## CPU utilization reaches 90%, but Auto Scaling does not launch new instances.

### Symptoms

* High CPU utilization persists.
* Desired capacity remains unchanged.

### Investigation

1. Review scaling policy configuration.
2. Check CloudWatch metrics.
3. Verify maximum capacity.
4. Review scaling activity history.
5. Confirm cooldown or warm-up settings.

### Root Cause

Possible causes include:

* Maximum capacity already reached
* Incorrect scaling policy
* Metric threshold not met over the required evaluation period

### Resolution

Adjust scaling policies or increase maximum capacity after validating the workload.

### Lessons Learned

Scaling behavior depends on policy configuration, not just instantaneous CPU values.

---

# Incident 10

## A replacement EC2 instance launches but never joins the Target Group.

### Symptoms

* Auto Scaling launches a new instance.
* Target Group continues showing fewer healthy targets than expected.

### Investigation

1. Verify User Data completed successfully.
2. Confirm the web server started.
3. Review Security Groups.
4. Check the Target Group health check path and port.
5. Examine instance system logs.

### Root Cause

The application failed to start because the User Data script encountered an error.

### Resolution

Correct the User Data script, create a new Launch Template version, update the Auto Scaling Group, and perform an Instance Refresh if required.

### Lessons Learned

User Data should be tested thoroughly because every replacement instance depends on it.

---

**Next Section**

Part 2 introduces more advanced enterprise incidents, including networking failures, security events, cost anomalies, IAM issues, deployment failures, and multi-service troubleshooting scenarios.
# Production Incident Scenarios (Part 2)

---

# Incident 11

## Private EC2 instances suddenly lose internet connectivity.

### Symptoms

* Package updates fail.
* AWS CLI calls to public AWS endpoints fail.
* Session Manager may continue working if VPC Endpoints are configured, otherwise it may also fail.
* Application continues serving requests through the ALB.

### Investigation

1. Check the NAT Gateway status.
2. Verify the private route table.
3. Confirm the default route (`0.0.0.0/0`) points to the NAT Gateway.
4. Verify the NAT Gateway Elastic IP.
5. Review Network ACLs and Security Groups.

### Root Cause

The NAT Gateway was deleted or became unavailable.

### Resolution

* Restore or recreate the NAT Gateway.
* Update route tables if required.
* Validate outbound connectivity.

### Lessons Learned

Inbound application traffic and outbound internet connectivity are independent. Losing outbound access does not necessarily make the application unavailable immediately.

---

# Incident 12

## ALB returns HTTP 503 Service Unavailable.

### Symptoms

* ALB is reachable.
* Every request returns HTTP 503.
* Target Group contains no healthy targets.

### Investigation

1. Check Target Group health.
2. Verify the application is running.
3. Review health check configuration.
4. Confirm Security Group rules.
5. Review Auto Scaling activity.

### Root Cause

No healthy backend instances are available.

### Resolution

Restore application health before troubleshooting the ALB itself.

### Lessons Learned

An ALB cannot route requests if no healthy targets exist.

---

# Incident 13

## Auto Scaling Group cannot launch new instances.

### Symptoms

* Desired capacity is not achieved.
* Scaling activities fail.
* Replacement instances are never created.

### Investigation

1. Review Auto Scaling activity history.
2. Check EC2 service quotas.
3. Verify subnet IP availability.
4. Review IAM permissions.
5. Confirm Launch Template configuration.

### Root Cause

Common causes include:

* Instance quota reached
* No available IP addresses
* Invalid Launch Template
* Missing IAM permissions

### Resolution

Resolve the underlying resource or configuration issue before retrying.

### Lessons Learned

Always review scaling activity before assuming Auto Scaling is malfunctioning.

---

# Incident 14

## Terraform cannot acquire the state lock.

### Symptoms

Terraform displays:

"The state lock is already held."

### Investigation

1. Verify another deployment is not currently running.
2. Review the DynamoDB lock entry.
3. Confirm the previous deployment completed successfully.
4. Investigate whether the lock is stale.

### Root Cause

Another Terraform operation is using the remote state, or a stale lock remains after an interrupted operation.

### Resolution

Only remove a stale lock after confirming that no active Terraform process is running.

### Lessons Learned

Never forcefully remove state locks without verification, as this can lead to state corruption.

---

# Incident 15

## Terraform reports Access Denied when accessing the backend.

### Symptoms

* `terraform init` fails.
* Backend initialization cannot complete.

### Investigation

1. Verify IAM permissions.
2. Confirm S3 bucket policy.
3. Check DynamoDB permissions.
4. Review AWS credentials.

### Root Cause

The Terraform execution role lacks sufficient permissions for the backend resources.

### Resolution

Grant only the required permissions to access the S3 backend and DynamoDB lock table.

### Lessons Learned

Protect backend resources using least privilege while ensuring Terraform has the permissions it requires.

---

# Incident 16

## Session Manager cannot connect to an EC2 instance.

### Symptoms

* The instance appears online.
* Session Manager connection fails.

### Investigation

1. Verify the IAM Role.
2. Confirm the SSM Agent is running.
3. Review outbound connectivity.
4. Check Systems Manager registration.
5. Verify VPC Endpoints or NAT connectivity if required.

### Root Cause

Possible causes include:

* Missing IAM policy
* Stopped SSM Agent
* No outbound connectivity
* Registration failure

### Resolution

Restore Systems Manager connectivity before attempting administrative access.

### Lessons Learned

Session Manager depends on both IAM configuration and network connectivity.

---

# Incident 17

## WAF blocks legitimate customer requests.

### Symptoms

* Users receive HTTP 403 responses.
* Application remains healthy.
* ALB reports normal target health.

### Investigation

1. Review WAF logs.
2. Identify the matching rule.
3. Confirm whether the request is malicious or legitimate.
4. Adjust rule configuration if necessary.

### Root Cause

A managed or custom WAF rule generated a false positive.

### Resolution

Tune the rule or create a targeted exception while maintaining overall protection.

### Lessons Learned

Security controls should be continuously monitored and refined.

---

# Incident 18

## Security Group changes accidentally block production traffic.

### Symptoms

* Application becomes unreachable.
* EC2 instances remain healthy.
* Target Group may begin reporting unhealthy targets.

### Investigation

1. Review recent Security Group changes.
2. Compare current rules with Terraform.
3. Validate required ports.
4. Review CloudTrail for change history.

### Root Cause

An inbound or outbound rule was removed or modified incorrectly.

### Resolution

Restore the required rules through Terraform and validate connectivity.

### Lessons Learned

Treat network security changes with the same rigor as application deployments.

---

# Incident 19

## AWS monthly bill increases by 40%.

### Investigation

1. Review AWS Cost Explorer.
2. Compare costs by service.
3. Identify new resources.
4. Review Auto Scaling history.
5. Check data transfer costs.
6. Verify NAT Gateway usage.
7. Review idle resources.

### Common Causes

* Oversized EC2 instances
* Idle Load Balancers
* Excessive NAT Gateway traffic
* Unused EBS volumes
* Scaling misconfiguration
* Snapshot growth

### Resolution

Optimize resources based on usage rather than assumptions.

### Lessons Learned

Cost optimization should be an ongoing operational activity, not a one-time exercise.

---

# Incident 20

## After deployment, the application works on one EC2 instance but fails on another.

### Symptoms

* One target is healthy.
* One target is unhealthy.
* Traffic succeeds intermittently.

### Investigation

1. Compare User Data execution.
2. Review application logs.
3. Verify installed packages.
4. Compare instance configuration.
5. Review Launch Template version.

### Root Cause

Configuration drift or a failed bootstrap process on one instance.

### Resolution

Standardize deployments using immutable infrastructure and validated Launch Templates.

### Lessons Learned

All instances within an Auto Scaling Group should be functionally identical.

---

# Incident 21

## CloudWatch Alarm never triggers despite high CPU utilization.

### Investigation

1. Verify the metric namespace.
2. Review the threshold configuration.
3. Check evaluation periods.
4. Confirm alarm state.
5. Compare actual metric values with alarm conditions.

### Root Cause

The alarm configuration did not match the expected workload pattern.

### Resolution

Adjust thresholds based on observed production behavior rather than arbitrary values.

### Lessons Learned

Monitoring thresholds should evolve with application usage patterns.

---

# Incident 22

## A deployment introduces a faulty Launch Template version.

### Symptoms

* Existing instances continue running normally.
* Newly launched instances fail.

### Investigation

1. Compare Launch Template versions.
2. Review recent changes.
3. Validate User Data.
4. Test a replacement instance.

### Root Cause

An incorrect Launch Template version was promoted.

### Resolution

Update the Auto Scaling Group to a known-good Launch Template version and perform an Instance Refresh if appropriate.

### Lessons Learned

Test Launch Template changes in lower environments before production rollout.

---

# Incident 23

## Customers report intermittent slow response times.

### Investigation

Review:

* ALB Target Response Time
* CPU utilization
* Memory utilization
* Database latency
* Network latency
* Application logs

### Root Cause

Performance bottlenecks are often application-related rather than infrastructure-related.

### Resolution

Identify and optimize the actual bottleneck before increasing infrastructure capacity.

### Lessons Learned

Scaling inefficient applications only increases cost.

---

# Incident 24

## Terraform Apply succeeds, but the application is still unavailable.

### Investigation

1. Verify infrastructure deployment.
2. Check User Data execution.
3. Confirm application startup.
4. Review Target Group health.
5. Validate Security Groups.

### Root Cause

Terraform successfully provisioned infrastructure, but application initialization failed.

### Resolution

Treat infrastructure deployment and application deployment as separate validation stages.

### Lessons Learned

Infrastructure success does not guarantee application success.

---

# Incident 25

## A major AWS Region outage occurs.

### Investigation

1. Confirm the scope of the outage.
2. Review AWS Health Dashboard.
3. Assess service impact.
4. Activate the organization's disaster recovery plan.

### Resolution

Recovery depends on the organization's architecture.

Possible approaches include:

* Multi-Region deployment
* Cross-Region backups
* DNS failover
* Database replication

### Lessons Learned

Multi-Availability Zone designs protect against AZ failures, but not full Regional outages. Regional resilience requires a dedicated disaster recovery strategy.

---

# Key Operational Principles

Across all incidents, follow a consistent approach:

1. Understand the symptoms before making changes.
2. Collect evidence from metrics, logs, and events.
3. Identify the root cause instead of treating only the symptoms.
4. Implement the least disruptive resolution.
5. Validate recovery through monitoring and testing.
6. Document the incident and capture lessons learned.
7. Introduce preventive measures to reduce recurrence.

Cloud Architects are expected to lead investigations methodically rather than making assumptions or applying changes without evidence.

---

**Next Section**

The next document focuses on **AWS Cost Optimization**, including real-world scenarios, investigation techniques, architectural trade-offs, and interview questions around controlling cloud spend while maintaining performance, security, and availability.
