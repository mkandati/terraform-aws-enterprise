# AWS Cloud Architect Interview Guide

This guide is based on the implementation of the **Enterprise AWS Infrastructure using Terraform** project.

Unlike generic interview preparation material, the questions and answers in this document are aligned with the architecture that was designed, deployed, tested, and validated during this project.

The goal is to help explain not only **what** was built, but also **why** specific design decisions were made and **how** the infrastructure behaved during operational testing.

---

# Interview Strategy

When answering technical questions:

* Explain the business requirement.
* Describe the architecture.
* Explain the AWS services selected.
* Discuss design trade-offs.
* Mention production considerations.
* Share validation or troubleshooting experience.

Interviewers value practical experience more than memorized definitions.

---

# Question 1

## Tell me about your Terraform project.

### Sample Answer

I built an enterprise-inspired AWS infrastructure using Terraform with a modular Infrastructure as Code approach.

The environment includes:

* Amazon VPC
* Public and Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* IAM Roles
* EC2 Launch Templates
* Auto Scaling Group
* Application Load Balancer
* Target Groups
* CloudWatch Dashboards
* CloudWatch Alarms
* Amazon SNS
* AWS WAF

Terraform remote state is stored in Amazon S3 with DynamoDB state locking.

The infrastructure was deployed across multiple Availability Zones and validated through operational testing, including Auto Scaling recovery, CloudWatch monitoring, SNS notifications, and WAF integration.

---

# Question 2

## Why did you choose Terraform?

### Sample Answer

Terraform provides a declarative approach to Infrastructure as Code.

Key advantages include:

* Version-controlled infrastructure
* Repeatable deployments
* Reduced manual configuration
* Easier change management
* Reusable modules
* Multi-cloud support
* State management

For this project, Terraform modules improved maintainability and allowed individual infrastructure components to be developed independently.

---

# Question 3

## Why did you create separate Terraform modules?

### Sample Answer

Each module has a single responsibility.

Examples include:

* VPC
* Subnets
* Security Groups
* IAM
* Auto Scaling
* Load Balancer
* CloudWatch
* WAF

This modular approach improves readability, simplifies maintenance, enables code reuse, and allows teams to work on different infrastructure components independently.

---

# Question 4

## Why are your EC2 instances deployed in private subnets?

### Sample Answer

The application servers do not require direct internet access.

Instead:

* Users connect to the Application Load Balancer.
* The ALB forwards requests to the Target Group.
* The Target Group routes traffic to healthy EC2 instances.

This architecture reduces the attack surface because the EC2 instances have no public IP addresses and are not directly reachable from the internet.

Administrative access is provided through AWS Systems Manager Session Manager.

---

# Question 5

## How do you access your EC2 instances without SSH?

### Sample Answer

I used AWS Systems Manager Session Manager.

The EC2 instances have an IAM Role with the `AmazonSSMManagedInstanceCore` policy attached.

This provides secure shell access without:

* SSH keys
* Bastion hosts
* Public IP addresses
* Port 22 exposure

This approach improves security while simplifying operational management.

---

# Question 6

## Explain the request flow through your architecture.

### Sample Answer

The request flow is:

1. User accesses the Application Load Balancer.
2. The ALB receives the request.
3. Listener rules evaluate the request.
4. The Target Group selects a healthy instance.
5. The EC2 instance processes the request.
6. The response is returned through the ALB.

The ALB continuously performs health checks to ensure requests are routed only to healthy instances.

---

# Question 7

## How did you validate that Auto Scaling was working?

### Sample Answer

I intentionally stopped the Apache (`httpd`) service on one EC2 instance.

The following sequence occurred:

* The Target Group marked the instance unhealthy.
* CloudWatch generated an alarm.
* Amazon SNS sent an email notification.
* The Auto Scaling Group launched a replacement instance.
* The replacement instance passed health checks.
* The CloudWatch alarm returned to the **OK** state.

I verified that the replacement instance had a different EC2 Instance ID and was created using the current Launch Template.

---

# Question 8

## What was the biggest lesson you learned from testing Auto Scaling?

### Sample Answer

Auto Scaling restores **availability**, not necessarily the **root cause** of an incident.

Replacing an instance quickly restores service, but production teams should still investigate why the original instance became unhealthy.

For example, if the Apache service stopped due to an application bug or configuration issue, replacing the instance alone would not permanently resolve the underlying problem.

---

# Question 9

## What security measures did you implement?

### Sample Answer

The project includes multiple layers of security:

* Private EC2 instances
* IAM Roles
* Security Groups
* AWS Systems Manager Session Manager
* AWS WAF
* AWS Shield Standard
* IMDSv2
* Encrypted EBS volumes

This follows the Defense in Depth principle.

---

# Question 10

## If you were deploying this architecture for production, what would you improve?

### Sample Answer

I would enhance the architecture by adding:

* HTTPS using AWS Certificate Manager (ACM)
* Amazon Route 53 with a custom domain
* One NAT Gateway per Availability Zone
* AWS CloudTrail
* Amazon GuardDuty
* AWS Config
* AWS Security Hub
* VPC Endpoints
* AWS Secrets Manager
* CI/CD pipelines
* AWS Backup
* Multi-Region disaster recovery (where business requirements justify it)

These improvements would increase security, resiliency, governance, and operational maturity.

---

# Key Interview Tips

When discussing this project:

* Focus on architectural decisions, not just resource creation.
* Explain trade-offs between cost and resiliency.
* Describe the validation scenarios you performed.
* Highlight lessons learned from troubleshooting.
* Be honest about what was intentionally simplified for learning.

Interviewers are often more interested in your reasoning and operational understanding than in memorizing AWS service features.

---

**Next Section**

Part 2 covers Terraform interview questions, including state management, modules, lifecycle settings, dependencies, remote backends, and production best practices.
# Terraform Interview Questions

This section focuses on Terraform concepts that were directly applied in this project, along with production best practices and common follow-up questions.

---

# Question 1

## Explain the Terraform workflow.

### Expected Answer

Terraform follows a predictable workflow:

1. Write Terraform configuration files.
2. Initialize the working directory using `terraform init`.
3. Validate the configuration using `terraform validate`.
4. Review the execution plan using `terraform plan`.
5. Apply changes using `terraform apply`.
6. Destroy infrastructure when no longer required using `terraform destroy`.

This workflow ensures infrastructure changes are reviewed before deployment.

### Project Implementation

Throughout this project, every infrastructure change followed this workflow.

