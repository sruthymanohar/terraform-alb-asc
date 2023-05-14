// keypair creation

resource "aws_key_pair" "terraform" {
  key_name   = "${var.project}-key"
  public_key = file("~/.ssh/terraform1/terraform.pub")
   tags       = {
    Name = "${var.project}-key"
  }

}


//security group creation

resource "aws_security_group" "securitygroupinstance" {

  name        = "${ var.project }.securitygroup"
  description = "allows 22"
  vpc_id      = aws_vpc.main.id
  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {

    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${ var.project }-securitygroup"
  }
}



// ami creation

data "aws_ami" "ami" {
  most_recent = true
  owners =["amazon"]
  filter {
    name= "name"
    values= ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
}
filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

//ebs volume creation



// ec2 instance creation


resource "aws_instance" "webserver" {
  ami           = data.aws_ami.ami.id
  instance_type = "t2.large"
  key_name  = aws_key_pair.terraform.key_name
  vpc_security_group_ids = [aws_security_group.securitygroupinstance.id]

  subnet_id      =  aws_subnet.private_subnet1.id

  user_data = file("apache.sh")



  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 60
    volume_type = "gp2"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

 tags = {
   Name = "Server "
 }

}
