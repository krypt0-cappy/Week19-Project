# Create our VPC, Subnets, Internet Gateway

resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Week-19-ECS-VPC"
  }
}

resource "aws_subnet" "week19_ecs_publicsubnet1" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "week19_ecs_publicsubnet2" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
}

# Create Internet Gateway
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "Week-19-ECS-IGW"
  }
}

# Create a Routing Table
resource "aws_route_table" "ecs_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "Week-19-ECS-RT"
  }
}

# Create a Default Public Route
resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.ecs_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs_igw.id
}

# Create a Public Route Table Association
resource "aws_route_table_association" "ecs-rt-association1" {
  subnet_id      = aws_subnet.week19_ecs_publicsubnet1.id
  route_table_id = aws_route_table.ecs_route_table.id
}

resource "aws_route_table_association" "ecs-rt-association2" {
  subnet_id      = aws_subnet.week19_ecs_publicsubnet2.id
  route_table_id = aws_route_table.ecs_route_table.id
}

resource "aws_security_group" "ecs-sg" {
  vpc_id = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}