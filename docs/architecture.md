# Enterprise AWS Infrastructure Architecture

## Overview

This document describes the architecture, design decisions, implementation strategy, and operational considerations for the Enterprise AWS Infrastructure project.

The solution was implemented using **Terraform** following Infrastructure as Code (IaC) principles and demonstrates a secure, modular, highly available AWS environment inspired by enterprise production practices.

Although deployed in a personal AWS account for learning purposes, the architecture reflects common patterns used in modern cloud environments.

---

# Objectives

The primary objectives of this project were:

* Design a secure AWS networking environment.
* Deploy highly available application infrastructure across multiple Availability Zones.
* Implement Infrastructure as Code using reusable Terraform modules.
* Eliminate manual infrastructure provisioning.
* Improve operational visibility through monitoring and alerting.
* Apply enterprise-inspired security best practices.
* Validate infrastructure through practical operational testing.
* Understand the differences between learning environments and production deployments.

---

# Architecture Principles

The solution was designed around several core cloud architecture principles.

## 1. Infrastructure as Code

All AWS resources are provisioned using Terraform.

Benefits include:

* Repeatable deployments
* Version-controlled infrastructure
* Simplified change management
* Reduced manual configuration
* Easier disaster recovery

---

## 2. Modular Design

The Terraform configuration is organized into independent modules.

Examples include:

* VPC
* Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* IAM
* Launch Template
* Auto Scaling Group
* Application Load Balancer
* CloudWatch
* SNS
* AWS WAF

Each module is responsible for a single area of functionality, making the solution easier to understand, maintain, and extend.

---

## 3. Security by Design

Security was considered throughout the design process rather than being added later.

Key security measures include:

* Private EC2 instances
* IAM Roles
* Security Groups
* AWS Systems Manager Session Manager
* AWS WAF
* AWS Shield Standard
* IMDSv2
* Encrypted EBS volumes

This layered approach follows the principle of **defense in depth**.

---

## 4. High Availability

To improve resilience, application resources are distributed across multiple Availability Zones.

High availability is achieved through:

* Multi-AZ subnets
* Application Load Balancer
* Auto Scaling Group
* Health Checks
* Automatic instance replacement

These capabilities help maintain service availability during infrastructure failures.

---

## 5. Operational Excellence

Operational visibility was incorporated into the architecture from the beginning.

Implemented services include:

* Amazon CloudWatch
* CloudWatch Dashboards
* CloudWatch Alarms
* Amazon SNS Notifications

This allows infrastructure events to be detected, monitored, and acted upon quickly.

---

# Scope

The project includes the following AWS services.

| Category               | Services                                                          |
| ---------------------- | ----------------------------------------------------------------- |
| Networking             | Amazon VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway  |
| Compute                | Amazon EC2, Launch Templates, Auto Scaling                        |
| Load Balancing         | Application Load Balancer, Target Groups                          |
| Security               | IAM, Security Groups, AWS WAF, AWS Shield Standard                |
| Management             | AWS Systems Manager Session Manager                               |
| Monitoring             | Amazon CloudWatch, CloudWatch Logs, CloudWatch Alarms, Dashboards |
| Notifications          | Amazon SNS                                                        |
| Infrastructure as Code | Terraform                                                         |
| State Management       | Amazon S3, DynamoDB                                               |

---

# Business Scenario

Consider an organization deploying a public-facing web application.

The architecture must satisfy several requirements:

* High availability
* Secure application access
* Automated infrastructure provisioning
* Operational monitoring
* Automatic recovery from infrastructure failures
* Controlled administrative access
* Scalability to accommodate changing workloads

The implemented solution addresses these requirements while maintaining a modular and reusable design.

---

# Architecture Goals

The architecture was designed to achieve the following outcomes:

* Secure network segmentation
* Fault tolerance across Availability Zones
* Controlled internet access
* Centralized monitoring
* Event-driven notifications
* Automated scaling and recovery
* Reusable Infrastructure as Code
* Enterprise-inspired operational practices

---

# Target Audience

This documentation is intended for:

* Cloud Architects
* DevOps Engineers
* Infrastructure Engineers
* Site Reliability Engineers (SREs)
* Platform Engineers
* Students learning AWS
* Interviewers reviewing cloud architecture projects

---

# Design Assumptions

The following assumptions apply to this implementation:

* The environment is hosted in a single AWS Region.
* The application is a stateless web application.
* User traffic is routed through an Application Load Balancer.
* EC2 instances are managed by an Auto Scaling Group.
* Infrastructure changes are managed through Terraform.
* Administrative access is performed using AWS Systems Manager Session Manager.
* CloudWatch provides operational monitoring.

These assumptions simplify the environment while remaining representative of many enterprise workloads.

---

# Architecture Overview

At a high level, the environment consists of:

* A custom Amazon VPC
* Public and private subnets spanning multiple Availability Zones
* Internet Gateway for inbound connectivity
* NAT Gateway for secure outbound internet access
* Application Load Balancer receiving client traffic
* Auto Scaling Group hosting EC2 instances
* CloudWatch providing monitoring and alerting
* SNS delivering notifications
* AWS WAF protecting the application layer
* AWS Shield Standard providing baseline DDoS protection

The following sections describe each component, its responsibilities, and the rationale behind its inclusion in the architecture.

---

**Next Section**

Part 2 presents the complete high-level architecture, request flow, infrastructure topology, and end-to-end interaction between AWS services.

# High-Level Architecture

The Enterprise AWS Infrastructure project follows a layered architecture that separates networking, compute, security, monitoring, and management services. This separation improves scalability, maintainability, and security while aligning with common enterprise cloud design patterns.

---

# Architecture Diagram

> **Architecture Diagram Placeholder**
>
> Replace this section with the completed architecture diagram.
>
> Suggested location:
>
> ```text
> docs/images/high-level-architecture.png
> ```

---

