## Table of Contents

- [Prerequisites](#Prerequisites)
- [Introduction](#Introduction)
- [Purpose](#Purpose)
- [Steps](#Steps)
- [Clean up](#Clean up)
- [Explanation](#Explanation)
  
## Prerequisites

- Terraform: [Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Ansible: [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Introduction
This repository contains automation scripts and workflow to create and manage EC2 instance using Terraform, Ansible, Git Actions and AWS.

## Purpose
The purpose of this project is to automate the provisioning of an AWS EC2 instance with Nginx using Terraform, configure it using Ansible, and facilitate CI/CD through GitHub Actions. It faciliates the EC2 instance setup and gives opportunity to easily upload index.html file without need to connect to EC2 server through CMD.

## Steps
1. Fork and clone this repository
```sh
git clone https://github.com/skilet16/Bootcamp_Main_Task.git
cd Bootcamp_Main_Task
```

2. Create AWS account if you don't have one and get AWS ACCESS KEY and AWS SECRET KEY

3. *Optional*. You can change **key_pair_name**, **common_tags**, **instance_type** in **/terraform/variables.tf** according to your preference

4. Go to **/terraform** and execute following command:
```sh
terraform init 
```

4. Go to **/terraform** directory and execute following command:
```sh
terraform apply
```
Terraform will ask following information to fill:
* AWS Access KEY
* AWS Secret KEY
* Region (Example - eu-region-1)
* VPC ID (Example - vpc-8429342023)

The terraform will create EC2 instance and generate two files - **hosts** and **webserver-bootcamp-eriks-key.pem** in **/ansible** directory

5. Go to **/ansible** directory and execute following:
```sh
ansible-playbook nginx-install.yml
```

This will execute the playbook, install nginx in EC2 instance and change /var/www/html/ permission for future CI/CD workflow

6. Inside of **/ansible** execute following command:
```sh
cat webserver-bootcamp-eriks-key.pem
```
And copy the private key of the file.

7. Go to your fork and add following secret variables:

| Secret variables | Description    | 
| :---:   | :---: | 
| REMOTE_HOST | The remote ip address, example - 3.12.142.1   | 
REMOTE_USER | The remote user of the ec2, example - ubuntu
REMOTE_TARGET_DIR | The directory of nginx, example - /var/www/html/
SSH_PRIVATE_KEY | The ssh private key from .pem file

8. Upload a new modified index.html file
The github actions workflow will identify new index.html file and upload to nginx, into specified directory. By default the directory is /var/www/html/.

9. Access to your EC2 instance through public ip
Now you can see the new modified index.html in the EC2.

## Explanation
This section explains how everything works in code
### Ansible
The ansible is responsible for installing NGINX in newly created EC2 instance.
All files that is related to the ansible is located in **/ansible** directory: 

* **nginx-install.yml** - this is a playbook that contains four tasks: apt update, apt install nginx, service nginx start and finally change the file permission for directory /var/www/html

* **ansible.cfg** - this is a config that defines the default inventory file which is **hosts**

* **hosts** - this file is generated by terraform. This contains a public ip address, user and private key 

### Terraform
Terraform is responsible for creating security group, ssh key, EC2 instance and generating files such as **hosts** and **.pem** private key file
All the terraform files located in **/terraform** directory:

* **main.tf** - this file contains the main logic of defining required version, creating security group, generating ssh key, creating new Instance using ubuntu and generating hosts and .pem file in ansible directory
* **variables.tf** - this file contains all the variables that you can modify for your own needs
* **provider.tf** - this file contains AWS provider
* **output.tf** - this file has one output: public_ip. It is useful when EC2 is created, you can get the public address.

### Git Actions
Git Actions responsible for uploading newly modified index.html to the EC2 instance. It acts on any push event and uploads index.html if it is modified. All the logic is contained in folder .git/workflows/deploy_index_to_ec2.yml

Inside of this code, we have secrets variables that should be defined in github repository in order to connect to EC2 instance and make some changes

## Clean up
In order to clean everything up, go to **/terraform** and execute following command:
```
terraform destroy
```
Then it will prompt a message, and you should enter **yes**