Examples included:

* Deploying the VPC
* Creating the Application Load Balancer
* Adding CloudWatch dashboards
* Configuring SNS notifications
* Associating AWS WAF

### Production Best Practice

Infrastructure changes are typically executed through CI/CD pipelines rather than from an engineer's workstation.

---

# Question 2

## What is the Terraform state file?

### Expected Answer

The Terraform state file records the mapping between Terraform resources and the actual infrastructure deployed in AWS.

Terraform uses the state file to:

* Track managed resources
* Detect configuration drift
* Calculate execution plans
* Perform updates safely

### Project Implementation

Initially, the project used a local state file.

Later, the backend was migrated to Amazon S3 with DynamoDB state locking.

### Production Best Practice

Never store production state files locally. Use a remote backend with locking, versioning, and restricted access.

---

# Question 3

## Why did you use Amazon S3 and DynamoDB?

### Expected Answer

Amazon S3 provides durable, centralized storage for Terraform state.

DynamoDB prevents multiple users from modifying the same state simultaneously by implementing state locking.

### Project Implementation

The project migrated from a local backend to:

* Amazon S3
* DynamoDB state locking

This prevented concurrent Terraform operations.

### Follow-up Question

**What happens if two engineers run `terraform apply` simultaneously?**

Expected response:

The second operation waits until the lock is released or fails with a lock error, preventing state corruption.

---

# Question 4

## Why did you organize the code into modules?

### Expected Answer

Modules improve:

* Reusability
* Readability
* Maintainability
* Team collaboration
* Standardization

### Project Implementation

Modules were created for:

* VPC
* Subnets
* Route Tables
* NAT Gateway
* IAM
* Security Groups
* Launch Templates
* Auto Scaling
* Application Load Balancer
* CloudWatch
* SNS
* AWS WAF

Each module manages a single responsibility.

### Production Best Practice

Organizations often maintain a centralized repository of approved Terraform modules that are reused across multiple projects.

---

# Question 5

## What is the purpose of a Launch Template?

### Expected Answer

A Launch Template defines the standard configuration for EC2 instances launched by an Auto Scaling Group.

It includes:

* AMI
* Instance type
* IAM Instance Profile
* Security Groups
* User Data
* Storage configuration
* Metadata options

### Project Implementation

The Launch Template enforced:

* Amazon Linux 2023
* IMDSv2
* Encrypted EBS
* IAM Role
* User Data
* Security Groups

### Follow-up Question

**How did you update your Launch Template?**

Expected response:

A new Launch Template version was created. The Auto Scaling Group was then updated to use the latest version, ensuring newly launched instances used the updated configuration.

---

# Question 6

## Explain resource dependencies in Terraform.

### Expected Answer

Terraform automatically determines dependencies by analyzing resource references.

For example:

* The Auto Scaling Group depends on the Launch Template.
* The ALB depends on public subnets.
* The Target Group depends on the VPC.

Terraform builds a dependency graph and provisions resources in the correct order.

### Project Implementation

Explicit dependencies were rarely required because resource references allowed Terraform to infer the correct creation order.

---

# Question 7

## What is `create_before_destroy`?

### Expected Answer

The `create_before_destroy` lifecycle rule instructs Terraform to create a replacement resource before destroying the existing one.

This minimizes downtime during updates.

### Project Implementation

The Auto Scaling Group uses:

```hcl
lifecycle {
  create_before_destroy = true
}
```

This helps avoid service interruption during infrastructure updates.

---

# Question 8

## What is `prevent_destroy`?

### Expected Answer

`prevent_destroy` prevents accidental deletion of important resources.

Terraform returns an error if an operation attempts to destroy the protected resource.

### Project Implementation

The CloudWatch Log Group uses:

```hcl
lifecycle {
  prevent_destroy = true
}
```

This protects operational logs from accidental deletion.

### Production Best Practice

Use `prevent_destroy` selectively for critical resources such as log groups, databases, and state storage.

---

# Question 9

## What is Terraform drift?

### Expected Answer

Drift occurs when infrastructure is modified outside of Terraform.

Examples:

* Changing Security Group rules manually
* Deleting AWS resources from the console
* Modifying Auto Scaling settings directly

Terraform detects drift during planning by comparing the desired configuration with the actual infrastructure.

### Production Best Practice

Limit manual changes in production and use Terraform as the single source of truth.

---

# Question 10

## How would you structure Terraform code for multiple environments?

### Expected Answer

Separate environments should have:

* Independent state files
* Environment-specific variables
* Shared reusable modules

Typical structure:

```text
modules/
environments/
   ├── dev
   ├── test
   └── prod
```

### Project Implementation

This project uses separate environment folders with reusable infrastructure modules.

---

# Common Interview Mistakes

Candidates often:

* Store state locally in production.
* Create large monolithic Terraform files.
* Hardcode resource names.
* Ignore state locking.
* Make manual console changes instead of updating Terraform.
* Skip `terraform plan` before applying changes.
* Grant overly broad IAM permissions.

Avoiding these practices demonstrates operational maturity.

---

# Rapid-Fire Terraform Questions

Be prepared to answer:

* What is a provider?
* What is a backend?
* What is a data source?
* What is a variable?
* What is an output?
* What is a local value?
* What is the difference between `count` and `for_each`?
* What is the purpose of `terraform fmt`?
* What does `terraform validate` check?
* When would you use `terraform import`?
* How do you upgrade providers safely?
* What is the difference between `terraform taint` (legacy) and `terraform apply -replace`?

---

# Production Scenario

**Scenario**

A Terraform deployment fails halfway through, leaving some resources created and others not.

**How would you respond?**

### Suggested Answer

1. Do not manually delete resources unless absolutely necessary.
2. Review the Terraform error message.
3. Run `terraform plan` to understand the current state.
4. Resolve the underlying issue (permissions, quotas, dependencies, etc.).
5. Re-run `terraform apply`.
6. If resources were created outside of Terraform's state, use `terraform import` where appropriate.
7. Verify the final infrastructure against the expected configuration.

The objective is to allow Terraform to reconcile the environment rather than introducing additional drift through manual intervention.

---

**Next Section**

Part 3 covers AWS Networking interview questions, including VPC design, subnetting, routing, NAT Gateways, Security Groups, and common architecture discussions.
# AWS Networking Interview Questions

Networking is one of the most important topics in Cloud Architect interviews. The questions below are based on the architecture implemented in this project and expanded with production considerations.

---

# Question 1

