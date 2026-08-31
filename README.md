

## Overview
I built a production-style DevOps deployment pipeline for Memos, using Docker, Amazon ECR, ECS Fargate and Terraform. The AWS infrastructure includes a VPC, public/private subnets, ALB, NAT Gateway, Route 53 and ACM, with the application secured behind HTTPS.

GitHub Actions automates Docker builds, ECR pushes, Terraform deployments and post-deployment health checks using AWS OIDC. A Terraform-destroy pipeline was also included but as a manual trigger and not part of the automation. 

## Contents
- [Project Structure](#project-structure)
- [Architecture Diagram](#architecture-diagram)
- [Live app](#live-app)
- [Local Setup](#local-setup)
- [Docker Local Setup](#docker-local-setup)
- [Dockerfile Optimisation](#dockerfile-optimisation)
- [Terraform Overview](#terraform-overview)
- [CI/CD Pipelines](#cicd-pipelines)
- [Memos App](#memos-app)

## Project Structure 
<img width="1264" height="900" alt="Project-structure" src="https://github.com/user-attachments/assets/56f10664-4ca2-42bd-9970-4587bf97a6d6" />

## Architecture Diagram
**Key point:** for this project I used a single NAT Gateway to provide outbound internet access for both private subnets. The reason behind this was because it keeps the architecture simple and significantly reduces AWS costs. Even though in a production environment one NAT Gateway per availability zone is used for higher availability, in this case I chose one after deciding that the intended application was for a small scale environment. 


<img width="741" height="1090" alt="ecs drawio" src="https://github.com/user-attachments/assets/4140536a-e2d9-4e05-b5e2-d326608e3089" />





## Live App

https://github.com/user-attachments/assets/3047e9e4-0488-4b21-aca5-741f2f2e3dbb


## Local Setup
To do a local setup the project repository needs to be cloned from Github. The app will then need a docker image built locally to test if it is working. Specify the port that was used for the original application using docker build.

Steps used:
- git clone git@github.com:YOUR-USERNAME/YOUR-REPO.git
- cd YOUR-REPO

- docker build --platform linux/amd64 -t memos:latest .

- docker run -d --name memos -p 8081:8081 memos:latest


It can also be tested via the terminal using: curl http://localhost:{port number}/health


## Docker Local Set Up
After the Dockerfile/ stage was complete I tested the app locally via the container before moving onto the infrastructure. 

<img width="700" height="379" alt="Screenshot 2026-07-23 at 12 13 21" src="https://github.com/user-attachments/assets/0239cf01-a287-4382-a2a0-46ca7de03f3b" />

<img width="900" height="500" alt="memos-local" src="https://github.com/user-attachments/assets/7c0257fe-5719-4c33-9904-112fe5777cd0" />


## Dockerfile optimisation 

My final image is approximately 40 MB. By using a multi-stage build, I removed the Node.js and Go build environments from the production image and used Alpine as the runtime base. Compared with the kind of 1 GB-plus image a single-stage build could produce, this drastically reduces the image size.


| Dockerfile approach                        | Estimated image size | Why                                                                  |
| ------------------------------------------ | -------------------: | -------------------------------------------------------------------- |
| Single-stage with Go + Node + dependencies |            ~1–1.5 GB | Go/Node toolchains, `node_modules`, Go modules, source + build tools |
| Backend-only Go image                      |         ~800 MB–1 GB | Go compiler/toolchain remains in the image                           |
| Multi-stage + Debian                       |          ~100–150 MB | Build tools removed, but larger runtime base                         |
| **Multi-stage + Alpine**                   |         **~40 MB** ✅ | Only compiled application + minimal runtime                          |



## Terraform Overview

Below shows the main overview of the whole infrastructure. 

| Component                     | AWS Resource                  | Purpose                                                                        |
| ----------------------------- | ----------------------------- | ------------------------------------------------------------------------------ |
| **VPC**                       | VPC                           | Provides the isolated network for the application                              |
| **Public Subnets**            | 2 × Public Subnets            | Hosts internet-facing resources such as the ALB and NAT Gateway                |
| **Private Subnets**           | 2 × Private Subnets           | Runs the ECS Fargate tasks without direct public internet access               |
| **Internet Gateway**          | Internet Gateway              | Provides internet connectivity to the public subnets                           |
| **NAT Gateway**               | 1 × NAT Gateway               | Provides outbound internet access for resources in the private subnets         |
| **Elastic IP**                | 1 × Elastic IP                | Provides a fixed public IP for the NAT Gateway                                 |
| **Route Tables**              | Public & Private Route Tables | Controls traffic between subnets, the Internet Gateway and NAT Gateway         |
| **ECR**                       | ECR Repository                | Stores the Docker image used by ECS                                            |
| **ECS**                       | ECS Fargate Cluster & Service | Runs the containerised Memos application                                       |
| **Task Definition**           | Fargate Task Definition       | Defines the container image, CPU, memory, networking and logging configuration |
| **Application Load Balancer** | ALB                           | Distributes incoming HTTPS traffic to the ECS tasks                            |
| **Target Group**              | ALB Target Group              | Registers and performs health checks on the ECS tasks                          |
| **Security Groups**           | ALB & ECS Security Groups     | Controls inbound and outbound network traffic                                  |
| **IAM**                       | ECS Execution & Task Roles    | Provides ECS with the permissions required to run the application              |
| **CloudWatch**                | CloudWatch Log Group          | Collects and retains ECS container logs                                        |
| **ACM**                       | SSL/TLS Certificate           | Provides HTTPS encryption for the application                                  |
| **Route 53**                  | DNS Record                    | Routes `tm.<your-domain>` to the Application Load Balancer                     |
| **S3**                        | Terraform State Bucket        | Stores Terraform state remotely and securely                                   |


## CI/CD Pipelines
Github actions automates the CI/CD pipelines for three of the pipleines which are: build & push, deploy, and post-deploy. The fourth pipeline which is destroy is not automated but is triggered manually through Github workflows. 

### Build & Push
This pipeline builds the Docker Image and Pushes the image to ECR.

<img width="1160" height="440" alt="Screenshot 2026-08-28 at 19 26 45" src="https://github.com/user-attachments/assets/9281d5d4-b489-4594-ad7c-1a998661e2ab" />


### Deploy
This phase of the automation deploys the whole infrastructure needed for the app to run in the cloud.

<img width="1409" height="538" alt="deploy" src="https://github.com/user-attachments/assets/473382b3-127e-42bf-87b1-d102be41a32b" />



### Post Deploy
This runs an application health check after the deployment stage is completed.

<img width="1397" height="576" alt="post-deploy" src="https://github.com/user-attachments/assets/68999b13-37d7-4949-9e2f-e64651b956d8" />


### Destroy
This pipeline destroys the whole infrastructure by manually destroying through Github. A confirmation word is required before this pipeline starts.

<img width="1414" height="663" alt="terra destroy" src="https://github.com/user-attachments/assets/9d75231e-16c0-4d15-8d5f-a43070c56fdf" />





## Memos App
### Memos
Memos is a lightweight, open-source note taking and management application. Its main purpose is to allow users to create, organise, and manage personal notes through a web interface. The application has a Go-based backend and web frontend, making it suitable for containerisation and deployment as a single application.

### Why this app?
I chose Memos as the application for this project because it has enough complexity to demonstrate a real-world cloud deployment. It's a full-stack application with a database, allowing me to containerise the app through to automated deployment. 

### Why host it on ECS instead of a VM, Vercel or Netlify?
I chose Amazon ECS with Fargate because the main purpose of the project was to develop my DevOps and AWS skills around containers and infrastructure automation.

A traditional VM would require me to manage the operating system, Docker run time, and other configurations myself. ECS Fargate allows AWS to manage the infrastructure while I focus on the container, task definition, networking and automation/deployment.

Although Vercel and Netlify maybe easier to use for deployment, but it would not provide me with the opportunity to utilise my skills to build end to end deployment. Therefore, ECS was better suited to demonstrate production-style DevOps practices.

### How many users are there / how many are you expecting?
This project is mainly for my portfolio and a learning project, so it was not intended for a large scale environment. Therefore, I designed the deployment for approximately 10-50 users. 




