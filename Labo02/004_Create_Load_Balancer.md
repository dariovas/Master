### Deploy the elastic load balancer

In this task you will create a load balancer in AWS that will receive
the HTTP requests from clients and forward them to the Drupal
instances.

![Schema](./img/CLD_AWS_INFA.PNG)

## Task 01 Prerequisites for the ELB

* Create a dedicated security group

|Key|Value|
|:--|:--|
|Name|SG-DEVOPSTEAM[XX]-LB|
|Inbound Rules|Application Load Balancer|
|Outbound Rules|Refer to the infra schema|

```bash
[INPUT]
aws ec2 create-security-group --group-name SG-DEVOPSTEAM16-LB --description "SG-DEVOPSTEAM16-LB" --vpc-id vpc-03d46c285a2af77ba --tag-specifications ResourceType=security-group,Tags=[{Key=Name,Value=SG-DEVOPSTEAM16-LB}]

aws ec2 authorize-security-group-ingress --group-id sg-0858109c60ec99c7b --ip-permissions IpProtocol=tcp,FromPort=8080,ToPort=8080,IpRanges="[{CidrIp=10.0.0.0/28,Description='HTTP'}]"

[OUTPUT]
{
    "GroupId": "sg-0858109c60ec99c7b",
    "Tags": [
        {
            "Key": "Name",
            "Value": "SG-DEVOPSTEAM16-LB"
        }
    ]
}


{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-01f17269b31f4705e",
            "GroupId": "sg-0858109c60ec99c7b",
            "GroupOwnerId": "709024702237",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 8080,
            "ToPort": 8080,
            "CidrIpv4": "10.0.0.0/28",
            "Description": "HTTP"
        }
    ]
}
```

* Create the Target Group

|Key|Value|
|:--|:--|
|Target type|Instances|
|Name|TG-DEVOPSTEAM[XX]|
|Protocol and port|Refer to the infra schema|
|Ip Address type|IPv4|
|VPC|Refer to the infra schema|
|Protocol version|HTTP1|
|Health check protocol|HTTP|
|Health check path|/|
|Port|Traffic port|
|Healthy threshold|2 consecutive health check successes|
|Unhealthy threshold|2 consecutive health check failures|
|Timeout|5 seconds|
|Interval|10 seconds|
|Success codes|200|

```bash
[INPUT]
aws elbv2 create-target-group --name TG-DEVOPSTEAM16 --protocol HTTP --protocol-version HTTP1 --port 8080 --ip-address-type ipv4 --vpc-id vpc-03d46c285a2af77ba --healthy-threshold-count 2 --unhealthy-threshold-count 2 --health-check-timeout-seconds 5 --health-check-interval-seconds 10 --matcher HttpCode=200

aws elbv2 register-targets --target-group-arn arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM16/d34751cfd970b57a --targets Id=i-0331f782b4b45f420 Id=i-07303374c9b239b00

[OUTPUT]
{
    "TargetGroups": [
        {
            "TargetGroupArn": "arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM16/d34751cfd970b57a",
            "TargetGroupName": "TG-DEVOPSTEAM16",
            "Protocol": "HTTP",
            "Port": 8080,
            "VpcId": "vpc-03d46c285a2af77ba",
            "HealthCheckProtocol": "HTTP",
            "HealthCheckPort": "traffic-port",
            "HealthCheckEnabled": true,
            "HealthCheckIntervalSeconds": 10,
            "HealthCheckTimeoutSeconds": 5,
            "HealthyThresholdCount": 2,
            "UnhealthyThresholdCount": 2,
            "HealthCheckPath": "/",
            "Matcher": {
                "HttpCode": "200"
            },
            "TargetType": "instance",
            "ProtocolVersion": "HTTP1",
            "IpAddressType": "ipv4"
        }
    ]
}
```


## Task 02 Deploy the Load Balancer