## Explain your VPC architecture.

### Expected Answer

I designed a dedicated Amazon VPC using a `/16` CIDR block.

The VPC contains:

* Two Public Subnets
* Two Private Subnets
* Internet Gateway
* NAT Gateway
* Public Route Table
* Private Route Table

The Application Load Balancer is deployed in the public subnets, while EC2 instances are deployed in private subnets across two Availability Zones.

This design provides secure network segmentation and high availability.

### Project Implementation

* VPC CIDR: `10.0.0.0/16`
* Multi-AZ deployment
* Public ALB
* Private EC2 instances

### Production Best Practice

Plan CIDR ranges carefully to accommodate future expansion, VPC peering, Transit Gateway integration, or hybrid networking without requiring readdressing.

---

# Question 2

## Why are EC2 instances deployed in private subnets?

### Expected Answer

Application servers do not require direct internet access.

Instead:

* Clients connect to the Application Load Balancer.
* The ALB forwards requests to healthy EC2 instances.
* Administrative access is performed through AWS Systems Manager Session Manager.

This reduces the attack surface by eliminating public IP addresses on application servers.

### Production Best Practice

Only components that must accept inbound internet traffic should be placed in public subnets.

---

# Question 3

## Explain the difference between a public subnet and a private subnet.

### Expected Answer

A **public subnet** has a route to an Internet Gateway, allowing resources such as an Application Load Balancer or NAT Gateway to communicate with the internet.

A **private subnet** has no direct route to the Internet Gateway. Outbound internet access is typically provided through a NAT Gateway, while inbound access is controlled through internal load balancers or other trusted services.

### Common Mistake

Many candidates incorrectly believe that assigning a public IP address alone makes a subnet public. The route table determines whether a subnet is public or private.

---

# Question 4

## Why did you use a NAT Gateway?

### Expected Answer

The EC2 instances require outbound internet access for activities such as:

* Installing operating system updates
* Downloading application packages
* Accessing AWS APIs

The NAT Gateway provides outbound connectivity while preventing unsolicited inbound connections.

### Project Implementation

The NAT Gateway is deployed in a public subnet, and the private route table directs `0.0.0.0/0` traffic to it.

### Production Best Practice

Deploy one NAT Gateway per Availability Zone to eliminate a single point of failure.

---

# Question 5

## Why did you use only one NAT Gateway?

### Expected Answer

For this learning project, a single NAT Gateway reduced cost while still demonstrating the required networking concepts.

In production, I would recommend one NAT Gateway per Availability Zone to improve resilience and avoid cross-AZ dependency for outbound traffic.

This decision reflects a cost-versus-availability trade-off rather than a technical limitation.

---

# Question 6

## Explain how a request reaches an EC2 instance.

### Expected Answer

The request flow is:

1. Client sends a request to the Application Load Balancer.
2. The Internet Gateway routes traffic to the public subnet.
3. The ALB receives the request.
4. Listener rules evaluate the request.
5. The Target Group selects a healthy EC2 instance.
6. The EC2 instance processes the request.
7. The response is returned to the client through the ALB.

### Follow-up Question

**Can the client communicate directly with the EC2 instance?**

No. The EC2 instances are located in private subnets and do not have public IP addresses.

---

# Question 7

## What is the difference between Security Groups and Network ACLs?

### Expected Answer

| Security Groups                         | Network ACLs                                |
| --------------------------------------- | ------------------------------------------- |
| Stateful                                | Stateless                                   |
| Applied to ENIs (instances, ALBs, etc.) | Applied to subnets                          |
| Supports only allow rules               | Supports allow and deny rules               |
| Return traffic is automatically allowed | Return traffic must be explicitly permitted |

### Project Implementation

Security Groups provide the primary network protection in this project. Default Network ACL behavior is retained for simplicity.

### Production Best Practice

Use Network ACLs when an additional subnet-level control is required, particularly for compliance or specialized traffic filtering.

---

# Question 8

## Explain stateful and stateless firewalls.

### Expected Answer

A **stateful firewall** tracks established connections. Once inbound traffic is permitted, the corresponding return traffic is automatically allowed.

A **stateless firewall** evaluates every packet independently. Both inbound and outbound rules must be configured explicitly.

### Examples

* Security Groups → Stateful
* Network ACLs → Stateless

---

# Question 9

## What happens if the NAT Gateway fails?

### Expected Answer

Private instances lose outbound internet connectivity.

Examples of affected operations include:

* Package downloads
* Operating system updates
* Calls to AWS public service endpoints (unless VPC Endpoints are configured)

However, inbound application traffic through the Application Load Balancer typically continues if the application is already running and healthy.

### Production Solution

Deploy one NAT Gateway per Availability Zone and configure route tables accordingly.

---

# Question 10

## Why did you use two Availability Zones?

### Expected Answer

Deploying resources across multiple Availability Zones improves fault tolerance.

If one Availability Zone experiences an outage, the remaining zone can continue serving traffic.

The Application Load Balancer distributes requests across healthy instances in both zones, while the Auto Scaling Group works to restore capacity.

---

# Production Scenario 1

## One Availability Zone becomes unavailable.

### Interview Question

How does your application behave?

### Suggested Answer

The Application Load Balancer routes traffic only to healthy instances in the remaining Availability Zone.

The Auto Scaling Group attempts to restore the desired capacity based on available resources.

If dependent services such as NAT Gateways are deployed in multiple Availability Zones, the application continues with minimal disruption.

Capacity planning remains important to ensure the surviving Availability Zone can handle the increased load.

---

# Production Scenario 2

## Users report that the application is down, but all EC2 instances are running.

### Investigation Approach

1. Check the Application Load Balancer health status.
2. Review Target Group health checks.
3. Verify the web server process (for example, `httpd`).
4. Examine CloudWatch metrics and alarms.
5. Review Security Group rules.
6. Confirm listener configuration.
7. Inspect application logs.

### Project Connection

You validated this behavior by stopping the Apache service. The EC2 instance remained running, but the Target Group marked it unhealthy and stopped routing traffic to it.

---

# Production Scenario 3

## A developer manually modifies a Security Group in the AWS Console.

### Interview Question

What happens during the next Terraform deployment?

### Suggested Answer

Terraform detects the configuration drift during `terraform plan`.

If the manual change is not reflected in the Terraform configuration, the next `terraform apply` reconciles the Security Group back to the declared state.

To avoid drift, infrastructure changes should be made through Terraform rather than directly in the AWS Console.

