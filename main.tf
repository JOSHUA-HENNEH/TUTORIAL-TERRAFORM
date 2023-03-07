
# configuring our network for Tenacity IT

# Create a VPC

resource "aws_vpc" "Tenacity-IT" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "Tenacity-IT"
  }
}

# creating public subnets

resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.Tenacity-IT.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod -pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.Tenacity-IT.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Prod -pub-sub2"
  }
}

# creating private subnets

resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.Tenacity-IT.id
  cidr_block = "10.0.12.0/24"

  tags = {
    Name = "Prod -priv-sub1"
  }
}

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.Tenacity-IT.id
  cidr_block = "10.0.6.0/24"

  tags = {
    Name = "Prod -priv-sub2"
  }
}

# creating public route table

resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.Tenacity-IT.id

  route = []

  tags = {
    Name = "Prod-pub-route-table"
  }
}

# creating private route table
resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.Tenacity-IT.id

  route = []

  tags = {
    Name = "Prod-priv-route-table"
  }
}

# Associate the subnets to their respective route tables

resource "aws_route_table_association" "Prod-pub-sub1_assoc" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Prod-pub-sub2_assoc" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Prod-priv-sub1_assoc" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "Prod-priv-sub2_assoc" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}


# create an internet gateway

resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.Tenacity-IT.id

  tags = {
    Name = "Prod-igw"
  }
}

# Associate the internet gateway with the public route table

resource "aws_route" "IGW-Assocciation" {
  route_table_id            = aws_route_table.Prod-pub-route-table.id
  gateway_id = aws_internet_gateway.Prod-igw.id
  destination_cidr_block    = "0.0.0.0/0"
}


# Creating an eIP address 
resource "aws_eip" "EIP" {
  vpc      = true
}



# Create NAT gateway

resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.Prod-pub-sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }
}

# NAT Gateway Association with private route table

resource "aws_route" "Prod-Nat-Assocciation" {
  route_table_id            = aws_route_table.Prod-priv-route-table.id
  gateway_id = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block    = "0.0.0.0/0"
}



