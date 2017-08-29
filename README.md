## Intro/Dependencies
This project assumes that you have an AWS user created with Admin level access and API Access enabled.  Configure this on the command line with these instructions (http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

Install and configure Terraform, tested with version 10.2 (https://www.terraform.io/downloads.html)

Install and configure Docker, tested on Ubuntu 17.04 (https://www.docker.com/community-edition)

Additional manual step that cannot be automated are to create a certificate in Amazon using Amazon Certificate Manager and record this certificate ARN, Terraform will require this.  You will also need an EC2 key created that terraform can reference to start your EC2 instances, you will only need the name of the key.(https://aws.amazon.com/documentation/acm/) (http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

### Quick Terraform Note
Ensure that there are no spaces in copy/pasted fields.  Terraform will interpret them literally and applies may fail.

### Deploy the Infrastructure

First, review the vpc.tf file located in the terraform directory.  Ensure that the IP Address subnets do not overlap with any current subnets.  Replace them if necessary with subnets that do not overlap.  Also ensure that you have the AWS_PROFILE variable set to the correct account in your shell.

```sh
$ cd terraform
$ terraform init
$ terraform plan
```
Terraform will ask you the following questions:
```sh
var.key_name
  Enter a value: <ec2 keypair name>

var.ssl_certificate_arn
  Enter a value: <certificate arn>
```
Review the plan, it will list all of the resources that are going to be created

```sh
$ terraform apply
```

Once this step finished you should have a full infrastructure deployed and ready to use.  This includes Application Load Balancers, a Docker Cluster(ECS), Logging with Cloudwatch, Application Autoscaling for the containers, Systems Autoscaling with Spot Fleet, a VPC, all the required networking components in a VPC, and all the necessary permissions and security groups to wire the components together.

### Build the Application
To build the application
```sh
$ cd ../application
$ docker build -t docker-mongo .
```

### Deploy the Application

After terraform is finished there should be an output on the command line that looks like this:
```sh
docker_mongo_repository = 352484006547.dkr.ecr.us-west-2.amazonaws.com/docker-mongo
```

Run the following commands to push the docker image to the repo

```sh
$ aws ecr get-login --no-include-email --region us-west-2 | bash -
$ docker tag docker-mongo:latest 352484006547.dkr.ecr.us-west-2.amazonaws.com/docker-mongo:latest
$ docker push 352484006547.dkr.ecr.us-west-2.amazonaws.com/docker-mongo:latest
```

Edit the application.tf file and replace the variable docker_image with the image pushed above.  Run the following:

```sh
$ cd ../terraform
$ terraform plan
$ terraform apply
```

After about five minutes the application should be connected to the load balancer.  From the AWS Console navigate to EC2
and Load Balancers.  Retrieve the public URL for the load balancer and you should be able to connect to the application.

### Cleanup
Issue the following command to remove all the resources created for this exercise

```sh
$ terraform destroy
```

### Notes on Improvements
This is just a demo application.  Ideally there should be an API Gateway between the application load balancer and the internet
at large.  This gives you the ability for rate limiting, consistent API tokenization, among other capabilities.

Also, the requirements were to run MongoDB with the application.  For simplicity the containers are linked, but the Mongo
instances do not have awareness of each other.  They should be abstracted away into a cluster and the application should interface with them
through the clustered topology.  This demo is also running on Spot Fleet, most fleets are diversified across many instance types to ensure 
application uptime.  Do to the inconsistent performance I would not recommend running Mongo on Spot Fleet.