---

# Whiteboard Question

Design a secure network architecture for a three-tier web application.

### Strong Answer

The design would include:

* One VPC
* Public subnets for the Application Load Balancer
* Private subnets for application servers
* Private subnets for databases
* Internet Gateway
* NAT Gateways
* Separate route tables
* Security Groups enforcing least privilege
* AWS WAF
* Multi-Availability Zone deployment
* Optional VPC Endpoints for AWS services

The discussion should include security, availability, scalability, and operational considerations rather than focusing only on drawing the components.

---

# Common Interview Mistakes

Candidates often:

* Place EC2 instances in public subnets unnecessarily.
* Confuse public IP assignment with subnet type.
* Forget that Security Groups are stateful.
* Use `0.0.0.0/0` excessively.
* Overlook route tables when troubleshooting connectivity.
* Ignore the resilience implications of a single NAT Gateway.
* Focus only on resource creation instead of explaining the design rationale.

---

**Next Section**

Part 4 covers EC2, Launch Templates, Auto Scaling Groups, self-healing behavior, scaling policies, and production operational scenarios.
# EC2 and Auto Scaling Interview Questions

Amazon EC2 and Auto Scaling are fundamental services in AWS architectures. This section focuses on real operational scenarios, design decisions, and production best practices based on this project.

---

# Question 1

## Why did you use a Launch Template instead of launching EC2 instances directly?

### Expected Answer

A Launch Template provides a standardized configuration for all EC2 instances launched by the Auto Scaling Group.

It defines:

* Amazon Machine Image (AMI)
* Instance type
* Security Groups
* IAM Instance Profile
* User Data
* EBS configuration
* IMDSv2 settings
* Tags

Using a Launch Template ensures consistency and repeatability across all instances.

### Project Implementation

The Launch Template in this project includes:

* Amazon Linux 2023
* Apache installation using User Data
* IAM Role for Systems Manager
* Encrypted EBS volumes
* IMDSv2 enforcement
* Security Groups

---

# Question 2

## Why did you use an Auto Scaling Group?

### Expected Answer

The Auto Scaling Group provides:

* High availability
* Automatic recovery
* Elastic scaling
* Desired capacity management

Even when automatic scaling is not required, an Auto Scaling Group helps maintain application availability by replacing unhealthy instances.

### Project Implementation

Configured values:

* Minimum Capacity: 2
* Desired Capacity: 2
* Maximum Capacity: 3

The Auto Scaling Group spans two Availability Zones.

---

# Question 3

## What happens if one EC2 instance fails?

### Expected Answer

The sequence is:

1. Target Group health checks detect the failure.
2. The unhealthy instance is removed from load balancing.
3. The Auto Scaling Group detects that desired capacity is no longer met.
4. A replacement EC2 instance is launched using the Launch Template.
5. The new instance registers with the Target Group.
6. Once health checks pass, traffic resumes to the replacement instance.

The application remains available through the remaining healthy instance during recovery.

### Project Validation

This workflow was successfully validated by stopping the Apache (`httpd`) service on one instance.

---

# Question 4

## How did you verify that Auto Scaling was working correctly?

### Expected Answer

I performed a controlled failure test.

Steps:

1. Connected to an EC2 instance using AWS Systems Manager Session Manager.
2. Stopped the Apache service (`sudo systemctl stop httpd`).
3. Observed the Target Group mark the instance as unhealthy.
4. Received a CloudWatch alarm.
5. Received an SNS email notification.
6. Observed the Auto Scaling Group launch a replacement instance.
7. Verified the replacement instance had a new EC2 Instance ID.
8. Confirmed the Target Group returned to a healthy state.

This validated monitoring, alerting, and self-healing.

---

# Question 5

## Why didn't Auto Scaling simply restart the Apache service?

### Expected Answer

Auto Scaling manages infrastructure health, not application-level troubleshooting.

Its responsibility is to maintain the desired number of healthy instances.

If an instance fails health checks, Auto Scaling replaces it according to its health evaluation.

Root cause analysis remains the responsibility of the operations team.

### Production Best Practice

Organizations often attempt automated service recovery before replacing the instance.

Examples include:

* Restarting the web service
* Restarting the application
* Running a Systems Manager Automation document
* Executing a custom recovery script

If those actions fail, replacing the instance becomes the preferred option.

---

# Question 6

## Why did you choose a Target Tracking Scaling Policy?

### Expected Answer

Target Tracking automatically adjusts capacity to maintain a specified metric target.

In this project, the policy uses average CPU utilization.

Advantages include:

* Simpler configuration
* Automatic scale-out and scale-in
* Reduced operational effort

### Project Implementation

Target metric:

* Average CPU Utilization: 50%

---

# Question 7

## Suppose your Auto Scaling Group has three running instances and one instance becomes unhealthy. What happens?

### Expected Answer

The Auto Scaling Group first ensures the unhealthy instance is replaced to maintain the desired capacity.

If the desired capacity is already three:

* The unhealthy instance is terminated.
* A replacement instance is launched.
* Desired capacity remains three.

This replacement process is independent of CPU-based scaling policies.

### Key Point

Health replacement and dynamic scaling are separate Auto Scaling functions.

---

# Question 8

## What is the difference between scaling and self-healing?

### Expected Answer

**Self-healing**

* Triggered by failed health checks.
* Replaces unhealthy instances.
* Maintains desired capacity.

**Scaling**

* Triggered by workload metrics.
* Increases or decreases capacity.
* Responds to demand changes.

### Project Example

Stopping the Apache service demonstrated self-healing, not scaling.

Generating CPU load would demonstrate dynamic scaling.

---

# Question 9

## What happens when a new Launch Template version is created?

### Expected Answer

Creating a new Launch Template version does not automatically update existing EC2 instances.

The Auto Scaling Group must be configured to use the new version.

Existing instances continue running until:

* They are replaced,
* They are refreshed, or
* An Instance Refresh is performed.

### Project Experience

During this project, the Launch Template version changed, and the Auto Scaling Group configuration was updated to use the latest version.

This ensured future replacement instances used the updated configuration.

---

# Question 10

## How would you update all EC2 instances without downtime?

### Expected Answer

Production environments commonly use an **Instance Refresh**.

The process:

1. Create a new Launch Template version.
2. Update the Auto Scaling Group.
3. Start an Instance Refresh.
4. Instances are replaced gradually while maintaining the desired healthy capacity.

This minimizes service disruption.

---

# Production Scenario 1

