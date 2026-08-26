

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
To do a local setup the project repository needs to be cloned from Github. The project will then need to have a docker image built locally to test if the app is working. Specify any port using docker build, in this case port: 5230 was used.

<img width="700" height="400" alt="local setup" src="https://github.com/user-attachments/assets/b2b6b56a-e5b7-46fe-a43c-955685d39a05" />


</br>


It can also be tested via the terminal using: curl http://localhost:{port number}/health




