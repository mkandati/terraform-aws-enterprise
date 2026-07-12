# Cloud Architect Design Scenarios

This document contains realistic architecture design scenarios commonly discussed during Cloud Architect interviews.

Each scenario includes:

* Business Requirements
* Non-Functional Requirements
* Proposed AWS Architecture
* Design Decisions
* Trade-offs
* Common Follow-up Questions

The objective is to explain not only *what* services to use, but *why* they are appropriate for the workload.

---

# Scenario 1

## Design a Secure Internet Banking Application

### Business Requirements

* Customers access the application over the internet.
* Secure authentication and authorization.
* High availability.
* Protection against common web attacks.
* Continuous monitoring.
* Disaster recovery capability.
* Regulatory compliance.

---

## Non-Functional Requirements

Availability

* 99.99% or higher

Security

* Encryption in transit
* Encryption at rest
* Least Privilege
* Multi-layer security

Performance

* Low latency
* Automatic scaling

Reliability

* Multi-AZ deployment
* Automatic recovery

Monitoring

* Centralized monitoring
* Alerting
* Auditing

---

## Proposed AWS Architecture

Internet

↓

Amazon Route 53

↓

AWS WAF

↓

AWS Shield Standard

↓

Application Load Balancer

↓

Auto Scaling Group

↓

Private EC2 Instances

↓

Amazon RDS Multi-AZ

↓

CloudWatch + SNS

↓

CloudTrail + GuardDuty + Security Hub

---

## Why This Architecture?

Route 53

Provides highly available DNS routing.

---

AWS WAF

Protects against Layer 7 attacks.

---

AWS Shield Standard

Provides automatic DDoS protection.

---

Application Load Balancer

Distributes traffic across multiple Availability Zones.

---

Auto Scaling

Automatically adjusts capacity based on demand.

---

Private EC2

Application servers are isolated from direct internet access.

---

Amazon RDS Multi-AZ

Provides high availability and automated failover.

---

CloudWatch

Monitors application health.

---

CloudTrail

Captures API activity for auditing.

---

GuardDuty

Detects suspicious behavior.

---

Security Hub

Centralizes security findings.

---

## Security Controls

* IAM Roles
* MFA for administrators
* Session Manager
* IMDSv2
* Security Groups
* KMS encryption
* Encrypted EBS
* TLS certificates
* Secrets Manager

---

## Disaster Recovery

* Automated database backups
* Cross-Region backup strategy
* Infrastructure as Code using Terraform
* AMI backups
* Route 53 failover (where required)

---

## Cost Considerations

Do not optimize at the expense of:

* Availability
* Security
* Compliance

Banking workloads prioritize resilience over minimizing infrastructure costs.

---

## Common Interview Follow-up Questions

Why not use public EC2 instances?

Expected Answer:

Public-facing instances increase the attack surface. Keeping application servers in private subnets improves security by ensuring all client traffic passes through controlled entry points such as the ALB and WAF.

---

Why use Multi-AZ instead of a single Availability Zone?

Expected Answer:

A single Availability Zone represents a potential single point of failure. Multi-AZ deployments improve resilience against infrastructure failures and maintenance events.

---

Would you use Spot Instances?

Expected Answer:

No, not for customer-facing banking transactions. Spot capacity is appropriate only for interruption-tolerant workloads.

---

How would you secure administrator access?

Expected Answer:

Use IAM Identity Center (or an enterprise identity provider), enforce MFA, grant least-privilege IAM permissions, and use AWS Systems Manager Session Manager instead of exposing SSH.

---

# Scenario 2

## Migrate a Three-Tier On-Premises Application to AWS

### Existing Environment

* Web Server
* Application Server
* Database Server

Hosted in an on-premises data center.

---

## Migration Goals

* Minimize downtime.
* Improve scalability.
* Increase availability.
* Reduce operational overhead.
* Maintain application functionality.

---

## Proposed AWS Architecture

Users

↓

Route 53

↓

Application Load Balancer

↓

Auto Scaling Group

↓

Private EC2 Application Servers

↓

Amazon RDS Multi-AZ

↓

Amazon S3

↓

CloudWatch

---

## Migration Strategy

Assessment

* Inventory servers and dependencies.
* Measure resource utilization.
* Identify compliance requirements.

Migration

* Establish secure connectivity (for example, VPN or Direct Connect).
* Migrate databases.
* Deploy application servers.
* Validate functionality.
* Perform cutover during a planned maintenance window.

Optimization

* Enable Auto Scaling.
* Configure monitoring.
* Right-size resources.
* Automate deployments.

---

## AWS Services Selected

Networking

* Amazon VPC
* Public and Private Subnets
* Internet Gateway
* NAT Gateway

