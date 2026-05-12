# Module 9 - AWS Services
Your company has decided that they will use AWS as a cloud provider to deploy their applications. It's too much overhead to manage multiple platforms, including the billing etc.

So you need to deploy the previous NodeJS application on an EC2 instance now. This means you need to create and prepare an EC2 server with the AWS Command Line Tool to run your NodeJS app container on it.

<details>
<summary><b>EXERCISE 1: Create IAM user</b></summary>

First of all, you need an IAM user with correct permissions to execute the tasks below.

Create a new IAM user using "your name" as a username and "devops" as the user-group
Give the "devops" group all needed permissions to execute the tasks below - with login and CLI credentials
Note: Do that using the AWS UI with Admin User

* Create a group - DevOps
```
PS C:\Repos\js-app> aws iam create-group --group-name DevOps
{
    "Group": {
        "Path": "/",
        "GroupName": "DevOps",
        "GroupId": "AGPAZQWUEKUK437DFHICR",
        "Arn": "arn:aws:iam::654353650965:group/DevOps",
        "CreateDate": "2026-05-01T13:35:09+00:00"
    }
}
```
* Create an user
```
PS C:\Repos\js-app> aws iam create-user --user-name iroiter
{
    "User": {
        "Path": "/",
        "UserName": "iroiter",
        "UserId": "AIDAZQWUEKUKSENSSDKAZ",
        "Arn": "arn:aws:iam::654353650965:user/iroiter",
        "CreateDate": "2026-05-01T13:42:10+00:00"
    }
}
```
* Add an user to a group
```
PS C:\Repos\js-app> aws iam add-user-to-group --user-name iroiter --group-name DevOps
PS C:\Repos\js-app> aws iam get-group --group-name DevOps
{
    "Users": [
        {
            "Path": "/",
            "UserName": "iroiter",
            "UserId": "AIDAZQWUEKUKSENSSDKAZ",
            "Arn": "arn:aws:iam::654353650965:user/iroiter",
            "CreateDate": "2026-05-01T13:42:10+00:00"
        }
    ],
    "Group": {
        "Path": "/",
        "GroupName": "DevOps",
        "GroupId": "AGPAZQWUEKUK437DFHICR",
        "Arn": "arn:aws:iam::654353650965:group/DevOps",
        "CreateDate": "2026-05-01T13:35:09+00:00"
    }
}
```
* Add permissions to DevOps group from AWS UI
```
IAM->IAM user groups->DevOps->Add permissions->search for a policy - 'AmazonVPCFullAccess'->attach it
```
* Add 
```
IAM->IAM user groups->DevOps->Add permissions->search for a policy - 'AmazonEC2FullAccess'->attach it
```
* Create initial password for an user and request to reset it on first time login
```
PS C:\Repos\js-app> aws iam create-login-profile --user-name iroiter --password MyPassword! --password-reset-required
{
    "LoginProfile": {
        "UserName": "iroiter",
        "CreateDate": "2026-05-01T14:18:52+00:00",
        "PasswordResetRequired": true
    }
}
```
* Add permissions to DevOps group to change the password from AWS UI
```
IAM->IAM user groups->DevOps->Add permissions->search for a policy - 'IAMUserChangePassword'->attach it
```
* Create an access key for an user - iroiter
```
PS C:\Repos\js-app> aws iam create-access-key --user-name iroiter
{
    "AccessKey": {
        "UserName": "iroiter",
        "AccessKeyId": "XXXX",
        "Status": "Active",
        "SecretAccessKey": "XXXX",
        "CreateDate": "2026-05-01T14:26:39+00:00"
    }
}
```
</details>
<details>
<summary><b>EXERCISE 2: Configure AWS CLI</b></summary>

You want to use the AWS CLI for the following tasks. So, to be able to interact with the AWS account from the AWS Command Line tool you need to configure it correctly:

Set credentials for that user for AWS CLI
Configure correct region for your AWS CLI

```
PS C:\Repos\js-app> aws configure
AWS Access Key ID [****************ECD4]: XXX
AWS Secret Access Key [****************FXBz]: XXX
Default region name [ca-central-1]: ca-central-1
Default output format [json]: json
```
</details>
<details>
<summary><b>EXERCISE 3: Create VPC</b></summary>

