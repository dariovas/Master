# Custom AMI and Deploy the second Drupal instance

In this task you will update your AMI with the Drupal settings and deploy it in the second availability zone.

## Task 01 - Create AMI

### [Create AMI](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-image.html)

Note : stop the instance before

|Key|Value for GUI Only|
|:--|:--|
|Name|AMI_DRUPAL_DEVOPSTEAM[XX]_LABO02_RDS|
|Description|Same as name value|

```bash
[INPUT]
aws ec2 create-image --instance-id i-0331f782b4b45f420 --name "AMI_DRUPAL_DEVOPSTEAM16_LABO02_RDS" --description "AMI_DRUPAL_DEVOPSTEAM16_LABO02_RDS" --tag-specifications ResourceType=image,Tags=[{Key=Name,Value=AMI_DRUPAL_DEVOPSTEAM16_LABO02_RDS}]
[OUTPUT]
{
    "ImageId": "ami-044b78cb221a345cb"
}
```

## Task 02 - Deploy Instances

* Restart Drupal Instance in Az1

* Deploy Drupal Instance based on AMI in Az2

|Key|Value for GUI Only|
|:--|:--|
|Name|EC2_PRIVATE_DRUPAL_DEVOPSTEAM[XX]_B|
|Description|Same as name value|

```bash
[INPUT]

aws ec2 run-instances --image-id ami-044b78cb221a345cb --count 1 --instance-type t3.micro --key-name CLD_KEY_DRUPAL_DEVOPSTEAM16 --private-ip-address 10.0.16.140  --security-group-ids sg-05cddfeca33d9830b  --subnet-id subnet-0403d99111665b019 --tag-specifications ResourceType=instance,Tags=[{Key=Name,Value=EC2_PRIVATE_DRUPAL_DEVOPSTEAM16_B}]
 
[OUTPUT]

{
    "Groups": [],
    "Instances": [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-044b78cb221a345cb",
            "InstanceId": "i-07303374c9b239b00",
            "InstanceType": "t3.micro",
            "KeyName": "CLD_KEY_DRUPAL_DEVOPSTEAM16",
            "LaunchTime": "2024-03-23T10:47:17+00:00",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "eu-west-3b",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-10-0-16-140.eu-west-3.compute.internal",
            "PrivateIpAddress": "10.0.16.140",
            "ProductCodes": [],
            "PublicDnsName": "",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
            "StateTransitionReason": "",
            "SubnetId": "subnet-0403d99111665b019",
            "VpcId": "vpc-03d46c285a2af77ba",
            "Architecture": "x86_64",
            "BlockDeviceMappings": [],
            "ClientToken": "ae10311f-da5e-4887-9ac0-815f88ba9c2a",
            "EbsOptimized": false,
            "EnaSupport": true,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Attachment": {
                        "AttachTime": "2024-03-23T10:47:17+00:00",
                        "AttachmentId": "eni-attach-01b6cf9801e8a90da",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
                        "Status": "attaching",
                        "NetworkCardIndex": 0
                    },
                    "Description": "",
                    "Groups": [
                        {
                            "GroupName": "SG-PRIVATE-DRUPAL-DEVOPSTEAM16",
                            "GroupId": "sg-05cddfeca33d9830b"
                        }
                    ],
                    "Ipv6Addresses": [],
                    "MacAddress": "0a:17:bb:90:5c:3f",
                    "NetworkInterfaceId": "eni-0cf8c274a7713fd3b",
                    "OwnerId": "709024702237",
                    "PrivateIpAddress": "10.0.16.140",
                    "PrivateIpAddresses": [
                        {
                            "Primary": true,
                            "PrivateIpAddress": "10.0.16.140"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Status": "in-use",
                    "SubnetId": "subnet-0403d99111665b019",
                    "VpcId": "vpc-03d46c285a2af77ba",
                    "InterfaceType": "interface"
                }
            ],
            "RootDeviceName": "/dev/xvda",
            "RootDeviceType": "ebs",
            "SecurityGroups": [
                {
                    "GroupName": "SG-PRIVATE-DRUPAL-DEVOPSTEAM16",
                    "GroupId": "sg-05cddfeca33d9830b"
                }
            ],
            "SourceDestCheck": true,
            "StateReason": {
                "Code": "pending",
                "Message": "pending"
            },
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "EC2_PRIVATE_DRUPAL_DEVOPSTEAM16_B"
                }
            ],
            "VirtualizationType": "hvm",
            "CpuOptions": {
                "CoreCount": 1,
                "ThreadsPerCore": 2
            },
            "CapacityReservationSpecification": {
                "CapacityReservationPreference": "open"
            },
            "MetadataOptions": {
                "State": "pending",
                "HttpTokens": "optional",
                "HttpPutResponseHopLimit": 1,
                "HttpEndpoint": "enabled",
                "HttpProtocolIpv6": "disabled",
                "InstanceMetadataTags": "disabled"
            },
            "EnclaveOptions": {
                "Enabled": false
            },
            "PrivateDnsNameOptions": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            },
            "MaintenanceOptions": {
                "AutoRecovery": "default"
            },
            "CurrentInstanceBootMode": "legacy-bios"
        }
    ],
    "OwnerId": "709024702237",
    "ReservationId": "r-053ce93b8b9f93e98"
}
```

## Task 03 - Test the connectivity

### Update your ssh connection string to test

* add tunnels for ssh and http pointing on the B Instance

```bash
ssh devopsteam16@15.188.43.46 -i CLD_KEY_DMZ_DEVOPSTEAM16.pem -L 2224:10.0.16.140:22 -L 2225:10.0.16.140:8080
```

## Check SQL Accesses

FROM A :

```sql
[INPUT]
mysql -h dbi-devopsteam16.cshki92s4w5p.eu-west-3.rds.amazonaws.com -u bn_drupal -p

[OUTPUT]

mysql: Deprecated program name. It will be removed in a future release, use '/opt/bitnami/mariadb/bin/mariadb' instead
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 63
Server version: 10.11.7-MariaDB managed by https://aws.amazon.com/rds/

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
+--------------------+
2 rows in set (0.001 sec)
```

FROM B :

```sql
[INPUT]
mysql -h dbi-devopsteam16.cshki92s4w5p.eu-west-3.rds.amazonaws.com -u bn_drupal -p

[OUTPUT]

mysql: Deprecated program name. It will be removed in a future release, use '/opt/bitnami/mariadb/bin/mariadb' instead
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 89
Server version: 10.11.7-MariaDB managed by https://aws.amazon.com/rds/

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| bitnami_drupal     |
| information_schema |
+--------------------+
2 rows in set (0.001 sec)

```

### Check HTTP Accesses

```bash
ssh devopsteam16@15.188.43.46 -i CLD_KEY_DMZ_DEVOPSTEAM16.pem -L 2225:10.0.16.140:8080

connected with http://localhost:2225/
```

### Read and write test through the web app

* Login in both webapps (same login)

* Change the users' email address on a webapp... refresh the user's profile page on the second and validated that they are communicating with the same db (rds).

* Observations ?

```
login : cat /home/bitnami/bitnami_credentials
user,  yZ1=X/imdNpV
When I connect to drupal instance B, I was automatically connected to drupal A.

Yes, both servers communicate with the same database. After changing the email address on B, I refresh on A and the new email was there.
```

### Change the profil picture

* Observations ?

```
The image is displayed on an instance. However, the second instance sees that there's an image but can't visualize it. This is because the image is stored on the drupal server and not on the database.

The path to the image : /bitnami/drupal/sites/default/files/styles/thumbnail/public/pictures/2024-03/
```