Compute

* Amazon EC2
* Auto Scaling

Storage

* Amazon S3
* Amazon EBS

Database

* Amazon RDS

Security

* IAM
* WAF
* Security Groups

Monitoring

* CloudWatch
* SNS

---

## Migration Challenges

* Legacy application compatibility
* Database migration
* Session persistence
* DNS cutover
* Rollback planning
* User acceptance testing

---

## Common Interview Questions

Would you migrate everything at once?

Expected Answer:

Not usually. A phased migration reduces risk by validating each component before proceeding to the next stage.

---

How would you minimize downtime?

Expected Answer:

Synchronize data before cutover, validate the target environment, lower DNS TTL in advance where appropriate, and perform the final switch during a maintenance window with a tested rollback plan.

---

How would you validate migration success?

Expected Answer:

Validate infrastructure health, application functionality, database consistency, monitoring, security controls, and user acceptance before declaring the migration complete.

---

**Next Section**

Part 2 covers more advanced design scenarios, including:

* SaaS Multi-Tenant Platform
* Global E-Commerce Application
* Disaster Recovery Architecture
* Hybrid Cloud Design
* Event-Driven Microservices
* High-Volume Streaming Platform
* Enterprise Logging and Monitoring

# Cloud Architect Design Scenarios (Part 2)

---

# Scenario 3

## Design a Global E-Commerce Platform

### Business Requirements

* Customers from multiple continents.
* Low-latency user experience.
* High availability.
* Secure online payments.
* Ability to handle seasonal traffic spikes.
* Disaster recovery.

---

## Non-Functional Requirements

Availability

* 99.99% or higher

Performance

* Low latency worldwide

Scalability

* Handle Black Friday and seasonal peaks

Security

* PCI DSS compliance
* Encryption
* WAF protection

Monitoring

* Centralized logging and alerting

---

## Proposed AWS Architecture

Users

↓

Amazon Route 53 (Latency-Based Routing)

↓

Amazon CloudFront

↓

AWS WAF

↓

AWS Shield Standard

↓

Application Load Balancer

↓

Auto Scaling Group

↓

Private EC2 Application Tier

↓

Amazon RDS Multi-AZ

↓

Amazon ElastiCache

↓

Amazon S3

↓

CloudWatch

---

## Design Decisions

### Route 53

Routes users to the closest healthy endpoint.

---

### CloudFront

Reduces latency by caching static content at edge locations.

---

### AWS WAF

Protects against common Layer 7 attacks.

---

### Auto Scaling

Handles traffic surges automatically.

---

### Amazon ElastiCache

Reduces database load by caching frequently accessed data such as product catalogs and session information.

---

### Amazon RDS Multi-AZ

Provides automatic failover and high availability.

---

## Follow-up Questions

### Would you store product images on EC2?

Expected Answer:

No.

Static content is better stored in Amazon S3 and distributed through CloudFront.

---

### How would you prepare for Black Friday traffic?

Expected Answer:

* Load testing
* Auto Scaling validation
* Database performance testing
* CloudFront cache optimization
* Monitoring dashboards
* Incident response readiness

---

### What metrics would you monitor?

Examples:

* Request Count
* Target Response Time
* HTTP 5xx Errors
* CPU Utilization
* Database Connections
* Cache Hit Ratio
* Checkout Success Rate

---

# Scenario 4

## Design a Multi-Tenant SaaS Platform

### Business Requirements

* Multiple customers share the platform.
* Strong tenant isolation.
* Secure authentication.
* Independent scaling.
* Cost efficiency.

---

## Design Options

### Option 1

Shared Infrastructure

Shared Application

Shared Database

Lower cost

Lower isolation

---

### Option 2

Shared Infrastructure

Shared Application

Separate Database per Tenant

Balanced cost and isolation

---

### Option 3

Dedicated Infrastructure Per Tenant

Highest isolation

Highest cost

Suitable for highly regulated customers.

---

## Recommended Architecture

Internet

↓

Route 53

↓

CloudFront

↓

AWS WAF

↓

Application Load Balancer

↓

Application Tier

↓

Tenant Identification Layer

↓

Database Layer

---

## Tenant Isolation

Examples include:

* Separate databases
* Separate schemas
* Row-level security
* Tenant-specific encryption keys where required

The appropriate strategy depends on security, compliance, and operational requirements.

---

## Common Interview Question

How would you onboard a new tenant?

Expected Answer:

Automate provisioning using Infrastructure as Code and deployment pipelines where appropriate. Apply standard security controls, tagging, monitoring, and configuration to every tenant environment.

---

# Scenario 5

## Design a Hybrid Cloud Solution

### Business Requirements

