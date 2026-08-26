

## Overview
I built a production-style DevOps deployment pipeline for Memos, using Docker, Amazon ECR, ECS Fargate and Terraform. The AWS infrastructure includes a VPC, public/private subnets, ALB, NAT Gateway, Route 53 and ACM, with the application secured behind HTTPS.

GitHub Actions automates Docker builds, ECR pushes, Terraform deployments and post-deployment health checks using AWS OIDC. A Terraform-destroy pipeline was was also included but as a manual trigger and not part of the automation. 

## Contents


## Project structure 
<img width="1264" height="900" alt="Project-structure" src="https://github.com/user-attachments/assets/56f10664-4ca2-42bd-9970-4587bf97a6d6" />

## Architecture Diagram



## Live App

https://github.com/user-attachments/assets/3047e9e4-0488-4b21-aca5-741f2f2e3dbb


## Local Setup
To do a local setup the project repository needs to be cloned from Github. The app will then need a docker image built locally to test if it is working. Specify the port that was used for the original project using docker build.

Steps used:
- git clone git@github.com:YOUR-USERNAME/YOUR-REPO.git
- cd YOUR-REPO

- docker build --platform linux/amd64 -t memos:latest .

- docker run -d --name memos -p 8081:8081 memos:latest


<img width="700" height="400" alt="local setup" src="https://github.com/user-attachments/assets/b2b6b56a-e5b7-46fe-a43c-955685d39a05" />


</br>

It can also be tested via the terminal using: curl http://localhost:{port number}/health


# Docker Local set up
After the Dockerfile/ stage was complete it was tested locally via the container before moving onto the infrastructure. 

Running container:
<img width="960" height="579" alt="Screenshot 2026-07-23 at 12 13 21" src="https://github.com/user-attachments/assets/0239cf01-a287-4382-a2a0-46ca7de03f3b" />

</br>

<img width="1432" height="854" alt="memos-local" src="https://github.com/user-attachments/assets/7c0257fe-5719-4c33-9904-112fe5777cd0" />




