# Task 001 - Configure Auto Scaling

![Schema](./img/CLD_AWS_INFA.PNG)

* Follow the instructions in the tutorial [Getting started with Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/GettingStartedTutorial.html) to create a launch template.

* [CLI Documentation](https://docs.aws.amazon.com/cli/latest/reference/autoscaling/)

## Pre-requisites

* Networks (RTE-TABLE/SECURITY GROUP) set as at the end of the Labo2.
* 1 AMI of your Drupal instance
* 0 existing ec2 (even is in a stopped state)
* 1 RDS Database instance - started
* 1 Elastic Load Balancer - started

## Create a new launch configuration. 
[Source](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-launch-template.html)

## Create a new launch template. 

|Key|Value|
|:--|:--|
|Name|LT-DEVOPSTEAM[XX]|
|Version|v1.0.0|
|Tag|Name->same as template's name|
|AMI|Your Drupal AMI|
|Instance type|t3.micro (as usual)|
|Subnet|Your subnet A|
|Security groups|Your Drupal Security Group|
|IP Address assignation|Do not assign|
|Storage|Only 10 Go Storage (based on your AMI)|
|Advanced Details/EC2 Detailed Cloud Watch|enable|
|Purchase option/Request Spot instance|disable|

```
[INPUT]
//cli command is optionnal. Important is the screen shot to delivery in next step (testing and validation)
Done with the AWS Web Console.

[OUTPUT]
```

## Create an autoscaling group

* Choose launch template or configuration

|Specifications|Key|Value|
|:--|:--|:--|
|Launch Configuration|Name|ASGRP_DEVOPSTEAM[XX]|
||Launch configuration|Your launch configuration|
|Instance launch option|VPC|Refer to infra schema|
||AZ and subnet|AZs and subnets a + b|
|Advanced options|Attach to an existing LB|Your ELB|
||Target group|Your target group|
|Health check|Load balancing health check|Turn on|
||health check grace period|10 seconds|
|Additional settings|Group metrics collection within Cloud Watch|Enable|
||Health check grace period|10 seconds|
|Group size and scaling option|Desired capacity|1|
||Min desired capacity|1|
||Max desired capacity|4|
||Policies|Target tracking scaling policy|
||Target tracking scaling policy Name|TTP_DEVOPSTEAM[XX]|
||Metric type|Average CPU utilization|
||Target value|50|
||Instance warmup|30 seconds|
||Instance maintenance policy|None|
||Instance scale-in protection|None|
||Notification|None|
|Add tag to instance|Name|AUTO_EC2_PRIVATE_DRUPAL_DEVOPSTEAM[XX]|

```
[INPUT]
<<<<<<< HEAD
//cli command
aws autoscaling   create-auto-scaling-group --auto-scaling-group-name ASGRP_DEVOPSTEAM16 --launch-configuration-name LT-DEVOPSTEAM16 --vpc-zone-identifier "subnet-0403d99111665b019,subnet-05fd5dab104c7d287" 
--load-balancer-names "ELB-DEVOPSTEAM16  --target-group-arns arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM16/d34751cfd970b57a 
--health-check-type ELB --health-check-grace-period 10 --min-size 1 --max-size 1 --desired-capacity 1
=======
//cli command is optionnal. Important is the screen shot to delivery in next step (testing and validation)
>>>>>>> upstream/main


https://awscli.amazonaws.com/v2/documentation/api/latest/reference/autoscaling/create-auto-scaling-group.html
[OUTPUT]
```

* Result expected

The first instance is launched automatically.

Test ssh and web access.

```
[INPUT]
//ssh login

[OUTPUT]
```

```
//screen shot, web access (login)
```
