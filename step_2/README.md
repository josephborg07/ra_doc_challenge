# IaC for containerized app

## 1. General Overview
In this step we will simply push the application built in step 1 to AWS using simple terraform configuration. The end result, will be that the applicaiton will be exposed publically.

Our containers will run on ECS which is backed by an auto-scale group consisting of a maximum of 2 t2.small intances. The tasks are defined in a task defintion. We will then push the docker images to the ECR repository and initiate the task out of the ECS task definition

## 2. Components
- VPC - A vpc will be created in order to setup our network, including subnets on different availability zones, internet gateway, route table (to route traffic from internal to external), security group (to allow incoming requests based on port)

- ECS - Our own elastic container service cluster to orchestrate our containerized infrastructure.

- ECS Task defintion - The defintion of our application based on 2 containers (Frontend and backend)

- Autoscale group - This will be used to determine the number of VMs (EC2 instances used by our ECS cluster when attached - This is achieved by using an ECS enabled AMI and pointing the ecs daemon on the EC2 instances to the our ECS cluster).

- Launch configuration - Used to define the following when creating new nodes in the autoscale group:
    - define the IAM role profile to use when launching new nodes in the cluster
    - specifying the ECS enabled AMI image to use
    - Poiting the EC2 instance to our ECS cluster
    - Specifying the ssh key pair to use

- ALB - Used to expose our ECS cluster publically over a randomly generated public DNS name

- IAM role - Used to grant access to the EC2 instance to ECS cluster

## 3. Pre-requisites
- ECR repo already created (created from GUI)
- Docker images to be used in this step already pushed to ECR repo; The following steps have been followed to achieve this:
        
    1. Login to ECR 
        
        `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 047318192142.dkr.ecr.us-east-1.amazonaws.com`
    2. build the images using docker:
        
        `docker build -t doc_fe_image -f dockerfile-build-fe .`
        
        `docker build -t doc_be_image -f dockerfile-build-be .`
        
    3. Tag the newly created docker images

        `docker tag doc_fe_image:latest 047318192142.dkr.ecr.us-east-1.amazonaws.com/doc_ecr_fe:latest`

        `docker tag doc_be_image:latest 047318192142.dkr.ecr.us-east-1.amazonaws.com/doc_ecr_be:latest`

    4. Push the newly taged images to the ECR repo

        `docker push 047318192142.dkr.ecr.us-east-1.amazonaws.com/doc_ecr_fe:latest`

        `docker push 047318192142.dkr.ecr.us-east-1.amazonaws.com/doc_ecr_be:latest`

## 4. Steps
Below are the steps required to run the app

1. `terraform init` - Once in the `./terraform` directory, executing this command will initialize terraform (create the local state file,initiate the aws modules and create other terraform metadata for terraform to operate.
2. `terraform plan` - terraform will execute a dry run on its config in order to display what changes will be applied.
3. `terraform apply` - Invoking terraform to apply the code in the directory. Prior to actually committing the code (and creating the infrastructure), terraform will ask us to confirm our changes.
4. Point the local hostsfile to the public IPs associated with the newly created ALB endpoint. To do so simply simply point the public IP/s to ra.doc-challenge.com using the local hosts file (the ALB is configured to listen to that DNS endpoint).