# Architecture Components

The environment consists of the following logical layers.

```text
                    Internet
                        │
                        ▼
          Application Load Balancer
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
  Private Subnet A                Private Subnet B
        │                               │
        ▼                               ▼
     EC2 Instance                   EC2 Instance
        │                               │
        └───────────────┬───────────────┘
                        │
                 Auto Scaling Group
                        │
          AWS Systems Manager (SSM)
                        │
               CloudWatch Monitoring
                        │
                 Amazon SNS Alerts
```

This logical view illustrates how traffic reaches the application while operational services provide monitoring, automation, and administrative access.

---

# End-to-End Request Flow

A typical client request follows the sequence below.

1. A user accesses the web application using the Application Load Balancer DNS name.
2. The Application Load Balancer receives the request.
3. The ALB evaluates listener rules.
4. The request is forwarded to the Target Group.
5. The Target Group selects a healthy EC2 instance.
6. The EC2 instance processes the request.
7. The response is returned through the ALB to the client.

The Application Load Balancer continuously performs health checks against registered targets to ensure that requests are routed only to healthy instances.

---

# Request Flow Diagram

> **Request Flow Diagram Placeholder**
>
> Replace this section with:
>
> ```text
> docs/images/request-flow.png
> ```

Suggested flow:

```text
User
 │
 ▼
Internet
 │
 ▼
Application Load Balancer
 │
 ▼
Target Group
 │
 ▼
Healthy EC2 Instance
 │
 ▼
Application Response
 │
 ▼
User
```

---

# Infrastructure Layers

The architecture is divided into distinct functional layers.

## Edge Layer

Responsible for accepting traffic from the internet.

Components:

* Internet Gateway
* Application Load Balancer
* AWS WAF
* AWS Shield Standard

Responsibilities:

* Receive inbound requests
* Filter malicious traffic
* Distribute requests
* Provide DDoS protection

---

## Network Layer

Provides secure network segmentation.

Components:

* Amazon VPC
* Public Subnets
* Private Subnets
* Route Tables
* NAT Gateway

Responsibilities:

* Network isolation
* Internet routing
* Outbound internet access
* Availability Zone separation

---

## Compute Layer

Hosts the application.

Components:

* Amazon EC2
* Launch Templates
* Auto Scaling Group

Responsibilities:

* Execute application code
* Replace failed instances
* Scale capacity
* Maintain desired instance count

---

## Management Layer

Provides secure operational access.

Components:

* AWS Systems Manager
* IAM Roles

Responsibilities:

* Secure administration
* Session management
* Temporary AWS credentials
* Eliminate SSH access

---

## Observability Layer

Provides visibility into infrastructure health.

Components:

* CloudWatch Logs
* CloudWatch Dashboard
* CloudWatch Metrics
* CloudWatch Alarms
* Amazon SNS

Responsibilities:

* Monitoring
* Alerting
* Logging
* Operational visibility

---

# Service Interaction

The following table summarizes how AWS services interact.

| AWS Service               | Interacts With  | Purpose                           |
| ------------------------- | --------------- | --------------------------------- |
| Internet Gateway          | ALB             | Public internet connectivity      |
| Application Load Balancer | Target Group    | Distributes incoming requests     |
| Target Group              | EC2 Instances   | Health checks and request routing |
| Auto Scaling Group        | Launch Template | Creates EC2 instances             |
| Launch Template           | IAM Role        | Attaches permissions to EC2       |
| EC2                       | CloudWatch      | Publishes metrics and logs        |
| CloudWatch                | SNS             | Sends notifications               |
| WAF                       | ALB             | Filters application traffic       |
| Systems Manager           | EC2             | Secure administration             |
| NAT Gateway               | EC2             | Secure outbound internet access   |

---

# Network Topology

The environment spans two Availability Zones.

Each Availability Zone contains:

* One public subnet
* One private subnet

Public resources:

* Application Load Balancer
* NAT Gateway

Private resources:

* EC2 Instances
* Auto Scaling Group

This design increases resilience while keeping application servers isolated from direct internet access.

---

# Network Topology Diagram

> **Network Topology Placeholder**
>
> Replace with:
>
> ```text
> docs/images/network-topology.png
> ```

Suggested topology:

```text
                    Amazon VPC
 ┌─────────────────────────────────────────────┐

      Public Subnet A       Public Subnet B
             │                    │
             └────── ALB ─────────┘
                    │
             Target Group
                    │
      ┌─────────────┴─────────────┐
      │                           │
Private Subnet A           Private Subnet B
      │                           │
      ▼                           ▼
 EC2 Instance               EC2 Instance

            Auto Scaling Group

 └─────────────────────────────────────────────┘
```

---

# Data Flow

Infrastructure traffic can be grouped into four categories.

### Client Traffic

Client → ALB → Target Group → EC2

---

### Health Check Traffic

ALB → Target Group → EC2

Used to determine instance health before routing requests.

---

### Administrative Traffic

Administrator → AWS Systems Manager → EC2

No SSH access is required.

---

### Monitoring Traffic

EC2 → CloudWatch

CloudWatch → SNS

This enables metrics collection, alarm evaluation, and notification delivery.

---

# Availability Strategy

High availability is achieved through:

* Multi-Availability Zone deployment
* Load balancing
* Auto Scaling
* Continuous health checks
* Automatic instance replacement

This architecture minimizes service disruption when an individual instance becomes unavailable.

> **Architecture Decision (ADR-005)**
>
> Application traffic is distributed through an Application Load Balancer instead of direct instance access. This enables health-aware request routing, seamless scaling, and reduced operational complexity as instance membership changes over time.

---

# Design Trade-offs

Every architecture involves trade-offs. For this learning environment:

| Decision              | Benefit                     | Trade-off                   |
| --------------------- | --------------------------- | --------------------------- |
| Single NAT Gateway    | Lower cost                  | Single point of failure     |
| HTTP only             | Simpler setup               | No encryption in transit    |
| ALB DNS Name          | No domain purchase required | Less user-friendly endpoint |
| Basic Dashboard       | Lower complexity            | Fewer operational metrics   |
| AWS Managed WAF Rules | Fast deployment             | Limited customization       |

These decisions were intentional and documented to balance learning objectives with AWS costs.

---

# Summary

The architecture separates networking, compute, management, security, and monitoring into well-defined layers. This modular approach simplifies operations, improves maintainability, and provides a strong foundation for future enhancements such as HTTPS, Route 53, CloudFront, and CI/CD automation.

---

**Next Section**

Part 3 provides a detailed walkthrough of each AWS service, explaining its role, configuration, dependencies, and implementation rationale within the overall architecture.

# AWS Components Deep Dive

This section provides a detailed overview of each AWS service used in the project, including its purpose, implementation, dependencies, and operational considerations.

---

# Amazon Virtual Private Cloud (VPC)

## Purpose

Amazon VPC provides a logically isolated network where all application resources are deployed.

The VPC forms the networking foundation for the entire infrastructure.

---

## Implementation

Configured components include:

* Custom CIDR block
* DNS Resolution
* DNS Hostnames
* Public Subnets
* Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables

---

## Responsibilities

* Network isolation
* IP address management
* Routing
* Security boundaries
* Availability Zone segmentation

---

## Dependencies

Connected services include:

* EC2
* Application Load Balancer
* NAT Gateway
* Route Tables
* Security Groups

---

## Architecture Decision (ADR-006)

A custom VPC was deployed instead of using the default VPC to provide complete control over networking, routing, security, and future scalability.

---

## Production Recommendation

Use dedicated CIDR planning that accommodates future growth, VPN connectivity, Direct Connect, Transit Gateway, and additional environments.

---

# Public Subnets

## Purpose

Public subnets host infrastructure that must communicate directly with the internet.

---

## Hosted Resources

* Application Load Balancer
* NAT Gateway

---

## Characteristics

* Associated with a public route table
* Route to the Internet Gateway
* Public IP support where required

---

## Security Considerations

Only infrastructure requiring internet connectivity should reside in public subnets.

Application servers should remain private.

---

# Private Subnets

## Purpose

Private subnets host application workloads that should not be directly accessible from the internet.

---

## Hosted Resources

* EC2 Instances
* Auto Scaling Group

---

## Benefits

* Reduced attack surface
* Controlled inbound access
* Secure outbound internet access through the NAT Gateway

---

## Architecture Decision (ADR-007)

Application workloads were intentionally isolated in private subnets. All client traffic must pass through the Application Load Balancer before reaching application servers.

---

# Internet Gateway

## Purpose

Provides internet connectivity for public resources within the VPC.

---

## Responsibilities

* Enables inbound traffic to the ALB
* Supports outbound internet access from public resources

---

## Dependencies

* Public Route Table
* Public Subnets

---

## Production Recommendation

Restrict internet-facing resources to the minimum required infrastructure.

---

# NAT Gateway

## Purpose

Allows resources in private subnets to access the internet without exposing them to inbound connections.

---

## Usage in This Project

The NAT Gateway enables private EC2 instances to:

* Download operating system updates
* Install application packages
* Access AWS services when required

---

## Production Considerations

For cost optimization, a single NAT Gateway was deployed.

Production environments typically deploy one NAT Gateway per Availability Zone to eliminate a single point of failure.

---

# Route Tables

## Public Route Table

Configured routes include:

* Local VPC routing
* Default route to the Internet Gateway

---

## Private Route Table

Configured routes include:

* Local VPC routing
* Default route to the NAT Gateway

---

## Responsibilities

* Direct traffic
* Separate public and private networks
* Enforce network segmentation

---

# Security Groups

Security Groups act as stateful virtual firewalls.

---

## Application Load Balancer Security Group

Allows:

* HTTP (80)
* HTTPS (future implementation)

Outbound:

* Traffic to EC2 Security Group

---

## EC2 Security Group

Allows:

* HTTP traffic only from the ALB Security Group
* Systems Manager communication

Blocks:

* Direct internet access
* SSH access

---

## Architecture Decision (ADR-008)

Security Groups were configured using least privilege principles. EC2 instances accept traffic only from the Application Load Balancer Security Group.

---

# IAM Roles

## Purpose

Provide temporary AWS credentials to EC2 instances.

---

## Attached Permissions

Current implementation includes:

* AmazonSSMManagedInstanceCore

---

## Benefits

* No hardcoded credentials
* Automatic credential rotation
* Least privilege access
* Secure authentication

---

## Production Recommendation

Replace AWS managed policies with tightly scoped customer-managed IAM policies where practical.

---

# AWS Systems Manager Session Manager

## Purpose

Provides secure shell access without SSH.

---

## Benefits

* No SSH keys
* No bastion host
* No public IP addresses
* Session logging
* Centralized administration

---

## Operational Validation

Administrative access was successfully performed using Session Manager throughout testing.

---

## Architecture Decision (ADR-009)

SSH access was intentionally excluded to reduce operational overhead and improve security.

---

# Launch Template

## Purpose

Defines a reusable configuration for EC2 instances launched by the Auto Scaling Group.

---

## Configuration

Includes:

* Amazon Linux 2023 AMI
* Instance type
* User Data
* IAM Instance Profile
* IMDSv2 enforcement
* Encrypted EBS volume
* Security Group

---

## Benefits

* Consistent deployments
* Simplified updates
* Standardized configuration

---

## Validation

A Launch Template version update was successfully tested and adopted by newly launched instances.

---

# Auto Scaling Group

## Purpose

Maintains the desired number of healthy EC2 instances.

---

## Configuration

* Minimum Capacity
* Desired Capacity
* Maximum Capacity
* Target Tracking Policy
* Target Group Attachment