You want to create the EC2 Instance in a dedicated VPC, instead of using the default one. So, using the AWS CLI, you:

create a new VPC with 1 subnet
create a security group in the VPC that will allow you access on ssh port 22 and will allow browser access to your Node application

* Create a new VPC with 1 subnet
```
PS C:\Repos\js-app> aws ec2 create-vpc --region ca-central-1 --cidr-block 10.0.0.0/16
{
    "Vpc": {
        "OwnerId": "654353650965",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-087b055dd06d6a1cf",
                "CidrBlock": "10.0.0.0/16",
                "CidrBlockState": {
                    "State": "associated"
                }
            }
        ],
        "IsDefault": false,
        "VpcId": "vpc-057a53daa658c4fc1",
        "State": "pending",
        "CidrBlock": "10.0.0.0/16",
        "DhcpOptionsId": "dopt-0895c0b6537fdc668"
    }
}
```
* Create a subnet under 'vpc-057a53daa658c4fc1'
```
PS C:\Repos\js-app> aws ec2 create-subnet --vpc-id vpc-057a53daa658c4fc1 --cidr-block 10.0.1.0/24 --output json
{
    "Subnet": {
        "AvailabilityZoneId": "cac1-az1",
        "MapCustomerOwnedIpOnLaunch": false,
        "OwnerId": "654353650965",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "SubnetArn": "arn:aws:ec2:ca-central-1:654353650965:subnet/subnet-0252d44a7c185f0f6",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        },
        "SubnetId": "subnet-0252d44a7c185f0f6",
        "State": "available",
        "VpcId": "vpc-057a53daa658c4fc1",
        "CidrBlock": "10.0.1.0/24",
        "AvailableIpAddressCount": 251,
        "AvailabilityZone": "ca-central-1a",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false
    }
}
```
* Create gateway
```
PS C:\Users\user> aws ec2 create-internet-gateway
{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-079d8f744db4573ce",
        "OwnerId": "654353650965",
        "Tags": []
    }
}

PS C:\Users\user> aws ec2 attach-internet-gateway `
>> --vpc-id vpc-057a53daa658c4fc1 `
>> --internet-gateway igw-079d8f744db4573ce
```
* Create route to Internet
```
PS C:\Users\user> aws ec2 describe-route-tables --route-table-ids
{
    "RouteTables": [
        {
....
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0d4e41a87df5e7fc6",
...
            "VpcId": "vpc-057a53daa658c4fc1",
            "OwnerId": "654353650965"
        },
...


PS C:\Users\user> aws ec2 create-route `
>> --route-table-id rtb-0d4e41a87df5e7fc6 `
>> --destination-cidr-block 0.0.0.0/0 `
>> --gateway-id igw-079d8f744db4573ce
{
    "Return": true
}
```
* Enable auto-assign public IP
```
PS C:\Users\user> aws ec2 modify-subnet-attribute `
>> --subnet-id subnet-0252d44a7c185f0f6 `
>> --map-public-ip-on-launch
```
* Create a security group in the VPC that will allow you access on ssh port 22 and will allow browser access to your Node application
```
PS C:\Users\user> aws ec2 create-security-group --group-name irina-sg --description "My new SG" --vpc-id vpc-057a53daa658c4fc1
{
    "GroupId": "sg-040b86a18d2b3b2f9",
    "SecurityGroupArn": "arn:aws:ec2:ca-central-1:654353650965:security-group/sg-040b86a18d2b3b2f9"
}
```
* Create two rules for the security group allowing connection on port 22 and 3000   
```
PS C:\Users\user>  aws ec2 authorize-security-group-ingress `
>> --group-id sg-040b86a18d2b3b2f9 `
>> --protocol tcp `
>> --port 22 `
>> --cidr 108.162.140.99/32
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-025b328f8ce99f242",
            "GroupId": "sg-040b86a18d2b3b2f9",
            "GroupOwnerId": "654353650965",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "108.162.140.99/32",
            "SecurityGroupRuleArn": "arn:aws:ec2:ca-central-1:654353650965:security-group-rule/sgr-025b328f8ce99f242"
        }
    ]
}
```
```
PS C:\Users\user>  aws ec2 authorize-security-group-ingress `
>> --group-id sg-040b86a18d2b3b2f9 `
>> --protocol tcp `
>> --port 3000 `
>> --cidr 108.162.140.99/32
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-098dd672688590e30",
            "GroupId": "sg-040b86a18d2b3b2f9",
            "GroupOwnerId": "654353650965",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 3000,
            "ToPort": 3000,
            "CidrIpv4": "108.162.140.99/32",
            "SecurityGroupRuleArn": "arn:aws:ec2:ca-central-1:654353650965:security-group-rule/sgr-098dd672688590e30"
        }
    ]
}
``` 
* Validate that the rules has been created
```
PS C:\Users\user> aws ec2 describe-security-groups --group-ids sg-040b86a18d2b3b2f9
{
    "SecurityGroups": [
        {
            "GroupId": "sg-040b86a18d2b3b2f9",
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                }
            ],
            "VpcId": "vpc-057a53daa658c4fc1",
            "SecurityGroupArn": "arn:aws:ec2:ca-central-1:654353650965:security-group/sg-040b86a18d2b3b2f9",
            "OwnerId": "654353650965",
            "GroupName": "irina-sg",
            "Description": "My new SG",
            "IpPermissions": [
                {
                    "IpProtocol": "tcp",
                    "FromPort": 22,
                    "ToPort": 22,
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "CidrIp": "108.162.140.99/32"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                },
                {
                    "IpProtocol": "tcp",
                    "FromPort": 3000,
                    "ToPort": 3000,
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "CidrIp": "108.162.140.99/32"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                }
            ]
        }
    ]
}
``` 
</details>

<details>
<summary><b>EXERCISE 4: Create EC2 Instance</b></summary>

Once the VPC is created, using the AWS CLI, you:
Create an EC2 instance in that VPC with the security group you just created and ssh key file

* Create a key pair for ec2 instance
```
PS C:\Users\user> aws ec2 create-key-pair `
>> --key-name node-js-server `
>> --query 'KeyMaterial' `
>> --output text > C:\Users\user\.ssh\node-js-server.pem
```
* Create an ec2 instance
```
PS C:\Users\user> aws ec2 run-instances `
>> --image-id ami-0495a76ecf381a767 `
>> --count 1 `
>> --instance-type t2.micro `
>> --key-name node-js-server `
>> --security-group-ids sg-040b86a18d2b3b2f9 `
>> --subnet-id subnet-0252d44a7c185f0f6
{
    "ReservationId": "r-0b487e67d134f5960",
    "OwnerId": "654353650965",
    "Groups": [],
    "Instances": [
        {
...
            "NetworkInterfaces": [
                {
...
                    "Description": "",
                    "Groups": [
                        {
                            "GroupId": "sg-040b86a18d2b3b2f9",
                            "GroupName": "irina-sg"
                        }
                    ],
...
            "SecurityGroups": [
                {
                    "GroupId": "sg-040b86a18d2b3b2f9",
                    "GroupName": "irina-sg"
                }
            ],
...
            "InstanceId": "i-04cf93eccd8d9557b",
            "ImageId": "ami-0495a76ecf381a767",
...
            "SubnetId": "subnet-0252d44a7c185f0f6",
            "VpcId": "vpc-057a53daa658c4fc1",
            "PrivateIpAddress": "10.0.1.192"
        }
    ]
}

PS C:\Users\user>

```
</details>
<details>
<summary><b>EXERCISE 5: SSH into the server and install Docker on it</b></summary>

