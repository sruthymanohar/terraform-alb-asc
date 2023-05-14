// Creation of vpc

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = {
    Name = var.project
  }

  lifecycle {
    create_before_destroy = true
  }

}

// listing of az


data "aws_availability_zones" "az" {
  state = "available"
}



//  Creation of public subnet 1

resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block , var.subnetbit , 0)
  availability_zone = data.aws_availability_zones.az.names[0]
 
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-publicsubnet1"
  }
}


//  Creation of public subnet 2

resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block , var.subnetbit , 1)
  availability_zone = data.aws_availability_zones.az.names[1]
 
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-publicsubnet2"
  }
}



//  Creation of private subnet 1

resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block , var.subnetbit , 2)
  availability_zone = data.aws_availability_zones.az.names[0]
 


  tags = {
    Name = "${var.project}-privatesubnet1"
  }
}

// creation of private subnet2


resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block , var.subnetbit , 3)
  availability_zone = data.aws_availability_zones.az.names[1]
 


  tags = {
    Name = "${var.project}-privatesubnet2"
  }
}






// creation of internet gateway


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name ="${var.project}-igw"
  }
}

// creation of eip

resource "aws_eip" "eip" {
  vpc              = true

   tags = {
    Name ="${var.project}-eip"
  }
 
}

// creation of nat gateway


resource "aws_nat_gateway" "nat" {
  
  allocation_id = aws_eip.eip.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public_subnet1.id
  depends_on = [aws_internet_gateway.gw]

   tags = {
    Name = "${var.project}-nat"
  }
}


//creation of public route


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project}-publicroute"
  }
}


// creation of  private route



resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project}-privateroute"
  }
}

// creation  of public route table 1assosciation 

resource "aws_route_table_association" "public1" {

 
  subnet_id      =  aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public.id
}



// creation  of public route table 2 assosciation 

resource "aws_route_table_association" "public2" {

 
  subnet_id      =  aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public.id
}
//creation of private route table assosication 1



resource "aws_route_table_association" "private" {

  subnet_id      =  aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private.id
}

//creation of private route table assosication 1



resource "aws_route_table_association" "private2" {

  
  subnet_id      =  aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private.id
}