---

## Validated Scenarios

* Manual instance termination
* Failed health checks
* Automatic replacement
* Desired capacity restoration
* Launch Template updates

---

## Architecture Decision (ADR-010)

Target Tracking Scaling based on average CPU utilization was selected because it provides automatic and predictable scaling behavior while remaining straightforward to operate.

---

## Operational Observation

When the Apache service was stopped, the Target Group marked the instance unhealthy. The Auto Scaling Group launched a replacement instance to maintain service availability.

This demonstrated infrastructure self-healing but also highlighted that automated recovery should be complemented by root cause analysis.

---

# Application Load Balancer (ALB)

## Purpose

Distributes incoming requests across healthy EC2 instances.

---

## Responsibilities

* Load balancing
* Health checks
* High availability
* Centralized application entry point

---

## Listener Configuration

Current:

* HTTP (80)

Future:

* HTTPS (443)

---

## Benefits

* Improved availability
* Fault isolation
* Simplified scaling

---

## Production Recommendation

Use HTTPS with AWS Certificate Manager (ACM) and redirect all HTTP requests to HTTPS.

---

# Target Group

## Purpose

Maintains the pool of healthy application instances.

---

## Responsibilities

* Health checks
* Request routing
* Instance registration

---

## Health Check Configuration

Validated settings:

* Interval: 30 seconds
* Timeout: 5 seconds
* Healthy Threshold: 3
* Unhealthy Threshold: 2

These settings were tested by intentionally stopping the web service and observing alarm generation and automatic instance replacement.

---

# CloudWatch

## Implemented Features

* Log Groups
* Dashboard
* Metrics
* Alarms

---

## Dashboard

Current widgets include:

* ALB Request Count

Future dashboards may include:

* CPU Utilization
* Memory Utilization
* Disk Usage
* Network Traffic
* HTTP Error Rates
* Target Response Time

---

## Operational Validation

Traffic generated during testing appeared on the dashboard, confirming successful metric collection.

---

# Amazon SNS

## Purpose

Delivers notifications when CloudWatch alarms change state.

---

## Validation

Email notifications were successfully received for:

* Alarm activation
* Alarm recovery

---

## Benefits

* Faster incident awareness
* Improved operational response

---

# AWS WAF

## Purpose

Protects the application against common web exploits.

---

## Current Configuration

* AWS Managed Rule Group
* Web ACL
* Application Load Balancer Association

---

## Validation

Web ACL association and request metrics were successfully validated after deployment.

---

## Production Recommendation

Gradually introduce custom rules, IP reputation lists, geo restrictions, and rate-based rules based on observed traffic patterns.

---

# AWS Shield Standard

## Purpose

Provides baseline protection against common DDoS attacks.

---

## Benefits

* Automatic protection
* No additional configuration
* No extra cost

---

## Production Recommendation

Evaluate AWS Shield Advanced for business-critical internet-facing applications requiring enhanced DDoS detection, mitigation, and support.

---

# Component Dependency Summary

| Component          | Depends On                                               |
| ------------------ | -------------------------------------------------------- |
| EC2                | VPC, Subnets, Security Groups, IAM Role, Launch Template |
| Auto Scaling Group | Launch Template, Target Group                            |
| ALB                | Public Subnets, Security Groups                          |
| Target Group       | ALB, EC2                                                 |
| CloudWatch         | EC2, ALB                                                 |
| SNS                | CloudWatch                                               |
| WAF                | ALB                                                      |
| Systems Manager    | IAM Role, EC2                                            |
| NAT Gateway        | Public Subnet, Internet Gateway                          |

---

# Summary

Each AWS service in this architecture performs a clearly defined role while integrating with the broader infrastructure to provide networking, security, scalability, monitoring, and operational management.

The modular design ensures that individual services can evolve independently without requiring significant architectural changes, supporting both maintainability and future growth.

---

**Next Section**

Part 4 explores the network architecture in greater depth, including CIDR planning, subnet design, routing decisions, traffic flows, and network security considerations.

# Network Architecture

The network architecture provides the foundation for the entire AWS environment. It is designed to balance security, availability, scalability, and operational simplicity while following common enterprise networking principles.

The environment is deployed within a dedicated Amazon VPC and uses a layered network design that separates internet-facing resources from internal application workloads.

---

# Network Design Goals

The network architecture was designed to achieve the following objectives:

* Isolate application workloads
* Minimize public exposure
* Support high availability
* Enable secure outbound internet access
* Simplify routing
* Support future expansion
* Align with AWS networking best practices

---

# Virtual Private Cloud (VPC)

The infrastructure is deployed inside a dedicated Amazon VPC.

## Current Configuration

| Setting        | Value       |
| -------------- | ----------- |
| CIDR Block     | 10.0.0.0/16 |
| DNS Resolution | Enabled     |
| DNS Hostnames  | Enabled     |
| Region         | ap-south-1  |

The `/16` CIDR provides ample address space for future growth, including additional environments, application tiers, and integrations.

> **Architecture Decision (ADR-011)**
>
> A `/16` VPC CIDR was selected to provide flexibility for future subnet expansion without requiring network redesign.

---

# Availability Zone Strategy

Resources are distributed across two Availability Zones.

```text
Availability Zone A
    ├── Public Subnet
    └── Private Subnet

Availability Zone B
    ├── Public Subnet
    └── Private Subnet
```

This design improves resilience by reducing the impact of failures affecting a single Availability Zone.

---

# Subnet Design

Each Availability Zone contains:

* One Public Subnet
* One Private Subnet

## Public Subnets

Public subnets host infrastructure that must be reachable from the internet.

Current resources:

* Application Load Balancer
* NAT Gateway

Characteristics:

* Route to Internet Gateway
* Public IP support where required

---

## Private Subnets

Private subnets host application workloads.

Current resources:

* EC2 Instances
* Auto Scaling Group