* Existing on-premises data center.
* Gradual cloud migration.
* Secure connectivity.
* Minimal downtime.

---

## Proposed Architecture

On-Premises Data Center

↓

VPN or AWS Direct Connect

↓

Amazon VPC

↓

Private Subnets

↓

Application Tier

↓

Amazon RDS

↓

CloudWatch

---

## Key Design Decisions

Connectivity

* VPN for smaller environments or initial migration.
* Direct Connect for consistent, high-bandwidth enterprise connectivity.

Identity

* Federated authentication.
* Centralized IAM governance.

Monitoring

* Unified operational dashboards across environments where practical.

---

## Common Interview Question

Would you recommend VPN or Direct Connect?

Expected Answer:

For proof-of-concept or smaller workloads, VPN is often sufficient.

For enterprise production workloads requiring consistent bandwidth and lower latency, Direct Connect is generally preferred.

---

# Scenario 6

## Design an Event-Driven Order Processing System

### Business Requirements

* Orders placed online.
* Asynchronous processing.
* Fault tolerance.
* Scalability.

---

## Proposed Architecture

Client

↓

Application Layer

↓

Amazon SQS

↓

Order Processing Service

↓

Database

↓

SNS Notifications

---

## Benefits

* Loose coupling
* Improved scalability
* Retry capability
* Better fault isolation

---

## Follow-up Questions

Why use SQS?

Expected Answer:

SQS decouples producers from consumers, allowing components to scale independently and improving resilience during traffic spikes.

---

When would you use EventBridge?

Expected Answer:

EventBridge is well suited for event routing, application integration, and reacting to business events across AWS services and custom applications.

---

# Architectural Trade-offs

Every architecture should balance:

Security

Availability

Performance

Cost

Operational Complexity

Compliance

No single architecture optimizes every factor simultaneously. Cloud Architects are expected to make informed trade-offs based on business priorities.

---

# Whiteboard Tips

During architecture interviews:

1. Gather requirements before selecting services.
2. Identify functional and non-functional requirements.
3. Design for failure.
4. Explain security from the beginning.
5. Include monitoring and operational visibility.
6. Consider disaster recovery.
7. Discuss cost implications.
8. Explain trade-offs and alternatives.
9. Validate assumptions with the interviewer.
10. Summarize the design and invite questions.

---

**Next Section**

Part 3 focuses on advanced enterprise architectures, including Multi-Region Disaster Recovery, container platforms (Amazon ECS and Amazon EKS), serverless patterns, enterprise governance, and common architecture interview challenges.
# Cloud Architect Design Scenarios (Part 3)

---

# Scenario 7

## Design a Multi-Region Disaster Recovery Architecture

### Business Requirements

* Critical customer-facing application.
* Regional disaster resilience.
* Defined Recovery Time Objective (RTO) and Recovery Point Objective (RPO).
* Minimal data loss.
* Automated failover where appropriate.

---

## Recovery Strategies

### Backup & Restore

Characteristics

* Lowest cost
* Highest recovery time
* Suitable for non-critical workloads

Examples

* Amazon S3 backups
* Amazon RDS snapshots
* Terraform Infrastructure as Code

---

### Pilot Light

Characteristics

* Critical services remain running.
* Application tier is deployed when required.

Advantages

* Lower operating cost than active-active
* Faster recovery than backup-only

---

### Warm Standby

Characteristics

* Reduced-capacity environment runs continuously.
* Scale up during a disaster.

Advantages

* Lower RTO
* Moderate operating cost

---

### Active-Active

Characteristics

* Multiple AWS Regions actively serve production traffic.

Advantages

* Highest availability
* Lowest recovery time

Disadvantages

* Highest operational complexity
* Highest cost

---

## Interview Question

Which disaster recovery strategy would you recommend for an online banking platform?

### Expected Answer

For mission-critical banking workloads, Warm Standby or Active-Active architectures are commonly preferred because they provide lower recovery times while meeting strict availability requirements. The final choice depends on business continuity objectives, compliance requirements, and budget.

---

# Scenario 8

## Design a Container-Based Platform

### Business Requirements

* Microservices architecture.
* Independent deployments.
* Horizontal scaling.
* Simplified operations.

---

## Option 1 – Amazon ECS

Advantages

* Simpler operational model
* Native AWS integration
* Lower operational overhead

Suitable For

* Teams primarily using AWS
* Smaller container platforms
* Faster adoption

---

## Option 2 – Amazon EKS

Advantages

* Kubernetes standard
* Multi-cloud portability
* Large ecosystem

Suitable For

* Organizations with Kubernetes expertise
* Complex microservice environments
* Hybrid or multi-cloud strategies

---

## Interview Question

Which would you choose?

