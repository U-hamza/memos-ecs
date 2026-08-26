

## Overview
I built a production-style DevOps deployment pipeline for Memos, using Docker, Amazon ECR, ECS Fargate and Terraform. The AWS infrastructure includes a VPC, public/private subnets, ALB, NAT Gateway, Route 53 and ACM, with the application secured behind HTTPS.

GitHub Actions automates Docker builds, ECR pushes, Terraform deployments and post-deployment health checks using AWS OIDC.

## Contents


## Project structure 
<img width="1264" height="900" alt="Project-structure" src="https://github.com/user-attachments/assets/56f10664-4ca2-42bd-9970-4587bf97a6d6" />

## Architecture Diagram



## Live App

https://github.com/user-attachments/assets/23398abf-b8d2-4cd0-870d-8e2c9c2f901b







