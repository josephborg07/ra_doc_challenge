# IaC for containerized app

## 1. General Overview
In this step we will simply push the application built in step 1 to AWS using simple terraform configuration. The end result, will be that the applicaiton will be exposed publically.

Our containers will run on ECS which is backed by an auto-scale group consisting of a maximum of 2 t2.small intances. The tasks are defined in a task defintion. We will then push the docker images to the ECR repository and initiate the task out of the ECS task definition

## 2. Components
- S3 bucket - This is simply best practice for everyone making use of this TF directory to share the same state file. Without this everyone would have a local copy of the state file and change the infrastructure with every `terraform apply`.
- VPC - A vpc will be created in order to setup our network, including subnets on different availability zones, internet gateway, route table (to route traffic from internal to external), security group (to allow incoming requests based on port)
- ECS - Our own elastic container service cluster to orchestrate our containerized infrastructure.
- ECS Task defintion - The defintion of our application based on 2 containers (Frontend and backend)
- ECS Services - the ECS services ensuring that our application runs without failure across our autoscale group.
- Autoscale group - This will be used to determine the number of VMs (EC2 instances used by our ECS cluster when attached - This is achieved by using an ECS enabled AMI and pointing the ecs daemon on the EC2 instances to the our ECS cluster).
- Launch configuration - Used to define the following when creating new EC2 instances in the autoscale group:
    - define the IAM role profile to attach to the instance
    - specifying the ECS enabled AMI image to use
    - Poiting any EC2 instance deployed to our ECS cluster by updating `/etc/ecs/ecs.config`
    - Specifying the ssh key pair to use
- ALB - Used to expose our ECS cluster publically
- IAM role - Used to grant access to the EC2 instance to ECS cluster

## 3. Pre-requisites
- S3 bucket named **doc_state** (used for terraform's state file).
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

### TLDR
1. Define local credentials (Environment variables or in local shared credentials)
2. `terraform init`
3. `terraform plan` - ensure all config is what's expected
4. `terraform apply`
5. Point ra.doc-challenge.com to the same IPs used by the ALB's public DNS endpoint.

**NOTE:** The application will not work without the final step as the LB is expecting the ra.doc-challenge.com in the request's host header


### Long version

Below are the steps required to run the app

1. Define AWS credentials; either as environment variables or in the local credentials file under `~/.aws/credentials`; reference can be made to the following:
    - https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables
    - https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file
2. `terraform init` - Once in the `./terraform` directory, executing this command will initialize terraform (create the local state file,initiate the aws modules and create other terraform metadata for terraform to operate.
3. `terraform plan` - terraform will execute a dry run on its config in order to display what changes will be applied.
4. `terraform apply` - Invoking terraform to apply the code in the directory. Prior to actually committing the code (and creating the infrastructure), terraform will ask us to confirm our changes.
5. Once all the infrastructure is applied, terraform will output the public DNS endpoint exposed by the ALB. We need to point `ra.doc-challenge.com` to the same public IP belonging to the ALB's public DNS endpoint (IP can be established by running `nslookup <ALB_Public_endpoint>.us-east-1.elb.amazonaws.com`).
6. You can then access the Frontend on http://ra.doc-challenge.com, which will request stats from the python backend on http://ra.doc-challenge.com/stats