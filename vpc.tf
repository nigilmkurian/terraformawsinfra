# ---  Create a VPC ------


resource "aws_vpc" "vpc1" {
  cidr_block       = "10.10.0.0/16"
  tags = {
    Name = "vpc1"
  }
}





#--- Create Internet Gateway -------


resource "aws_internet_gateway" "igw" {
 vpc_id = "${aws_vpc.vpc1.id}"
 tags = {
    Name = "igw"
 }
}




#-------  Create public subnet  --------

         
resource "aws_subnet" "public-subnet" {
  cidr_block        = "10.10.20.0/24"
  vpc_id            = "${aws_vpc.vpc1.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "public-subnet"
   }
}




#-------  Create private subnet  ------



resource "aws_subnet" "private-subnet" {
  cidr_block        = "10.10.31.0/24"
  vpc_id            = "${aws_vpc.vpc1.id}"
  tags = {
   Name = "private-subnet"
   }
}




# --------  Create Elastic IP ---------


resource "aws_eip" "eip" {
  vpc=true
}




# --------------  NAT Gateway ------------

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.public-subnet.id}"
  tags = {
      Name = "vpc1 Nat Gateway"
  }
}




# --------------  Routing ----------



resource "aws_route_table" "public-route" {
  vpc_id =  "${aws_vpc.vpc1.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

   tags = {
       Name = "public-route"
   }
}



resource "aws_route_table" "private-route" {
  vpc_id =  "${aws_vpc.vpc1.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_nat_gateway.ngw.id}"
  }

   tags = {
       Name = "private-route"
   }
}




#------------   Subnet Association ------------




resource "aws_route_table_association" "publicsa" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}



resource "aws_route_table_association" "privatesa" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.private-route.id}"
}
