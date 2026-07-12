# Lessons Learned

This document captures the practical lessons learned while designing, deploying, testing, and troubleshooting this AWS infrastructure project.

Rather than documenting only successful deployments, it records real implementation challenges, observations, and production best practices. These lessons reflect the engineering process followed during the project and reinforce operational thinking.

---

# Lesson 1 – Launch Template Versions Matter

## What Happened

A new Launch Template version was created, but the Auto Scaling Group continued using the previous version.

## Root Cause

The Auto Scaling Group was still referencing an older Launch Template version.

## Resolution

* Updated the Launch Template version reference.
* Applied the Terraform changes.
* Performed an Instance Refresh so existing instances adopted the new Launch Template.

## Key Learning

Creating a new Launch Template version alone does not update running instances. The Auto Scaling Group must reference the correct version, and existing instances must be refreshed or replaced.

## Production Best Practice

* Use versioned Launch Templates.
* Test changes in lower environments.
* Perform controlled Instance Refresh operations during maintenance windows where appropriate.

---

# Lesson 2 – Application Health Is Different from EC2 Health

## What Happened

The EC2 instance remained in the **Running** state, but the Target Group marked it as unhealthy.

## Root Cause

The Apache (`httpd`) service was intentionally stopped.

## Resolution

* Reviewed Target Group health.
* Confirmed CloudWatch alarm activation.
* Observed Auto Scaling replace the unhealthy instance.

## Key Learning

An EC2 instance can be healthy while the application running on it is unavailable.

Infrastructure monitoring alone is not sufficient.

## Production Best Practice

Always implement application-level health checks in addition to infrastructure health monitoring.

---

# Lesson 3 – CloudWatch Alarms May Initially Show "Insufficient Data"

## What Happened

The Unhealthy Target alarm displayed **Insufficient Data** immediately after deployment.

## Root Cause

CloudWatch had not yet collected enough datapoints to evaluate the metric.

## Resolution

Waited for metric collection and verified the alarm transitioned to **OK** without requiring configuration changes.

## Key Learning

"Insufficient Data" is often expected after alarm creation and does not necessarily indicate a configuration problem.

## Production Best Practice

Allow sufficient time for metric collection before troubleshooting newly created alarms.

---

# Lesson 4 – Validate Monitoring End-to-End

## What Happened

Monitoring was tested by stopping the Apache service.

## Validation Results

* Target Group marked the instance unhealthy.
* CloudWatch alarm entered the ALARM state.
* Amazon SNS delivered an email notification.
* Auto Scaling launched a replacement instance.
* Alarm returned to OK after recovery.

## Key Learning

Creating alarms is not enough.

Monitoring must be validated through controlled failure testing.

## Production Best Practice

Regularly test alerting and recovery mechanisms as part of operational readiness exercises.

---

# Lesson 5 – Auto Scaling Restores Capacity, Not Root Cause

## What Happened

Auto Scaling launched a replacement instance after the application failed.

## Observation

Availability was restored, but the underlying reason why the original service failed still required investigation.

## Key Learning

Auto Scaling maintains service capacity but does not diagnose or correct application defects.

## Production Best Practice

Treat Auto Scaling as a resilience mechanism, not a substitute for root cause analysis.

---

# Lesson 6 – Terraform Remote State Improves Team Collaboration

## What Happened

The project initially used a local Terraform state before migrating to an Amazon S3 backend with DynamoDB state locking.

## Key Learning

Remote state enables consistent collaboration and prevents concurrent modifications.

## Production Best Practice

Use remote state with locking for all shared Terraform environments.

---

# Lesson 7 – WAF Deployment Should Be Validated

## What Happened

AWS WAF was associated with the Application Load Balancer and validated using basic test requests.

## Key Learning

Deploying a Web ACL is only the first step. Rule behavior should be verified before relying on it in production.

## Production Best Practice

Enable logging where appropriate, monitor rule actions, and tune managed or custom rules to reduce false positives.

---

# Lesson 8 – Health Check Configuration Is Critical

## What Happened

Target Group health checks were configured with appropriate intervals, timeouts, and healthy/unhealthy thresholds.

## Observation

Stopping the application service caused the Target Group to detect the failure and remove the instance from service.

## Key Learning

Health check configuration directly affects recovery time and application availability.

## Production Best Practice

Review health check settings periodically to balance rapid failure detection with stability.

---

# Lesson 9 – SNS Notifications Must Be Confirmed

## What Happened

Email notifications were not available until the SNS subscription was confirmed.

## Key Learning

Infrastructure deployment alone does not complete the notification workflow. Subscription confirmation is an operational requirement.

## Production Best Practice

Include notification validation as part of deployment verification.

---

# Lesson 10 – Test Before Declaring Success

## What Happened

Each major feature was validated after deployment instead of assuming success because Terraform completed successfully.

## Examples

* Generated traffic to validate CloudWatch dashboards.
* Stopped the Apache service to test health checks.
* Verified Auto Scaling replacement behavior.
* Confirmed CloudWatch alarm transitions.
* Validated SNS email notifications.
* Tested WAF association.

## Key Learning

Successful infrastructure deployment does not guarantee successful application operation.

## Production Best Practice

Every deployment should include functional validation, operational validation, and monitoring verification.

---

# Overall Takeaways

This project reinforced several important engineering principles:

* Infrastructure as Code improves consistency and repeatability.
* High availability depends on architecture, monitoring, and automation working together.
* Monitoring should be validated through controlled testing.
* Security should be implemented in layers rather than relying on a single control.
* Cost optimization requires balancing efficiency with resilience and business requirements.
* Root cause analysis remains essential even in highly automated environments.
* Operational readiness is achieved through testing, observation, and continuous improvement—not infrastructure deployment alone.

---

# Final Reflection

This project evolved beyond a Terraform exercise into a production-style AWS implementation.

The most valuable outcomes were not simply the AWS resources that were created, but the practical understanding gained by troubleshooting issues, validating recovery mechanisms, evaluating architectural trade-offs, and documenting lessons learned.

Those experiences are directly applicable to real-world cloud engineering and Cloud Architect responsibilities.
