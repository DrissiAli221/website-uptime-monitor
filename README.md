# Serverless Global Uptime Monitor

A multi-region website uptime monitoring system built entirely with **Terraform** and **AWS Serverless** services. Checks website availability from US and EU regions simultaneously, stores results in DynamoDB, and sends email alerts when sites go down.

## Architecture

![Architecture Diagram](<./AWS%20(2025)%20horizontal%20framework.png>)

## Tech Stack

| Component        | Technology          |
| ---------------- | ------------------- |
| Infrastructure   | Terraform           |
| Compute          | AWS Lambda (Python) |
| Orchestration    | AWS Step Functions  |
| Database         | DynamoDB            |
| Scheduling       | EventBridge         |
| API              | API Gateway (HTTP)  |
| Frontend Hosting | S3 Static Website   |
| Alerting         | SNS → Email         |

## Features

- **Multi-Region Monitoring** - Parallel health checks from US (us-east-1) and EU (eu-west-1)
- **Cross-Region Invocation** - Proxy Lambda enables Step Functions to invoke EU Lambda
- **Automatic Alerting** - SNS email notifications on website downtime
- **Dashboard** - Real-time Chart.js visualization of latency and status
- **Fully Serverless** - Pay only for execution time, no servers to manage
- **Infrastructure as Code** - 100% Terraform, easily reproducible

## Project Structure

```
uptime-monitor/
├── src/
│   ├── main.tf              # Multi-region checker module instantiation
│   ├── versions.tf          # Terraform & provider versions
│   ├── database.tf          # DynamoDB table
│   ├── dashboard.tf         # Reader Lambda + API Gateway
│   ├── event.tf             # EventBridge schedule
│   ├── frontend.tf          # S3 static website hosting
│   ├── iam.tf               # IAM roles and policies
│   ├── lambda.tf            # Lambda packaging
│   ├── notifications.tf     # SNS topic and email subscription
│   ├── proxy.tf             # Cross-region Lambda proxy
│   ├── saver.tf             # Result aggregator Lambda
│   ├── stepfucntions.tf     # Step Functions state machine
│   ├── modules/
│   │   └── checker/         # Reusable uptime checker module
│   ├── state_machines/
│   │   └── multi_region_workflow.json
│   ├── frontend/            # Dashboard HTML/JS
│   ├── reader/              # API Lambda (Python)
│   ├── saver/               # Aggregator Lambda (Python)
│   └── proxy/               # Cross-region proxy Lambda (Python)
└── aws-backend/             # S3 backend for Terraform state
```

## Deployment

### Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0

### Deploy

```bash
cd src

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply
```

### Outputs

After deployment, Terraform outputs:

- `api_url` - The API Gateway endpoint for `/history`
- `dashboard_url` - S3 static website URL

## How It Works

1. **EventBridge** triggers the Step Functions state machine every 5 minutes
2. **Step Functions** runs two parallel branches:
   - Direct invocation of US Lambda (us-east-1)
   - Proxy Lambda invokes EU Lambda across regions (eu-west-1)
3. Both Lambdas perform HTTP requests to target website, measuring latency
4. **Saver Lambda** merges results from both regions
5. Results stored in **DynamoDB** with timestamp, latency, and status
6. If site is down, **SNS** sends an email alert
7. **Frontend dashboard** polls API Gateway for history and displays charts

## License

MIT