Characteristics:

* No direct internet access
* Outbound internet access through NAT Gateway
* Access only through the Application Load Balancer

> **Architecture Decision (ADR-012)**
>
> Public access is limited to the Application Load Balancer. Application servers remain isolated within private subnets, reducing the attack surface while maintaining application availability.

---

# Network Topology

```text
                          Internet
                              │
                              ▼
                    Internet Gateway
                              │
         ┌────────────────────┴────────────────────┐
         │                                         │
 Public Subnet (AZ-A)                     Public Subnet (AZ-B)
         │                                         │
         └────────── Application Load Balancer ────┘
                              │
                       Target Group
                              │
         ┌────────────────────┴────────────────────┐
         │                                         │
 Private Subnet (AZ-A)                   Private Subnet (AZ-B)
         │                                         │
      EC2 Instance                          EC2 Instance
         │                                         │
         └──────────── Auto Scaling Group ─────────┘
```

This topology provides redundancy while keeping compute resources isolated.

---

# Route Tables

Separate route tables are used for public and private subnets.

## Public Route Table

| Destination | Target           |
| ----------- | ---------------- |
| VPC CIDR    | Local            |
| 0.0.0.0/0   | Internet Gateway |

Purpose:

* Internet connectivity
* Public resource routing

---

## Private Route Table

| Destination | Target      |
| ----------- | ----------- |
| VPC CIDR    | Local       |
| 0.0.0.0/0   | NAT Gateway |

Purpose:

* Secure outbound internet access
* Internal VPC communication

---

# Internet Gateway

The Internet Gateway enables communication between public AWS resources and the internet.

Current responsibilities:

* Inbound traffic to the ALB
* Outbound traffic from public resources

Only public subnets have routes pointing to the Internet Gateway.

---

# NAT Gateway

The NAT Gateway provides outbound internet access for resources located in private subnets.

Example use cases:

* Installing operating system updates
* Downloading application packages
* Accessing AWS APIs
* Pulling software dependencies

The NAT Gateway prevents unsolicited inbound connections from the internet.

---

# Traffic Flow Analysis

## Client Traffic

```text
User
   │
Internet
   │
Application Load Balancer
   │
Target Group
   │
Healthy EC2 Instance
```

---

## Outbound Traffic

```text
Private EC2
      │
Private Route Table
      │
NAT Gateway
      │
Internet Gateway
      │
Internet
```

---

## Administrative Traffic

```text
Administrator
        │
AWS Systems Manager
        │
EC2 Instance
```

No SSH access is required.

---

## Monitoring Traffic

```text
EC2
 │
CloudWatch
 │
SNS
 │
Administrator
```

This enables proactive monitoring and alerting.

---

# East-West vs. North-South Traffic

Understanding traffic direction is important for network design.

## North-South Traffic

Traffic entering or leaving the VPC.

Examples:

* Client requests from the internet
* Outbound package downloads
* ALB internet connectivity

---

## East-West Traffic

Traffic remaining within the VPC.

Examples:

* ALB to EC2 communication
* EC2 to CloudWatch
* EC2 to Systems Manager endpoints (or via internet/NAT in this lab)

East-west traffic should remain private whenever possible.

---

# Security Boundaries

The architecture implements multiple security boundaries.

| Layer                | Protection            |
| -------------------- | --------------------- |
| Internet Edge        | AWS Shield Standard   |
| Application Layer    | AWS WAF               |
| Network Layer        | Security Groups       |
| Identity Layer       | IAM Roles             |
| Administrative Layer | AWS Systems Manager   |
| Storage Layer        | Encrypted EBS Volumes |

This layered approach limits the impact of individual failures or attacks.

---

# Failure Scenarios

## EC2 Instance Failure

Observed during testing:

* Target Group marks instance unhealthy.
* Auto Scaling launches replacement instance.
* Desired capacity restored.

Application availability is maintained.

---

## Application Service Failure

Observed during testing:

* Apache service stopped.
* Health checks failed.
* CloudWatch Alarm entered ALARM state.
* SNS notification sent.
* Auto Scaling replaced the instance.

This demonstrated automated recovery.

---

## Availability Zone Failure

Current behavior:

* Remaining Availability Zone continues serving traffic.
* Auto Scaling attempts to restore desired capacity.

Production environments should ensure sufficient capacity and dependent services (such as NAT Gateways) are deployed in each Availability Zone.

---

## NAT Gateway Failure

Current architecture:

* Single NAT Gateway

Impact:

* Private instances lose outbound internet connectivity.
* Existing application traffic through the ALB continues if instances remain healthy.

> **Architecture Decision (ADR-013)**
>
> A single NAT Gateway was selected to reduce cost in this learning environment. Production deployments typically provision one NAT Gateway per Availability Zone to eliminate this single point of failure.

---

# Network Security Best Practices

The following practices were implemented:

* Dedicated VPC
* Public and private subnet separation
* Least privilege Security Groups
* No public EC2 instances
* No inbound SSH
* Systems Manager administration
* Stateful firewalls
* Encrypted storage
* Layered security controls

---

# Future Network Enhancements

The network can be extended with:

* Amazon Route 53
* AWS Global Accelerator
* AWS Transit Gateway
* AWS Direct Connect
* Site-to-Site VPN
* IPv6 support
* Multi-AZ NAT Gateways
* VPC Endpoints (for S3, SSM, CloudWatch, etc.)
* Network Firewall
* Hybrid networking integration

These enhancements would improve scalability, resilience, and enterprise connectivity.

---

# Network Architecture Summary

The network architecture follows a layered design that separates public and private resources while supporting high availability, secure connectivity, and operational simplicity.

Key outcomes include:

* Secure workload isolation
* Controlled internet access
* Multi-Availability Zone deployment
* Automated recovery
* Clear traffic flow
* Expandable network design

