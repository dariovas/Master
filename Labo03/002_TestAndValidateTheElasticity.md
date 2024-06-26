# Task 003 - Test and validate the elasticity

![Schema](./img/CLD_AWS_INFA.PNG)


## Simulate heavy load to trigger a scaling action

* [Install the package "stress" on your Drupal instance](https://www.geeksforgeeks.org/linux-stress-command-with-examples/)

* [Install the package htop on your Drupal instance](https://www.geeksforgeeks.org/htop-command-in-linux-with-examples/)

* Check how many vCPU are available (with htop command)

```
[INPUT]
htop

[OUTPUT]
//copy the part representing vCPus, RAM and swap usage
```
![](./img/CLD_Drupal_htop.png)

### Stress your instance

```
[INPUT]
stress -c 2

[OUTPUT]
//copy the part representing vCPus, RAM and swap usage
```
![](./img/CLD_Drupal_StressCPU.png)

* (Scale-IN) Observe the autoscaling effect on your infa

```
Cloud watch metric
```

![](./img/CLD_AWS_CPU_Metrics.png)

```
ECC2 instances list (running state)
```
![](./img/CLD_AWS_EC2_InstancesList.png)

[Source](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html)
```
[INPUT]
aws ec2 describe-instances --filters "Name=key-name,Values=CLD_KEY_DRUPAL_DEVOPSTEAM16" --query 'Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value}' --output table

[OUTPUT]
-------------------------------------------------------------------------------
|                              DescribeInstances                              |
+------------+-----------------------+----------------------------------------+
|     AZ     |       Instance        |                 Name                   |
+------------+-----------------------+----------------------------------------+
|  eu-west-3a|  i-02bca9e2bf33f94f9  |  AUTO_EC2_PRIVATE_DRUPAL_DEVOPSTEAM16  |
|  eu-west-3a|  i-045f37ef867cad5ca  |  AUTO_EC2_PRIVATE_DRUPAL_DEVOPSTEAM16  |
|  eu-west-3b|  i-02e001339e1a76236  |  AUTO_EC2_PRIVATE_DRUPAL_DEVOPSTEAM16  |
|  eu-west-3b|  i-07921f497bfff4624  |  AUTO_EC2_PRIVATE_DRUPAL_DEVOPSTEAM16  |
+------------+-----------------------+----------------------------------------+
```

```
Activity history
```

![](./img/CLD_AWS_ActivityHistory.png)

```
Cloud watch alarm target tracking
```

![](./img/CLD_AWS_AlarmHigh.png)


* (Scale-OUT) As soon as all 4 instances have started, end stress on the main machine.

[Change the default cooldown period](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-scaling-cooldowns.html)

```
Cloud watch metric
```
![](./img/CLD_AWS_CPU_MetricsLow.png)

```
EC2 instances list (terminated state)
```
![](./img/CLD_AWS_EC2_InstancesTermList.png)

```
Activity history
```
![](./img/CLD_AWS_ActivityHistoryTerm.png)

## Release Cloud resources

Once you have completed this lab release the cloud resources to avoid
unnecessary charges:

* Terminate the EC2 instances.
    * Make sure the attached EBS volumes are deleted as well.
* Delete the Auto Scaling group.
* Delete the Elastic Load Balancer.
* Delete the RDS instance.

(this last part does not need to be documented in your report.)

## Delivery

Inform your teacher of the deliverable on the repository (link to the commit to retrieve)