Once the EC2 instance is created successfully, you want to prepare the server to run Docker containers. So you:
ssh into the server and
install Docker on it to run the dockerized application later

* Connect to ec2 instance
```
PS C:\Users\user> ssh -i C:\Users\user\.ssh\node-js-server.pem ec2-user@3.99.161.105
The authenticity of host '3.99.161.105 (3.99.161.105)' can't be established.
ED25519 key fingerprint is SHA256:sO2ioxZ/rvwkuDr981Lq8Ht0SXwiPniZWlCnopKdwoc.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '3.99.161.105' (ED25519) to the list of known hosts.
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[ec2-user@ip-10-0-1-82 ~]$
```
* Install Docker
```
[ec2-user@ip-10-0-1-82 ~]$ sudo yum update
Amazon Linux 2023 Kernel Livepatch repository                                           215 kB/s |  31 kB     00:00
...
Dependencies resolved.
Nothing to do.
Complete!
```
```
[ec2-user@ip-10-0-1-82 ~]$ sudo yum install docker
Last metadata expiration check: 0:00:52 ago on Mon May  4 19:10:15 2026.
Dependencies resolved.
...
Complete!
```
* Start Docker Engine
```
[ec2-user@ip-10-0-1-82 ~]$ sudo service docker start
Redirecting to /bin/systemctl start docker.service
```
* Add ec2-user to docker group
```
[ec2-user@ip-10-0-1-82 ~]$ sudo usermod -aG docker $USER
[ec2-user@ip-10-0-1-82 ~]$ groups
ec2-user adm wheel systemd-journal

[ec2-user@ip-10-0-1-82 ~]$ exit
logout
Connection to 3.99.161.105 closed.

PS C:\repos\aws-exercises> ssh -i C:\Users\user\.ssh\node-js-server.pem ec2-user@3.99.161.105
Last login: Tue May  5 20:39:42 2026 from 108.162.140.99
[ec2-user@ip-10-0-1-82 ~]$ groups
ec2-user adm wheel systemd-journal docker
```

