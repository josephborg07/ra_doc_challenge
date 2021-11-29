# IaC for containerized app

## 1. General Overview
In this step we will simply push the application built in step 1 to AWS using simple terraform configuration. The end result, will be that the applicaiton will be exposed publically.

Our containers will run on ECS which is backed by an auto-scale group consisting of a maximum of 2 t2.small intances. The tasks are defined in a task defintion. We will then push the docker images to the ECR repository and initiate the task out of the ECS task definition

## 2. Components

## 3. Steps
Below are the steps required to run the app

1. `terraform init` - This will initialize terraform (create the local state file,initiate the modules and create other terraform metadata for terraform to operate.
2. `terraform plan` - terraform will execute a dry run on its config in order to display what changes will be applied.
3. `terraform apply` - Invoking terraform to apply the code in the directory. Prior to actually committing the code (and creating the infrastructure), terraform will ask us to confirm our changes.
4. Tag and push docker images to ECR repo:
    - This will be required for our tasks to work as intended
    - on your local machine, you'll need to to tag both fe_service and be_service using the following command:
        
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

5. We're now ready to initiate a task from the services defined in the task defintion. We'll be doing this from the AWS GUI console to ensure everything runs smoothly as intended.