## CPU utilization remains below 20%, but users report slow response times.

### Investigation Approach

Check:

* Application logs
* Memory utilization
* Disk utilization
* Database latency
* Network latency
* ALB Target Response Time
* Request Count
* HTTP error rates

### Key Point

Low CPU utilization does not necessarily indicate a healthy application.

---

# Production Scenario 2

## Auto Scaling suddenly launches the maximum number of instances.

### Investigation Steps

1. Review CloudWatch metrics.
2. Check scaling activity history.
3. Verify Target Tracking policies.
4. Examine recent deployments.
5. Review application logs.
6. Check for traffic spikes or DDoS events.
7. Confirm health checks are functioning correctly.

Scaling behavior should always be correlated with metrics before making changes.

---

# Production Scenario 3

## Every replacement instance immediately becomes unhealthy.

### Possible Causes

* Faulty User Data
* Incorrect application configuration
* Broken AMI
* Security Group misconfiguration
* Health check path returning errors
* Missing IAM permissions
* Application startup failures

### Investigation

Review:

* EC2 console output
* CloudWatch Logs
* Application logs
* User Data execution logs
* Target Group health details

---

# Whiteboard Question

Design an Auto Scaling strategy for an e-commerce application during a festival sale.

### Strong Answer

The design should include:

* Multi-AZ Auto Scaling Group
* Application Load Balancer
* Launch Templates
* Target Tracking policies
* Scheduled scaling for expected demand
* CloudWatch alarms
* SNS notifications
* Health checks
* Graceful instance warm-up
* Capacity planning
* Monitoring dashboards

The explanation should also address scaling limits, cost control, and rollback planning.

---

# Common Interview Mistakes

Candidates often:

* Confuse scaling with self-healing.
* Assume Launch Template updates affect existing instances immediately.
* Believe Auto Scaling fixes application bugs.
* Ignore health check configuration.
* Scale solely based on CPU without considering application metrics.
* Forget that desired capacity is continuously enforced.

---

# Advanced Follow-up Questions

Be prepared to discuss:

* Warm Pools
* Instance Refresh
* Lifecycle Hooks
* Mixed Instances Policy
* Spot and On-Demand combinations
* Predictive Scaling
* Scheduled Scaling
* Health Check Grace Period
* Capacity Rebalancing
* Instance Protection
* Standby mode
* Termination Policies

You are not expected to implement every feature in this project, but understanding when each is appropriate demonstrates architectural maturity.

---

# Interview Summary

This project provided practical experience with:

* Launch Templates
* Auto Scaling Groups
* Target Tracking Policies
* Health Checks
* Automated Recovery
* Multi-Availability Zone deployments
* Failure testing
* CloudWatch monitoring
* SNS notifications
* Operational validation

Being able to describe the complete failure-and-recovery sequence from your own testing is far more valuable than reciting service documentation.
# Application Load Balancer & Health Checks

The Application Load Balancer (ALB) is a Layer 7 load balancer that distributes HTTP and HTTPS traffic across multiple targets. In this project, the ALB provides high availability, health-aware routing, and a single entry point for the application.

---

# Question 1

## Why did you choose an Application Load Balancer instead of a Network Load Balancer?

### Expected Answer

The application serves HTTP traffic, making an Application Load Balancer the most suitable choice.

Benefits include:

* Layer 7 routing
* Host-based routing
* Path-based routing
* HTTP/HTTPS support
* Integration with AWS WAF
* Target Group health checks

A Network Load Balancer is typically preferred for Layer 4 (TCP/UDP) workloads requiring extremely low latency or static IP addresses.

### Project Implementation

The project uses:

* HTTP Listener (Port 80)
* Target Group
* Health Checks
* AWS WAF association

---

# Question 2

## Explain the request flow through your ALB.

### Expected Answer

The request flow is:

1. Client sends an HTTP request.
2. The Internet Gateway routes traffic to the public subnet.
3. The Application Load Balancer receives the request.
4. Listener rules evaluate the request.
5. The Target Group selects a healthy EC2 instance.
6. The EC2 instance processes the request.
7. The response is returned to the client through the ALB.

The client never communicates directly with the EC2 instances.

---

# Question 3

## What is a Target Group?

### Expected Answer

A Target Group is a logical collection of compute resources that receive traffic from a load balancer.

It is responsible for:

* Registering targets
* Performing health checks
* Routing requests only to healthy targets
* Reporting target health status

### Project Implementation

The Target Group contains the EC2 instances launched by the Auto Scaling Group.

---

# Question 4

## Explain your health check configuration.

### Expected Answer

The Target Group periodically checks whether each EC2 instance is capable of serving requests.

Current configuration:

| Parameter           |      Value |
| ------------------- | ---------: |
| Interval            | 30 seconds |
| Timeout             |  5 seconds |
| Healthy Threshold   |          3 |
| Unhealthy Threshold |          2 |

This configuration reduces false positives while allowing failed instances to be detected quickly.

---

# Question 5

## What happens if a health check fails?

### Expected Answer

The sequence is:

1. The Target Group marks the instance as unhealthy.
2. The ALB stops routing new requests to that instance.
3. CloudWatch metrics reflect the unhealthy target.
4. CloudWatch Alarm transitions to the ALARM state.
5. Amazon SNS sends an email notification.
6. The Auto Scaling Group replaces the unhealthy instance.

### Project Validation

This behavior was validated by stopping the Apache (`httpd`) service during testing.

---

# Question 6

## Why did the EC2 instance remain running even though the ALB marked it unhealthy?

### Expected Answer

The ALB evaluates **application health**, not **instance power state**.

An EC2 instance can remain in the **Running** state while:

* The web server has stopped.
* The application has crashed.
* The health check endpoint returns HTTP 500.
* A firewall blocks application traffic.

The ALB routes traffic based on health check results rather than EC2 instance status.

---

# Question 7

## What is Cross-Zone Load Balancing?

### Expected Answer

Cross-Zone Load Balancing allows the ALB to distribute traffic evenly across healthy targets in all enabled Availability Zones, regardless of which Availability Zone initially receives the client request.

### Benefits

* Better traffic distribution
* Improved resource utilization
* More consistent application performance

### Production Best Practice

Leave Cross-Zone Load Balancing enabled unless a specific design requires otherwise.

---

# Question 8

## What are Sticky Sessions?

### Expected Answer

Sticky Sessions (session affinity) cause a client to continue communicating with the same backend instance for a configurable period using cookies.

