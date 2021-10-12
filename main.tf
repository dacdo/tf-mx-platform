resource "aws_vpc" "dd_vpc" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.dd_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.dd_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false
}

# internet gateway for the vpc
resource "aws_internet_gateway" "myvpc-igw" {
  vpc_id = aws_vpc.dd_vpc.id
  tags = {
    Name = "dd_vpc-igw"
  }
}
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.dd_vpc.id

  tags = {
    Name = "rtb-for-public-subnet"
  }
}
# route to the my-igw
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myvpc-igw.id
}

resource "aws_route_table_association" "assoc-public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rtb.id
}
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.dd_vpc.id

  tags = {
    Name = "rtb-for-private-subnet"
  }
}
resource "aws_route_table_association" "assoc-private" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rtb.id
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"

  # instead of dac_test_role, you can use aws_iam_role instance
  role = aws_iam_role.instance.name
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.dac_test_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "instance" {
  name               = "instance_role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "dac_test_role" {
  name               = "dac_test_role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.dd_vpc.id
  service_name    = "com.amazonaws.us-west-2.s3"
  route_table_ids = [aws_route_table.private-rtb.id]
}