### Expected Answer

If the organization is fully invested in AWS and prefers operational simplicity, Amazon ECS is often an excellent choice.

If Kubernetes portability or existing Kubernetes expertise is a business requirement, Amazon EKS may be more appropriate.

The decision should align with organizational skills and long-term strategy.

---

# Scenario 9

## Design a Serverless Event Processing Platform

### Business Requirements

* Process uploaded files.
* Automatically scale.
* Pay only for actual usage.
* Minimal infrastructure management.

---

## Proposed Architecture

Client

↓

Amazon S3

↓

AWS Lambda

↓

Amazon DynamoDB

↓

Amazon SNS

↓

CloudWatch

---

## Benefits

* Automatic scaling
* No server management
* Event-driven architecture
* Cost efficiency for variable workloads

---

## Interview Question

When would you choose Lambda instead of EC2?

### Expected Answer

Lambda is well suited for short-lived, event-driven workloads with variable demand.

EC2 is generally preferred for long-running processes, applications requiring persistent compute, or workloads with specialized operating system requirements.

---

# Scenario 10

## Enterprise Governance

### Objectives

* Standardization
* Compliance
* Security
* Cost control
* Operational consistency

---

## Recommended AWS Services

* AWS Organizations
* Organizational Units (OUs)
* Service Control Policies (SCPs)
* IAM Identity Center
* AWS Config
* AWS CloudTrail
* AWS Security Hub
* Amazon GuardDuty

---

## Governance Best Practices

* Standard tagging
* Infrastructure as Code
* Change management
* Centralized logging
* Least Privilege IAM
* Continuous compliance monitoring

---

# Scenario 11

## Enterprise Logging and Monitoring

### Requirements

* Centralized logs
* Security monitoring
* Operational dashboards
* Long-term retention
* Audit support

---

## Architecture

Applications

↓

CloudWatch Logs

↓

CloudWatch Alarms

↓

SNS

↓

Operations Team

Optional Enterprise Enhancements

↓

Amazon OpenSearch Service

↓

Security Information and Event Management (SIEM)

---

## Best Practices

* Define log retention policies.
* Separate application, infrastructure, and security logs.
* Monitor actionable metrics.
* Periodically review and tune alarms.

---

# Scenario 12

## Design Review Exercise

### Interview Prompt

Design a highly available web application capable of serving 10 million users.

---

### Clarifying Questions

Before proposing a solution, ask:

* What is the expected traffic pattern?
* Is the workload global or regional?
* What are the RTO and RPO requirements?
* Are there compliance obligations?
* What is the expected growth rate?
* What is the budget?
* Are there latency targets?
* Is the application stateful or stateless?

Gathering requirements before selecting AWS services demonstrates architectural thinking.

---

### Example High-Level Solution

* Amazon Route 53
* Amazon CloudFront
* AWS WAF
* AWS Shield Advanced (if justified by business requirements)
* Application Load Balancer
* Auto Scaling
* Stateless application tier
* Amazon ElastiCache
* Amazon RDS Multi-AZ or Amazon Aurora
* Amazon S3
* CloudWatch
* CloudTrail
* AWS Backup

The exact architecture should be refined based on the answers to the clarification questions.

---

# Architecture Decision Framework

When evaluating any design, consider:

Business Requirements

↓

Security

↓

Availability

↓

Scalability

↓

Performance

↓

Cost

↓

Operational Simplicity

↓

Compliance

Avoid selecting services based solely on familiarity. Every architectural decision should map back to a business or technical requirement.

---

# Common Architecture Interview Mistakes

Candidates often:

* Start drawing before understanding requirements.
* Select AWS services without explaining why.
* Ignore operational monitoring.
* Overlook disaster recovery.
* Forget identity and access management.
* Recommend the most complex solution instead of the most appropriate one.
* Focus exclusively on technology rather than business outcomes.

---

# Final Interview Advice

Strong Cloud Architects consistently:

* Ask clarifying questions.
* Design for failure.
* Explain trade-offs.
* Consider operations and monitoring.
* Balance cost with resilience.
* Align technical decisions with business objectives.
* Communicate clearly and logically.

Technical depth is important, but structured thinking and decision-making are what distinguish senior architects.

---

# Summary

This document covered:

* Secure internet-facing applications
* Cloud migration strategies
* Global architectures
* Multi-tenant SaaS platforms
* Hybrid cloud
* Event-driven systems
* Disaster recovery
* Containers
* Serverless architectures
* Enterprise governance
* Monitoring and logging
* Architecture interview methodology

The architectural patterns presented here extend beyond the Terraform implementation in this project and are intended to prepare for broader Cloud Architect design discussions while remaining consistent with AWS best practices.