### Advantages

* Session persistence
* Simplified legacy application support

### Disadvantages

* Uneven traffic distribution
* Reduced scalability
* Harder failover

### Production Recommendation

Stateless application design is generally preferred over Sticky Sessions whenever possible.

---

# Question 9

## Why is the ALB deployed in public subnets?

### Expected Answer

The ALB must accept requests from internet clients.

Public subnets provide:

* A route to the Internet Gateway
* Public accessibility
* Integration with AWS WAF

The EC2 instances remain in private subnets.

---

# Question 10

## How would you migrate from HTTP to HTTPS?

### Expected Answer

The migration steps are:

1. Request or import an SSL/TLS certificate using AWS Certificate Manager (ACM).
2. Create an HTTPS listener on port 443.
3. Associate the certificate with the ALB.
4. Redirect HTTP (port 80) traffic to HTTPS.
5. Update DNS records if required.
6. Validate certificate and application functionality.

### Production Best Practice

Expose only HTTPS to end users and redirect all HTTP traffic to HTTPS.

---

# Production Scenario 1

## Users report intermittent failures.

### Investigation Approach

Review:

* Target Group health
* ALB metrics
* HTTP 5xx errors
* Application logs
* CloudWatch metrics
* Security Groups
* Auto Scaling activity

Determine whether the issue is isolated to one target or affects the entire application.

---

# Production Scenario 2

## Every target shows as unhealthy.

### Possible Causes

* Incorrect health check path
* Application not running
* Wrong port
* Security Group rules
* Application startup failure
* Target Group configuration mismatch

### Investigation

Check:

* Health check endpoint
* Web server status
* Target Group settings
* Security Group configuration
* EC2 application logs

---

# Production Scenario 3

## ALB is healthy, but users receive HTTP 502 errors.

### Possible Causes

* Backend application crashes
* Incorrect application port
* Reverse proxy issues
* Application timeout
* Malformed backend responses

### Investigation

Review:

* ALB access logs (if enabled)
* Application logs
* Web server logs
* Target response time metrics

---

# Whiteboard Question

Design an internet-facing web application using an Application Load Balancer.

### Strong Answer

The design should include:

* Application Load Balancer
* Public subnets
* Internet Gateway
* Target Group
* Auto Scaling Group
* Private EC2 instances
* Security Groups
* AWS WAF
* CloudWatch monitoring
* SNS notifications

Explain how requests flow through each component and how failures are detected and handled.

---

# Common Interview Mistakes

Candidates often:

* Confuse Target Groups with Auto Scaling Groups.
* Assume an EC2 instance must stop running before the ALB marks it unhealthy.
* Forget that health checks evaluate the application rather than the EC2 instance itself.
* Place the ALB in private subnets for an internet-facing application.
* Ignore health check tuning and its impact on recovery time.

---

# Advanced Follow-up Questions

Be prepared to discuss:

* Listener Rules
* Path-Based Routing
* Host-Based Routing
* HTTP to HTTPS redirects
* WebSockets support
* Idle Timeout configuration
* Access Logs
* Target Types (Instance, IP, Lambda)
* Deregistration Delay
* Slow Start mode
* Connection Draining

---

# Interview Summary

Through this project, you gained practical experience with:

* Application Load Balancer deployment
* Target Group configuration
* Health check tuning
* Traffic routing
* Failure detection
* Auto Scaling integration
* CloudWatch monitoring
* SNS notifications
* AWS WAF integration

The most valuable takeaway is understanding that the ALB makes routing decisions based on **application health**, not simply whether an EC2 instance is powered on.

# CloudWatch, Monitoring & SNS Interview Questions

Monitoring is a core responsibility of Cloud Architects and Operations Engineers. This section focuses on designing observable systems, detecting failures, and enabling rapid incident response.

---

# Question 1

## Why is monitoring important in cloud environments?

### Expected Answer

Monitoring provides visibility into infrastructure and application health.

It enables teams to:

* Detect failures early
* Measure performance
* Trigger automated responses
* Notify operations teams
* Support troubleshooting
* Improve availability

Without monitoring, failures are often discovered only after users report them.

---

# Question 2

## What CloudWatch components did you implement?

### Expected Answer

The project includes:

* CloudWatch Dashboard
* CloudWatch Metrics
* CloudWatch Alarms
* CloudWatch Log Group
* Amazon SNS Notifications

These components provide both visualization and automated alerting.

### Project Implementation

Implemented monitoring includes:

* ALB Request Count Dashboard
* EC2 CPU Utilization Alarm
* Unhealthy Target Alarm
* SNS Email Notifications
* CloudWatch Log Group with retention policy

---

# Question 3

## Explain the difference between CloudWatch Metrics, Dashboards, and Alarms.

### Expected Answer

**Metrics**

Numerical data representing resource performance over time.

Examples:

* CPU Utilization
* Request Count
* Network Traffic

---

**Dashboards**

Visual representations of multiple metrics.

Purpose:

* Operational visibility
* Infrastructure monitoring
* Performance analysis

---

**Alarms**

Evaluate metrics against thresholds.

Actions may include:

* Sending SNS notifications
* Triggering Auto Scaling
* Invoking Lambda functions

---

# Question 4

## What CloudWatch alarms did you configure?

### Expected Answer

Configured alarms include:

* High EC2 CPU Utilization
* Unhealthy Target Count

Each alarm sends notifications through Amazon SNS.

### Project Validation

Alarm behavior was validated by:

* Generating application traffic
* Stopping the Apache (`httpd`) service
* Observing alarm transitions
* Confirming SNS email delivery

---

# Question 5

## Why did one of your alarms initially show "Insufficient Data"?

### Expected Answer

CloudWatch Alarms require sufficient metric data before evaluating alarm conditions.

Immediately after creation, the alarm may display **Insufficient Data** until enough datapoints have been collected.

In this project, the Unhealthy Target alarm initially showed **Insufficient Data** before transitioning to **OK** once health check metrics became available.

### Interview Tip

Do not immediately assume an alarm configuration is incorrect when you see this state.

---

# Question 6

## How did you validate your monitoring configuration?

### Expected Answer

I performed multiple validation exercises.

Dashboard validation:

* Generated HTTP requests.
* Observed increased ALB Request Count.

Alarm validation:

* Stopped the Apache service.
* Observed Target Group health failure.
* Confirmed CloudWatch Alarm transitioned to **ALARM**.

Notification validation:

* Received Amazon SNS email.
* Confirmed recovery notification after Auto Scaling restored service.