* Install Docker Compose on AWS EC2 instance
```
[ec2-user@ip-10-0-1-82 ~]$ sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0   0     0   0     0     0     0  --:--:-- --:--:-- --:--:--     0
  0     0   0     0   0     0     0     0  --:--:-- --:--:-- --:--:--     0
100 31621k 100 31621k   0     0 62511k     0  --:--:-- --:--:-- --:--:-- 125.5M

[ec2-user@ip-10-0-1-82 ~]$ sudo chmod +x /usr/local/bin/docker-compose

[ec2-user@ip-10-0-1-82 ~]$ docker-compose --version
Docker Compose version v5.1.3
```
</details>
<details>
<summary><b>EXERCISE 6: Add docker-compose for deployment</b></summary>

Repo:
https://gitlab.com/IrinaRoiter/aws-exercises


* Add docker-compose to your NodeJS application

docker-compose:
https://gitlab.com/IrinaRoiter/aws-exercises/-/blob/be8a3660f2bfaccf9e3d1b6d1bbc8a78b0ca8d92/docker-compose.yaml

</details>
<details>
<summary><b>EXERCISE 7: Add "deploy to EC2" step to your existing pipeline</b></summary>

* Add credentials to AWS scoped to a pipeline only
```
Kind: ssh username with private key
ID: ec2-instance-key
Username: ec2-user
Private Key: enter directly
Extract the content of "C:\Users\user\.ssh\node-js-server.pem" file, copy and paste it in the provided area. Make sure to copy/paste everything including:
-----BEGIN OPENSSH PRIVATE KEY-----
-----END OPENSSH PRIVATE KEY-----
```
* Create a multibranch pipeline for my repo in Jenkins

```
Name: deploy-node-js-aws

Git repo: https://gitlab.com/IrinaRoiter/aws-exercises.git
Credentials: pat-gitlab

Behaviours->Add->choose 'Filer by name with reqular expressions'
Accept default regular expression '.*' - matches all the branches
```

* Add a deployment step to the Jenkinsfile

Jenkinsfile:
https://gitlab.com/IrinaRoiter/aws-exercises/-/blob/be8a3660f2bfaccf9e3d1b6d1bbc8a78b0ca8d92/Jenkinsfile

Docker-compose-script.sh
https://gitlab.com/IrinaRoiter/aws-exercises/-/blob/be8a3660f2bfaccf9e3d1b6d1bbc8a78b0ca8d92/docker-compose-script.sh


* Allow Jenkins communicate with ec2 instance on port 22
```
EC2
Security Groups
sg-040b86a18d2b3b2f9 - security-group-irina-vms
Add rule
Type: ssh
Protocol: TCP
Port: 22
Source: 159.203.26.80/32 (Jenkins public IPv4)
```

* Run a build

