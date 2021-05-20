# MiiingleFiles: Infrastructure
All of the AWS resources that we need to provision

Lets keep it simple, everything goes in a single workspace with s3 backend for the state.
- artifacts: s3 buckets and ECR repo
- ci_pipeline: code repo + CI/CD pipeline
- environment: template for a standalone deployment