This validated the complete monitoring workflow.

---

# Question 7

## What is Amazon SNS?

### Expected Answer

Amazon SNS (Simple Notification Service) is a managed messaging service used to distribute notifications to multiple subscribers.

Common endpoints include:

* Email
* SMS
* AWS Lambda
* Amazon SQS
* HTTPS endpoints

### Project Implementation

The project uses SNS email subscriptions for CloudWatch alarm notifications.

---

# Question 8

## How would you design monitoring for a production application?

### Expected Answer

Monitoring should include multiple layers.

Infrastructure:

* CPU
* Memory (via CloudWatch Agent)
* Disk utilization
* Network traffic

Application:

* Response time
* Error rates
* HTTP 5xx responses
* Request latency

Platform:

* ALB metrics
* Auto Scaling metrics
* Database metrics
* Queue depth

Security:

* WAF metrics
* CloudTrail events
* GuardDuty findings

Business:

* Login success rate
* Orders processed
* Payment failures

The objective is to monitor both technical health and business outcomes.

---

# Question 9

## What would you log in production?

### Expected Answer

Infrastructure logs:

* System logs
* Auto Scaling activity
* CloudTrail

Application logs:

* Errors
* Warnings
* Request logs
* Startup logs

Security logs:

* Authentication events
* Authorization failures
* WAF logs

Audit logs:

* Administrative actions
* Configuration changes

Centralized logging simplifies troubleshooting and compliance.

---

# Question 10

## Why didn't you monitor memory utilization?

### Expected Answer

By default, CloudWatch provides CPU, network, disk I/O, and status check metrics for EC2 instances.

Memory utilization requires the CloudWatch Agent to be installed and configured on the instance.

### Production Best Practice

Install the CloudWatch Agent to collect:

* Memory utilization
* Disk usage
* File system metrics
* Process-level metrics

---

# Production Scenario 1

## CPU utilization remains low, but users report poor application performance.

### Investigation Approach

Review:

* Memory utilization
* Disk utilization
* Application logs
* ALB Target Response Time
* HTTP error rates
* Database performance
* Network latency

CPU is only one indicator of system health.

---

# Production Scenario 2

## No CloudWatch alarm was triggered, but the application became unavailable.

### Possible Causes

* No alarm configured for that failure mode
* Incorrect threshold
* Missing metric
* Monitoring only infrastructure instead of the application
* Alarm disabled

### Lesson

Effective monitoring requires selecting meaningful metrics that align with business and operational requirements.

---

# Production Scenario 3

## Operations receives hundreds of alarm emails every hour.

### Investigation

Determine:

* Which alarms are triggering
* Whether thresholds are too sensitive
* Whether duplicate alarms exist
* Whether alerts are actionable

### Production Solution

Reduce alert fatigue by:

* Tuning thresholds
* Consolidating alarms
* Prioritizing critical events
* Escalating only actionable incidents

---

# Production Scenario 4

## CloudWatch Dashboard shows a sudden spike in ALB Request Count.

### Investigation Steps

1. Confirm whether traffic is expected.
2. Review Auto Scaling activity.
3. Check CPU utilization.
4. Review HTTP status codes.
5. Examine WAF metrics.
6. Determine whether the spike is legitimate traffic or a potential attack.

### Project Connection

You manually generated requests and observed the Request Count spike on the dashboard, confirming that metrics were being collected and visualized correctly.

---

# Whiteboard Question

Design a monitoring solution for an online banking application.

### Strong Answer

Include:

Infrastructure Monitoring

* EC2
* ALB
* RDS
* Auto Scaling
* NAT Gateway

Application Monitoring

* API latency
* Authentication failures
* Transaction failures
* Payment success rate

Security Monitoring

* WAF metrics
* CloudTrail
* GuardDuty
* Security Hub

Notifications

* SNS
* Incident management platform (for example, PagerDuty or ServiceNow)

Dashboards

* Executive dashboard
* Operations dashboard
* Security dashboard

The explanation should emphasize proactive monitoring and rapid incident response.

---

# Common Interview Mistakes

Candidates often:

* Monitor only CPU utilization.
* Ignore application metrics.
* Create excessive alarms that cause alert fatigue.
* Assume dashboards replace alarms.
* Forget that CloudWatch does not collect memory metrics by default.
* Treat monitoring as an afterthought rather than part of the architecture.

---

# Advanced Follow-up Questions

Be prepared to discuss:

* CloudWatch Agent
* Metric Filters
* Composite Alarms
* EventBridge integration
* Log Insights
* CloudWatch Contributor Insights
* Cross-account dashboards
* Embedded Metric Format (EMF)
* CloudWatch Anomaly Detection
* Metric Streams

---

# Interview Summary

This project provided practical experience with:

* CloudWatch Dashboards
* CloudWatch Metrics
* CloudWatch Alarms
* Amazon SNS
* Operational monitoring
* Infrastructure visualization
* Alert validation
* Failure testing
* Alarm lifecycle (OK → ALARM → OK)

The monitoring implementation was validated through real operational testing rather than relying solely on successful resource deployment.

# Security Interview Questions

Security is a foundational responsibility for Cloud Architects. This project implements multiple layers of protection using AWS security services and follows the principle of Defense in Depth.

---

# Question 1

## Explain the security architecture of your project.

### Expected Answer

The infrastructure uses multiple security layers rather than relying on a single control.

Implemented security measures include:

* Private EC2 instances
* Application Load Balancer in public subnets
* Security Groups
* IAM Roles
* AWS Systems Manager Session Manager
* AWS WAF
* AWS Shield Standard
* IMDSv2 enforcement
* Encrypted EBS volumes

Each component protects against different categories of threats.

---

# Question 2

## Why did you use IAM Roles instead of Access Keys?

### Expected Answer

IAM Roles provide temporary credentials that are automatically rotated by AWS.

Advantages include:

* No hardcoded credentials
* Automatic credential rotation
* Reduced credential exposure
* Easier permission management

### Project Implementation

The EC2 instances use an IAM Role with the required permissions for AWS Systems Manager.

---

# Question 3

## Why did you use Systems Manager Session Manager instead of SSH?

### Expected Answer

Session Manager eliminates the need for:

* Public IP addresses
* SSH keys
* Bastion Hosts
* Port 22 exposure

Benefits include:

* Encrypted management sessions
* IAM-based access control
* Session logging capabilities
* Improved auditability

### Project Implementation