The architecture provides a strong foundation for enterprise workloads while remaining intentionally cost-conscious for a personal learning environment.

---

**Next Section**

Part 5 examines the security architecture in detail, including IAM, Security Groups, AWS WAF, AWS Shield Standard, Session Manager, encryption, and defense-in-depth strategies.

# Security Architecture

Security was a primary design consideration throughout this project. Rather than relying on a single control, the environment implements multiple security layers following the **Defense in Depth** principle.

Each layer provides protection against different threat vectors while supporting secure operations and maintainability.

---

# Security Objectives

The security architecture was designed to achieve the following objectives:

* Minimize the attack surface
* Protect internet-facing applications
* Restrict administrative access
* Enforce least privilege
* Eliminate long-lived credentials
* Protect data at rest
* Monitor security events
* Support secure infrastructure operations

---

# Defense in Depth

The architecture applies multiple independent security controls.

```text id="u2m9kr"
                Internet
                    │
        AWS Shield Standard
                    │
               AWS WAF
                    │
      Application Load Balancer
                    │
          Security Groups
                    │
         Private EC2 Instances
                    │
             IAM Roles
                    │
      AWS Systems Manager
                    │
         CloudWatch & SNS
```

If one control fails or is bypassed, additional layers continue to provide protection.

---

# Identity and Access Management (IAM)

## Purpose

IAM controls who can access AWS resources and what actions they are permitted to perform.

---

## IAM Role for EC2

The EC2 instances use an IAM Role attached through an Instance Profile.

Current permissions include:

* AmazonSSMManagedInstanceCore

This enables Systems Manager Session Manager without storing AWS access keys on the instances.

---

## Benefits

* Temporary credentials
* Automatic credential rotation
* No hardcoded secrets
* Centralized permission management

---

## Production Recommendation

Replace broad AWS managed policies with customer-managed policies that grant only the permissions required by the application.

> **Architecture Decision (ADR-014)**
>
> IAM Roles were used instead of long-lived access keys to reduce credential management overhead and improve security.

---

# Administrative Access

## Current Implementation

Administrative access is performed exclusively through **AWS Systems Manager Session Manager**.

There is:

* No SSH access
* No public IP on EC2 instances
* No bastion host
* No SSH key pairs

---

## Operational Benefits

* Centralized session management
* IAM-based authentication
* Auditability through AWS
* Reduced attack surface

---

## Validation

Session Manager connectivity was successfully tested throughout the project for instance administration and troubleshooting.

---

# Network Security

Network access is controlled using **Security Groups**.

## Application Load Balancer Security Group

Allows:

* HTTP (TCP/80)

Future enhancement:

* HTTPS (TCP/443)

Outbound traffic is restricted to the application tier.

---

## EC2 Security Group

Allows:

* HTTP traffic **only** from the ALB Security Group
* Required outbound communication for updates and AWS service access

Blocks:

* Internet-originated HTTP
* SSH
* RDP

> **Architecture Decision (ADR-015)**
>
> Security Groups reference one another instead of allowing traffic from arbitrary IP ranges. This reduces exposure and simplifies rule management.

---

# Network ACLs

The current implementation uses the default Network ACL behavior.

Security Groups provide the primary network protection.

---

## Production Recommendation

Introduce custom Network ACLs only when an additional stateless filtering layer is required by compliance or organizational policy.

---

# Web Application Protection

## AWS WAF

AWS WAF protects the Application Load Balancer against common web attacks.

Current configuration:

* AWS Managed Rules
* Web ACL
* CloudWatch metrics

---

## Protection Examples

The managed rules help mitigate threats such as:

* SQL Injection (SQLi)
* Cross-Site Scripting (XSS)
* Known malicious request patterns
* Common web exploits

---

## Validation

The Web ACL was successfully associated with the Application Load Balancer, and request metrics were observed after deployment.

---

## Production Enhancements

Potential future improvements include:

* Rate-based rules
* Geo restrictions
* IP reputation lists
* Custom allow/deny rules
* Bot Control (where appropriate)

---

# DDoS Protection

## AWS Shield Standard

AWS Shield Standard is automatically enabled for supported AWS services.

Current protection includes:

* Network-layer attack mitigation
* Transport-layer attack mitigation
* Baseline DDoS protection

No additional configuration was required.

---

## Production Consideration

Mission-critical internet-facing applications may benefit from AWS Shield Advanced, which offers enhanced detection, mitigation, and access to the AWS DDoS Response Team (DRT).

---

# Instance Metadata Protection

The Launch Template enforces **Instance Metadata Service Version 2 (IMDSv2)**.

Benefits include:

* Protection against SSRF-based credential theft
* Session-oriented metadata access
* Improved security compared to IMDSv1

> **Architecture Decision (ADR-016)**
>
> IMDSv2 was enforced to align with current AWS security best practices and reduce the risk of instance metadata exploitation.

---

# Encryption

## EBS Volumes

EC2 root volumes are encrypted.

Benefits:

* Protects data at rest
* Meets common compliance requirements
* No application changes required

---

## Data in Transit

Current implementation:

* HTTP

Planned enhancement:

* HTTPS using:

  * AWS Certificate Manager (ACM)
  * Application Load Balancer TLS listener

> **Architecture Decision (ADR-017)**
>
> HTTP was retained during the learning phase to reduce complexity. HTTPS should be enabled before exposing production workloads to end users.

---

# Monitoring and Security Visibility

Security events are monitored using:

* Amazon CloudWatch
* CloudWatch Alarms
* Amazon SNS

Current alerting covers:

* High CPU utilization
* Unhealthy targets
* Auto Scaling activity (via operational events)

This provides operational awareness and supports faster incident response.

---

# Secrets Management

## Current State

No application secrets are stored on EC2 instances.

No AWS access keys are embedded in code or User Data.

---

## Production Recommendation

Use:

* AWS Secrets Manager
* AWS Systems Manager Parameter Store