![Jenkins build](images/node-js-docker-compose-aws-deployed.png)
```
ℹ️ From Console output:
Started by user Admin
...
Checking out Revision 9841a1444f2579a826a2c7a02ae673b2c4d91d72 (master)
...
Building the docker image...
[Pipeline] sh
+ docker build -t irinaroiter/demo-app:node-2.0.5-14 .
...
+ docker login -u irinaroiter --password-stdin
Login Succeeded
...
node-2.0.5-14: digest: sha256:d924b53e1df947d81091e672836ccf5221c627b6beeca47fb0705a424eb8392e size: 856
...
[Pipeline] withCredentials
...
Deploying Docker image to EC2 instance with docker-compose...
...

Login Succeeded
...
 Image irinaroiter/demo-app:node-2.0.5-14 Pulling 
...
 Image irinaroiter/demo-app:node-2.0.5-14 Pulled 
 Network ec2-user_default Creating 
 Network ec2-user_default Created 
 Container ec2-user-node-app-1 Creating 
 Container ec2-user-node-app-1 Created 
 Container ec2-user-node-app-1 Starting 
 Container ec2-user-node-app-1 Started 
Success
....
[Pipeline] End of Pipeline
Finished: SUCCESS
```
* Validate container is running on ec2 instance
```
PS C:\Users\user> ssh -i "C:\Users\user\.ssh\node-js-server.pem" ec2-user@3.99.161.105

Last login: Tue May  5 20:44:14 2026 from 108.162.140.99

[ec2-user@ip-10-0-1-82 ~]$ docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
f260f419df9e   irinaroiter/demo-app:node-2.0.5-14   "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp   ec2-user-node-app-1
[ec2-user@ip-10-0-1-82 ~]$
```
</details>

<details>
<summary><b>EXERCISE 8: Configure access from browser (EC2 Security Group)</b></summary>

After executing the Jenkins pipeline successfully, the application is deployed, but you still can't access it from the browser. You need to open the correct port on the server. For that, using the AWS CLI, you:

Configure the EC2 security group to access your application from a browser

✅ The port 3000 was opened as part of exercise 3, step "Create two rules for the security group allowing connection on port 22 and 3000"

</details>
<details>
<summary><b>EXERCISE 9: Configure automatic triggering of multi-branch pipeline</b></summary>

Your team members are creating branches to add new features to the application or fix any issues, so you don't want to build and deploy these half-done features or bug fixes. You want to build and deploy only to the master branch. All other branches should only run tests. Add this logic to the Jenkinsfile.

* Add branch based logic to Jenkinsfile
Jenkinsfile on master branch:</br>
https://gitlab.com/IrinaRoiter/aws-exercises/-/blob/bd7be312b20a168e00a84a8ed18f971f13a36316/Jenkinsfile

* Create a branch 

```
PS C:\repos\aws-exercises> git checkout -b feature/feature-1
Switched to a new branch 'feature/feature-1'
```
👉🏻 master and feature/feature-1 are identical

* Run builds on both branches

👉🏻 Master branch - all stages run
![master branch build](images/master-branch-build.png)

👉🏻 feature/feature-1 branch - Docker build and push, Deploy and commit to Git stages were skipped
![master branch build](images/feature-branch-build.png)

* Install 'Multibranch scan webhook trigger' plugin
```
Manage Jenkins->Plugins->Avaialble Plugins->Search for Install Multibranch scan webhook trigger
Install
```
* Configure trigger in'deploy-node-js-aws' job
```
'deploy-node-js-aws' job->Configure
Scan Multibranch Pipeline Triggers-> select 'Scan by webhook'->Trigger token 'gitlab-token'
Save
```
* Configure Webhook connection in GitLab
```
Connect to https://gitlab.com/IrinaRoiter/aws-exercises
Settings->Webhooks->Add webhook
Name: jenkins-webhook

URL: http://159.203.26.80:8080/multibranch-webhook-trigger/invoke?token=gitlab-token

Trigger: select "Push events"
Add Webhook and test it.
```
![Webhook test](images/webhook-test.png)
* Install 'Ignore committer strategy' plugin
```
Manage Jenkins->Available plugins->Search for 'Ignore committer strategy' plugin->Install
```
* Configure 'deploy-node-js-aws' job
```
'deploy-node-js-aws'->Configure->Branch sources->Build strategies->Add 'Ignore commiter strategy'
e-mail: jenkins@example.com
Select 'Allow builds when a changeset contains non-ignored author(s)'
Save
```
* Make a change in GitLab
```
Added a line under 'init' stage
echo "Testing Jenkins and GitLab integration"

```
* Verify that 'deploy-node-js-aws' job was triggerred
![Build is triggered automatically](images/webhook-build-test.png)


</details>