Administrative access was performed using Session Manager rather than SSH.

---

# Question 4

## What is IMDSv2, and why is it important?

### Expected Answer

The Instance Metadata Service (IMDS) allows EC2 instances to retrieve metadata and temporary credentials.

IMDSv2 introduces session-based authentication, helping protect against Server-Side Request Forgery (SSRF) attacks.

### Project Implementation

The Launch Template enforces IMDSv2 for all EC2 instances.

### Production Best Practice

Disable IMDSv1 and require IMDSv2 on all supported workloads.

---

# Question 5

## What is AWS WAF?

### Expected Answer

AWS WAF is a web application firewall that filters HTTP and HTTPS requests before they reach the application.

It protects against common web attacks such as:

* SQL Injection (SQLi)
* Cross-Site Scripting (XSS)
* Malicious bots
* Common web exploits

### Project Implementation

The Application Load Balancer is associated with an AWS WAF Web ACL using the AWS Managed Rules Common Rule Set.

---

# Question 6

## Why did you use AWS Managed Rules?

### Expected Answer

AWS Managed Rules provide protection against widely known web threats without requiring custom rule development.

Benefits include:

* Simplified management
* Regular updates by AWS
* Reduced operational effort
* Broad protection against common attack patterns

Custom rules can be added later for application-specific requirements.

---

# Question 7

## What is AWS Shield Standard?

### Expected Answer

AWS Shield Standard provides automatic protection against common network and transport layer Distributed Denial of Service (DDoS) attacks.

It is enabled automatically for supported AWS services, including:

* Application Load Balancers
* Network Load Balancers
* Amazon CloudFront
* Amazon Route 53

### Project Implementation

Because the application uses an internet-facing Application Load Balancer, it benefits from AWS Shield Standard without additional configuration.

---

# Question 8

## What is the difference between Security Groups and AWS WAF?

### Expected Answer

Security Groups operate at the network level and control which traffic is allowed to reach AWS resources.

AWS WAF operates at the application layer (Layer 7) and inspects HTTP and HTTPS requests for malicious content.

Examples:

Security Groups

* Allow TCP port 80
* Allow TCP port 443
* Restrict SSH access

AWS WAF

* Block SQL Injection
* Block Cross-Site Scripting
* Apply rate limiting
* Block malicious IP addresses

These services complement each other rather than replacing one another.

---

# Question 9

## How are your EBS volumes protected?

### Expected Answer

The Launch Template configures encrypted Amazon EBS volumes.

Benefits include:

* Data protection at rest
* Compliance support
* Minimal operational overhead because encryption is handled by AWS

---

# Question 10

## What additional security services would you enable in production?

### Expected Answer

Recommended additions include:

* AWS CloudTrail
* Amazon GuardDuty
* AWS Security Hub
* AWS Config
* AWS Inspector
* Amazon Macie (where applicable)
* AWS Secrets Manager
* AWS KMS customer-managed keys
* VPC Endpoints for AWS services

These services strengthen governance, threat detection, and compliance.

---

# Production Scenario 1

## A developer accidentally attaches AdministratorAccess to an EC2 IAM Role.

### Investigation

1. Confirm the role assignment.
2. Review CloudTrail logs.
3. Remove unnecessary permissions.
4. Apply the Principle of Least Privilege.
5. Verify application functionality.
6. Monitor for unauthorized actions.

### Best Practice

Grant only the permissions required for the workload to function.

---

# Production Scenario 2

## AWS WAF starts blocking legitimate customer requests.

### Investigation

1. Review WAF logs (if enabled).
2. Identify the rule responsible.
3. Confirm whether the traffic is a false positive.
4. Adjust rule actions or add exceptions.
5. Monitor after changes.

### Key Point

Avoid disabling the entire Web ACL when only a specific rule requires tuning.

---

# Production Scenario 3

## An EC2 instance is suspected of being compromised.

### Immediate Actions

1. Isolate the instance by restricting Security Group access.
2. Preserve evidence for forensic analysis.
3. Capture relevant logs and snapshots if required by organizational procedures.
4. Launch a replacement instance through the Auto Scaling Group if appropriate.
5. Rotate affected credentials and investigate the root cause.

### Lesson

Containment and evidence preservation are as important as service restoration.

---

# Production Scenario 4

## Access keys are accidentally committed to a Git repository.

### Immediate Actions

1. Disable or delete the exposed access keys.
2. Create replacement credentials only if required.
3. Review CloudTrail for suspicious activity.
4. Rotate related secrets.
5. Remove the exposed credentials from the repository history.
6. Update development practices to prevent recurrence.

### Prevention

Use IAM Roles whenever possible instead of long-lived access keys.

---

# Whiteboard Question

Design a secure AWS architecture for an online banking application.

### Strong Answer

Include:

Network Security

* Private application servers
* Private databases
* Security Groups
* Network ACLs

Identity

* IAM Roles
* Least Privilege
* Multi-Factor Authentication for administrators

Application Security

* AWS WAF
* AWS Shield
* HTTPS
* AWS Certificate Manager

Monitoring

* CloudTrail
* GuardDuty
* Security Hub
* CloudWatch
* SNS

Data Protection

* KMS encryption
* Encrypted EBS
* Encrypted database storage
* Secrets Manager

Operational Security

* Systems Manager Session Manager
* No public SSH access
* Patch management
* Continuous compliance monitoring

---

# Common Interview Mistakes

Candidates often:

* Store AWS access keys on EC2 instances.
* Open SSH (22) to the internet unnecessarily.
* Grant excessive IAM permissions.
* Treat WAF as a replacement for Security Groups.
* Assume AWS Shield protects against all application-layer attacks.
* Forget to enforce IMDSv2.
* Ignore encryption at rest.

---

# Advanced Follow-up Questions

Be prepared to discuss:

* IAM Permission Boundaries
* Service Control Policies (SCPs)
* IAM Identity Center
* Customer Managed KMS Keys
* WAF Rate-Based Rules
* AWS Firewall Manager
* AWS Network Firewall
* AWS Organizations
* VPC Endpoints
* PrivateLink
* Cross-account IAM roles

---

# Interview Summary

This project provided practical experience with:

* IAM Roles
* Least Privilege
* Systems Manager Session Manager
* IMDSv2
* Encrypted EBS volumes
* Security Groups
* AWS WAF
* AWS Shield Standard
* Defense in Depth

The security design emphasizes layered protection, secure administration, and minimizing the attack surface rather than relying on any single security control.