[Source](https://aws.amazon.com/elasticloadbalancing/)

* Create the Load Balancer

|Key|Value|
|:--|:--|
|Type|Application Load Balancer|
|Name|ELB-DEVOPSTEAM99|
|Scheme|Internal|
|Ip Address type|IPv4|
|VPC|Refer to the infra schema|
|Security group|Refer to the infra schema|
|Listeners Protocol and port|Refer to the infra schema|
|Target group|Your own target group created in task 01|

Provide the following answers (leave any
field not mentioned at its default value):

```bash
[INPUT]
aws elbv2 create-load-balancer --name ELB-DEVOPSTEAM16 --scheme internal --security-groups sg-0858109c60ec99c7b --subnets subnet-0403d99111665b019 subnet-05fd5dab104c7d287

aws elbv2 create-listener --load-balancer-arn arn:aws:elasticloadbalancing:eu-west-3:709024702237:loadbalancer/app/ELB-DEVOPSTEAM16/360e49246594e9e3 --protocol HTTP --port 8080 --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM16/d34751cfd970b57a
 
[OUTPUT]
{
    "LoadBalancers": [
        {
            "LoadBalancerArn": "arn:aws:elasticloadbalancing:eu-west-3:709024702237:loadbalancer/app/ELB-DEVOPSTEAM16/360e49246594e9e3",
            "DNSName": "internal-ELB-DEVOPSTEAM16-512155870.eu-west-3.elb.amazonaws.com",
            "CanonicalHostedZoneId": "Z3Q77PNBQS71R4",
            "CreatedTime": "2024-03-23T14:28:18.670000+00:00",
            "LoadBalancerName": "ELB-DEVOPSTEAM16",
            "Scheme": "internal",
            "VpcId": "vpc-03d46c285a2af77ba",
            "State": {
                "Code": "provisioning"
            },
            "Type": "application",
            "AvailabilityZones": [
                {
                    "ZoneName": "eu-west-3b",
                    "SubnetId": "subnet-0403d99111665b019",
                    "LoadBalancerAddresses": []
                },
                {
                    "ZoneName": "eu-west-3a",
                    "SubnetId": "subnet-05fd5dab104c7d287",
                    "LoadBalancerAddresses": []
                }
            ],
            "SecurityGroups": [
                "sg-0858109c60ec99c7b"
            ],
            "IpAddressType": "ipv4"
        }
    ]
}

{
    "Listeners": [
        {
            "ListenerArn": "arn:aws:elasticloadbalancing:eu-west-3:709024702237:listener/app/ELB-DEVOPSTEAM16/360e49246594e9e3/ad92d3b71deaf6a3",
            "LoadBalancerArn": "arn:aws:elasticloadbalancing:eu-west-3:709024702237:loadbalancer/app/ELB-DEVOPSTEAM16/360e49246594e9e3",
            "Port": 8080,
            "Protocol": "HTTP",
            "DefaultActions": [
                {
                    "Type": "forward",
                    "TargetGroupArn": "arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM16/d34751cfd970b57a",
                    "ForwardConfig": {
                        "TargetGroups": [
                            {
                                "TargetGroupArn": "arn:aws:elasticloadbalancing:eu-west-3:709024702237:targetgroup/TG-DEVOPSTEAM16/d34751cfd970b57a",
                                "Weight": 1
                            }
                        ],
                        "TargetGroupStickinessConfig": {
                            "Enabled": false
                        }
                    }
                }
            ]
        }
    ]
}


```

* Create the rules on the security group SG-PRIVATE-DRUPAL-DEVOPSTEAM16 to allow the traffic from the loadbalancer to the subnet A and the subnet B.

For the subnet A :
```bash
[INPUT]
aws ec2 authorize-security-group-ingress --group-id sg-05cddfeca33d9830b --ip-permissions IpProtocol=tcp,FromPort=8080,ToPort=8080,IpRanges="[{CidrIp=10.0.16.0/28,Description='AZ1'}]"

[OUTPUT]
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-04cb2fdcb13a8b4e0",
            "GroupId": "sg-05cddfeca33d9830b",
            "GroupOwnerId": "709024702237",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 8080,
            "ToPort": 8080,
            "CidrIpv4": "10.0.16.0/28",
            "Description": "AZ1"
        }
    ]
}
```

For the subnet B :
```bash
[INPUT]
aws ec2 authorize-security-group-ingress --group-id sg-05cddfeca33d9830b --ip-permissions IpProtocol=tcp,FromPort=8080,ToPort=8080,IpRanges="[{CidrIp=10.0.16.128/28,Description='AZ2'}]"

[OUTPUT]
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0b04674be62de3263",
            "GroupId": "sg-05cddfeca33d9830b",
            "GroupOwnerId": "709024702237",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 8080,
            "ToPort": 8080,
            "CidrIpv4": "10.0.16.128/28",
            "Description": "AZ2"
        }
    ]
}
```

* Get the ELB FQDN (DNS NAME - A Record)

```bash
[INPUT]

aws elbv2 describe-load-balancers --name ELB-DEVOPSTEAM16

[OUTPUT]
{
    "LoadBalancers": [
        {
            "LoadBalancerArn": "arn:aws:elasticloadbalancing:eu-west-3:709024702237:loadbalancer/app/ELB-DEVOPSTEAM16/360e49246594e9e3",
            "DNSName": "internal-ELB-DEVOPSTEAM16-512155870.eu-west-3.elb.amazonaws.com",
            "CanonicalHostedZoneId": "Z3Q77PNBQS71R4",
            "CreatedTime": "2024-03-23T14:28:18.670000+00:00",
            "LoadBalancerName": "ELB-DEVOPSTEAM16",
            "Scheme": "internal",
            "VpcId": "vpc-03d46c285a2af77ba",
            "State": {
                "Code": "active"
            },
            "Type": "application",
            "AvailabilityZones": [
                {
                    "ZoneName": "eu-west-3b",
                    "SubnetId": "subnet-0403d99111665b019",
                    "LoadBalancerAddresses": []
                },
                {
                    "ZoneName": "eu-west-3a",
                    "SubnetId": "subnet-05fd5dab104c7d287",
                    "LoadBalancerAddresses": []
                }
            ],
            "SecurityGroups": [
                "sg-0858109c60ec99c7b"
            ],
            "IpAddressType": "ipv4"
        }
    ]
}
```

* Get the ELB deployment status

Note : In the EC2 console select the Target Group. In the
       lower half of the panel, click on the **Targets** tab. Watch the
       status of the instance go from **unused** to **initial**.

* Ask the DMZ administrator to register your ELB with the reverse proxy via the private teams channel

* Update your string connection to test your ELB and test it

```bash
ssh devopsteam16@15.188.43.46 -i CLD_KEY_DMZ_DEVOPSTEAM16.pem -L 2224:internal-ELB-DEVOPSTEAM16-512155870.eu-west-3.elb.amazonaws.com:8080
```

* Test your application through your ssh tunneling

```bash
[INPUT]
curl localhost:2224

[OUTPUT]
<!DOCTYPE html>
<html lang="en" dir="ltr" style="--color--primary-hue:202;--color--primary-saturation:79%;--color--primary-lightness:50">
  <head>
    <meta charset="utf-8" />
<meta name="Generator" content="Drupal 10 (https://www.drupal.org)" />
<meta name="MobileOptimized" content="width" />
<meta name="HandheldFriendly" content="true" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link rel="icon" href="/core/themes/olivero/favicon.ico" type="image/vnd.microsoft.icon" />
<link rel="alternate" type="application/rss+xml" title="" href="http://localhost:8080/rss.xml" />
<link rel="alternate" type="application/rss+xml" title="" href="http://localhost/rss.xml" />

    <title>Welcome! | My blog</title>
    <link rel="stylesheet" media="all" href="/sites/default/files/css/css_-cKnLC8MhiHDJYmodx4zsmXQumPUqyNB5C2ItT3k1yA.css?delta=0&amp;language=en&amp;theme=olivero&amp;include=eJxdjMEKAyEMBX9ord8U9dUNzZqSuIp_X-jBQi9zmIHx5R1XTOQ4VHjANFbRRBK8L-FWt37rhKGEtEISza8dnkA5BmN6_PJxabnl92s0uFJnbcGRtRWytaODLJ9hcsG_a2Sm8wMVPz8c" />
<link rel="stylesheet" media="all" href="/sites/default/files/css/css_-xZkCDHGo6yyFo1nDdel_HofPlSTMWoY_9ApjkD4ucw.css?delta=1&amp;language=en&amp;theme=olivero&amp;include=eJxdjMEKAyEMBX9ord8U9dUNzZqSuIp_X-jBQi9zmIHx5R1XTOQ4VHjANFbRRBK8L-FWt37rhKGEtEISza8dnkA5BmN6_PJxabnl92s0uFJnbcGRtRWytaODLJ9hcsG_a2Sm8wMVPz8c" />
...
```

#### Questions - Analysis

* On your local machine resolve the DNS name of the load balancer into
  an IP address using the `nslookup` command (works on Linux, macOS and Windows). Write
  the DNS name and the resolved IP Address(es) into the report.

```
nslookup internal-ELB-DEVOPSTEAM16-512155870.eu-west-3.elb.amazonaws.com

Non-authoritative answer:
Name:	internal-ELB-DEVOPSTEAM16-512155870.eu-west-3.elb.amazonaws.com
Address: 10.0.16.6
Name:	internal-ELB-DEVOPSTEAM16-512155870.eu-west-3.elb.amazonaws.com
Address: 10.0.16.134
```

* From your Drupal instance, identify the ip from which requests are sent by the Load Balancer.

Help : execute `tcpdump port 8080`

```
$ tcpdump port 8080

listening on ens5, link-type EN10MB (Ethernet), snapshot length 262144 bytes
15:54:20.712334 IP 10.0.16.6.15468 > provisioner-local.http-alt: Flags [S], seq 3917016855, win 26883, options [mss 8961,sackOK,TS val 1678033633 ecr 0,nop,wscale 8], length 0
15:54:20.712360 IP provisioner-local.http-alt > 10.0.16.6.15468: Flags [S.], seq 1600872091, ack 3917016856, win 62643, options [mss 8961,sackOK,TS val 1313014233 ecr 1678033633,nop,wscale 7], length 0
15:54:20.712466 IP 10.0.16.6.15468 > provisioner-local.http-alt: Flags [.], ack 1, win 106, options [nop,nop,TS val 1678033633 ecr 1313014233], length 0
15:54:20.712467 IP 10.0.16.6.15468 > provisioner-local.http-alt: Flags [P.], seq 1:131, ack 1, win 106, options [nop,nop,TS val 1678033633 ecr 1313014233], length 130: HTTP: GET / HTTP/1.1
15:54:20.712485 IP provisioner-local.http-alt > 10.0.16.6.15468: Flags [.], ack 131, win 489, options [nop,nop,TS val 1313014233 ecr 1678033633], length 0
15:54:20.722327 IP provisioner-local.http-alt > 10.0.16.6.15468: Flags [P.], seq 1:5623, ack 131, win 489, options [nop,nop,TS val 1313014243 ecr 1678033633], length 5622: HTTP: HTTP/1.1 200 OK
```

* In the Apache access log identify the health check accesses from the
  load balancer and copy some samples into the report.

```
$ tail -n 10 /opt/bitnami/apache2/logs/access_log

10.0.16.6 - - [25/Mar/2024:15:55:00 +0000] "GET / HTTP/1.1" 200 5147
10.0.16.134 - - [25/Mar/2024:15:55:02 +0000] "GET / HTTP/1.1" 200 5147
10.0.16.6 - - [25/Mar/2024:15:55:10 +0000] "GET / HTTP/1.1" 200 5147
10.0.16.134 - - [25/Mar/2024:15:55:12 +0000] "GET / HTTP/1.1" 200 5147
10.0.16.140 - - [25/Mar/2024:15:55:15 +0000] "GET / HTTP/1.1" 200 16555
10.0.16.6 - - [25/Mar/2024:15:55:20 +0000] "GET / HTTP/1.1" 200 5147
10.0.16.134 - - [25/Mar/2024:15:55:22 +0000] "GET / HTTP/1.1" 200 5147
10.0.16.6 - - [25/Mar/2024:15:55:30 +0000] "GET / HTTP/1.1" 200 5147
10.0.16.6 - - [25/Mar/2024:15:55:31 +0000] "GET /sites/default/files/css/css_vq2tTNTAs6ymJ7ITbW3gnB-8--oPdsn13Nct6eTHugo.css?delta=0&language=en&theme=olivero&include=eJx9T1tuxCAMvBCEM-xJKgPTXasEIxuS5vZNVyWV9mN_7PHM-JWkdnz3QSVkHY3Kki7GF65f5uywjjVEMrgkimmk1HnD0-SknFAlNNmhyD4ePhZJ_8InkN3G2C0847JKHgWXXmnjO3WW6g3nCZn0uEQDaXr4nTNeuUqqsrsuUiJp-MtuGHTe-YsXPmeaS---nb32EO1p9GmZ9euSBZao4ZZXri7y_aNxQ5jgB-wdhps HTTP/1.1" 304 -
10.0.16.134 - - [25/Mar/2024:15:55:32 +0000] "GET / HTTP/1.1" 200 5147
```