to securely manage:

* Database credentials
* API keys
* Application secrets
* Certificates

---

# Patch Management

Current implementation:

* Manual package installation through User Data during provisioning.

---

## Production Recommendation

Use AWS Systems Manager Patch Manager to automate:

* Operating system updates
* Security patch deployment
* Patch compliance reporting
* Maintenance windows

---

# Logging and Auditing

Current implementation:

* CloudWatch Log Group
* CloudWatch Metrics
* Alarm history

---

## Production Recommendation

Enable additional audit services such as:

* AWS CloudTrail
* AWS Config
* Amazon GuardDuty
* AWS Security Hub

These services improve governance, compliance, and threat detection.

---

# Security Trade-offs

The following decisions were intentionally made for this learning environment.

| Decision                | Benefit            | Production Alternative                          |
| ----------------------- | ------------------ | ----------------------------------------------- |
| HTTP only               | Simpler validation | HTTPS with ACM                                  |
| Single NAT Gateway      | Lower cost         | Multi-AZ NAT Gateways                           |
| AWS Managed IAM Policy  | Faster setup       | Customer-managed least-privilege policies       |
| Managed WAF Rules       | Quick deployment   | Custom rule sets and tuning                     |
| No CloudTrail/GuardDuty | Reduced cost       | Enable continuous auditing and threat detection |

---

# Security Validation Performed

The following security-related scenarios were validated during implementation:

* Session Manager access without SSH
* EC2 instances inaccessible from the public internet
* ALB successfully routing only to healthy targets
* AWS WAF associated with the ALB
* CloudWatch alarms generating SNS notifications
* Automatic replacement of unhealthy instances by the Auto Scaling Group
* Encrypted root volumes and IMDSv2 enforcement confirmed through the Launch Template

---

# Security Summary

The environment applies multiple layers of security across identity, networking, compute, and operations.

Key achievements include:

* Least-privilege identity model
* Private application instances
* Layered network protection
* Secure administrative access
* Web application firewall
* Baseline DDoS protection
* Encrypted storage
* Operational monitoring and alerting

Although simplified for learning purposes, the overall design reflects many of the security practices commonly adopted in enterprise AWS environments.

---

**Next Section**

Part 6 focuses on High Availability and Resiliency, covering failure domains, Auto Scaling behavior, load balancing strategy, recovery mechanisms, and architectural trade-offs.
# High Availability and Resiliency

High availability and resiliency are fundamental design principles of modern cloud architectures. This project incorporates several AWS services and architectural patterns that improve service continuity, automate recovery, and reduce the operational impact of infrastructure failures.

The implementation intentionally balances enterprise-inspired practices with the cost constraints of a personal learning environment.

---

# Objectives

The resiliency strategy was designed to achieve the following objectives:

* Eliminate single points of failure where practical
* Maintain application availability during instance failures
* Automate infrastructure recovery
* Distribute workloads across multiple Availability Zones
* Reduce manual operational intervention
* Support future scaling requirements

---

# High Availability Strategy

The infrastructure achieves high availability through the following components:

| Component                          | Contribution                                      |
| ---------------------------------- | ------------------------------------------------- |
| Multi-Availability Zone Deployment | Protects against single AZ failures               |
| Application Load Balancer          | Routes requests only to healthy instances         |
| Target Group Health Checks         | Continuously evaluates instance health            |
| Auto Scaling Group                 | Maintains the desired number of healthy instances |
| Launch Template                    | Ensures consistent replacement instances          |
| CloudWatch                         | Detects operational issues                        |
| Amazon SNS                         | Notifies administrators of events                 |

These services work together to provide automated detection, recovery, and operational visibility.

---

# Multi-Availability Zone Design

The application is deployed across two Availability Zones within a single AWS Region.

```text id="ha-multi-az"
                AWS Region (ap-south-1)

        ┌──────────────────────────────────────┐

        Availability Zone A      Availability Zone B

          Public Subnet             Public Subnet
                │                         │
                └──── Application Load ───┘
                       Balancer (ALB)
                             │
                      Target Group
                             │
            ┌────────────────┴────────────────┐
            │                                 │
      Private Subnet                  Private Subnet
            │                                 │
       EC2 Instance A                  EC2 Instance B

            └──────── Auto Scaling Group ─────┘

        └──────────────────────────────────────┘
```

This architecture minimizes the impact of infrastructure failures within a single Availability Zone.

---

# Load Balancing Strategy

The Application Load Balancer serves as the single entry point for application traffic.

Responsibilities include:

* Accept client requests
* Perform health checks
* Route traffic only to healthy instances
* Distribute requests across Availability Zones

This improves both availability and scalability.

---

# Target Group Health Checks

The Target Group continuously monitors application health.

Validated configuration:

| Parameter           |      Value |
| ------------------- | ---------: |
| Interval            | 30 seconds |
| Timeout             |  5 seconds |
| Healthy Threshold   |          3 |
| Unhealthy Threshold |          2 |

An instance is removed from request routing only after consecutive failed health checks, reducing the likelihood of false positives.

---

# Auto Scaling Self-Healing

The Auto Scaling Group continuously maintains the desired number of healthy EC2 instances.

If an instance becomes unhealthy or terminates unexpectedly:

1. The Target Group reports the health check failure.
2. The Auto Scaling Group detects the unhealthy instance.
3. A replacement EC2 instance is launched using the Launch Template.
4. The new instance registers with the Target Group.
5. Once health checks pass, traffic resumes to the replacement instance.

This automated workflow reduces manual operational effort and helps maintain application availability.

---

# Validation Performed

The following scenarios were successfully tested during the project.

## Scenario 1 – Application Service Failure

Test performed:

* Stopped the Apache (`httpd`) service on one EC2 instance.

Observed behavior:

* Target Group marked the instance as unhealthy.
* CloudWatch Alarm transitioned to the **ALARM** state.
* Amazon SNS sent an email notification.
* Auto Scaling launched a replacement instance.
* The replacement instance passed health checks.
* CloudWatch Alarm returned to the **OK** state after recovery.

This validated the end-to-end monitoring and self-healing workflow.

---

## Scenario 2 – Instance Replacement

Validation confirmed:

* The replacement EC2 instance had a different Instance ID.
* The new instance was created from the latest Launch Template version.
* The Auto Scaling Group restored the desired capacity.

---

## Scenario 3 – CloudWatch Monitoring

Traffic was generated manually.

Observed results:

* CloudWatch Dashboard displayed increased ALB request counts.
* Metrics updated successfully.
* Dashboards reflected infrastructure activity in near real time.

---

## Scenario 4 – SNS Notifications

Successfully validated:

* Alarm notification emails
* Recovery notification emails

This confirmed operational visibility and alert delivery.

---

# Failure Scenarios

## EC2 Instance Failure

Expected behavior:

* Auto Scaling launches a replacement instance.
* Application remains available through remaining healthy instances.

Operational impact:

Minimal.

---

## Application Failure

Example:

* Web server process stops.

Observed behavior:

* Health checks fail.
* Instance is removed from request routing.
* Replacement instance is created.

Operational impact:

Low, assuming application startup completes successfully.

---

## Availability Zone Failure

Current architecture:

* Application continues serving traffic from the remaining Availability Zone.
* Auto Scaling attempts to restore capacity where possible.

Production environments should ensure sufficient capacity planning and redundant supporting services across Availability Zones.

---

## NAT Gateway Failure

Current design:

* One NAT Gateway.

Impact:

* Private instances lose outbound internet connectivity.
* Existing inbound application traffic through the ALB generally continues if instances remain healthy.

Trade-off:

Lower cost versus reduced resiliency.

---

## Internet Gateway Failure

Internet Gateways are AWS-managed highly available services within a Region. Customers do not deploy multiple Internet Gateways for redundancy within a VPC.

---

# Recovery Characteristics

| Failure                   | Automatic Recovery         | Manual Action Required          |
| ------------------------- | -------------------------- | ------------------------------- |
| EC2 Failure               | Yes                        | No                              |
| Apache Service Failure    | Yes (instance replacement) | Root cause analysis recommended |
| ALB Health Check Failure  | Yes                        | No                              |
| CloudWatch Alarm          | Yes                        | No                              |
| SNS Notification          | Yes                        | No                              |
| NAT Gateway Failure       | No                         | Replace or use Multi-AZ design  |
| Availability Zone Failure | Partial                    | Capacity review may be required |

---

# Lessons Learned

One important observation from testing was that automatic instance replacement is **not** always the optimal operational response.

During our validation:

* Stopping the Apache service caused the Target Group to mark the instance unhealthy.
* Auto Scaling replaced the instance to maintain availability.

While this behavior restored service, it did **not** determine why the service failed.

In production environments, organizations often combine automated recovery with incident investigation to identify and resolve the underlying cause.

> **Architecture Decision (ADR-018)**
>
> Auto Scaling is responsible for restoring application availability, while operational teams remain responsible for performing root cause analysis and implementing long-term corrective actions.

---

# Availability vs. Cost Trade-offs

Several architectural decisions were made to balance resiliency with AWS costs.

| Decision               | Benefit               | Trade-off                                                 |
| ---------------------- | --------------------- | --------------------------------------------------------- |
| Two Availability Zones | Improved availability | Slightly higher cost                                      |
| Single NAT Gateway     | Lower monthly cost    | Single point of failure for outbound internet access      |
| Auto Scaling           | Automated recovery    | Additional EC2 costs during replacement or scaling events |
| Managed ALB            | Simplified operations | Ongoing managed service cost                              |

These trade-offs are common in learning environments and smaller workloads, while production environments often invest in additional redundancy.

---

# Future Enhancements

The resiliency of this architecture can be further improved by introducing:

* One NAT Gateway per Availability Zone
* HTTPS with AWS Certificate Manager (ACM)
* Amazon Route 53 health checks and failover routing
* Amazon CloudFront for global content delivery
* Cross-Region disaster recovery
* AWS Backup for automated backup policies
* Multi-Region deployment for business-critical workloads

---

# Architecture Summary

This project demonstrates how multiple AWS services cooperate to provide a resilient infrastructure.

Key capabilities include:

* Multi-Availability Zone deployment
* Health-aware load balancing
* Automated instance replacement
* Operational monitoring
* Event-driven notifications
* Infrastructure consistency through Launch Templates
* Infrastructure as Code with Terraform

The architecture successfully achieved the project's objectives while remaining cost-conscious and operationally simple.

The implementation also provided practical experience with failure testing, monitoring, automated recovery, and the operational considerations required for highly available cloud environments.

---

# Final Conclusion

This architecture was intentionally designed as a learning platform that reflects many of the principles used in enterprise AWS environments.

Through the implementation and validation of networking, compute, security, monitoring, and resiliency components, the project demonstrated:

* Modular Infrastructure as Code using Terraform
* Secure network segmentation
* Automated infrastructure provisioning
* High availability across multiple Availability Zones
* Self-healing through Auto Scaling
* Operational monitoring with CloudWatch
* Event-driven alerting using Amazon SNS
* Application protection with AWS WAF
* Secure administration using AWS Systems Manager Session Manager
* Defense-in-depth security principles
* Documented architecture decisions and operational trade-offs

While intentionally simplified to control cost, the overall design establishes a strong foundation that can be extended with enterprise capabilities such as HTTPS, Route 53, CloudFront, CI/CD pipelines, AWS Config, CloudTrail, GuardDuty, Security Hub, and multi-Region disaster recovery.

This project serves as both a practical implementation of AWS Infrastructure as Code and a reference architecture for learning, demonstration, and technical interview discussions.
