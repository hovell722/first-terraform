# Terraform

Terraform is an Orchestration Tool, that is part of infrastructure as code.

Where Chef and Packer sit more on the Configuration management side and create immutable AMIs.

Terraform sits on the orchestrates side. This includes the creation of networks and complex systems and deploys AMIs.

An AMI is a blueprint (snap shot) of an instance:
- The operating system
- data and storage
- all the packages and exact state of a machine when AMI was created


## Setting up Terraform to run commands in EC2

To run commands inside the EC2 I used:
```
provisioner "remote-exec" {
  inline = [
    "cd /home/ubuntu/app",
    "npm start"
  ]
}
```
This is telling it to run the commands inside `inline` within a remote machine. I.E. the EC2 terraform will create.

It will not be able to access this EC2 unless it is given a connection, as set up like:
```
connection {
  type     = "ssh"
  user     = "ubuntu"
  host = self.public_ip
  private_key = "${file("~/.ssh/james-eng54.pem")}"
}
```
This will give it access to the machine.

`host = self.public_ip` will state the public ip of the EC2. and the `private_key` will use my private_key used to access the EC2.

## Running Terraform

To run terraform, first run:
```
$ terraform plan
```
This will allow you to see what changes will be made to your setup, and allow you to see any errors.

If you are happy with your plan run:
```
$ terraform apply
```
This will set up your EC2 instance, accessible on AWS.

From how this terraform is set up, the EC2 will not finish creating as the app will be running on it.

You can go to the http://<public_ip> of the EC2 to see the app running.
