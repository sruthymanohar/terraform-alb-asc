//


resource "aws_security_group" "securitygroupasc" {

  name        = "${ var.project }.ascsecuritygroup"
  vpc_id      = aws_vpc.main.id
 

  ingress {

    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

   ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

   ingress {

    from_port        = 443
    to_port          = 443
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
    Name = "${ var.project }-ascsecuritygroup"
  }
}

// create ami of the instance
resource "aws_ami_from_instance" "ami" {
  name               = "terraform-ami"
  source_instance_id = aws_instance.webserver.id
}


// launch template creation 

resource "aws_launch_template" "LC1" {
  name_prefix   = "LC1"
  image_id      = aws_ami_from_instance.ami.id
  instance_type = "t2.micro"
  key_name = "test"
  vpc_security_group_ids = [aws_security_group.securitygroupasc.id ]


  user_data = filebase64("apache.sh")
 

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "ASC" {

  force_delete              = true
  health_check_type         = "ELB"
  vpc_zone_identifier = [ aws_subnet.public_subnet1.id , aws_subnet.public_subnet2.id]
 
 
  timeouts {
    delete = "15m"
  }
  desired_capacity   = 2
  max_size           = 5
  min_size           = 1

  launch_template {
    id      = aws_launch_template.LC1.id
  }
}


// autoscaling group load balancer attachment

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.ASC.id
  lb_target_group_arn    = aws_lb_target_group.tg1.arn
}