# ---------- AMI:最新 Amazon Linux 2023(x86_64) ----------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon 官方账号

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------- IAM:SSM 角色(两台实例共用) ----------
resource "aws_iam_role" "ssm" {
  name = "saalab-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "saalab-ec2-ssm-profile"
  role = aws_iam_role.ssm.name
}

# ---------- 安全组:公网实例默认 SG(不开入站,走 SSM) ----------
resource "aws_security_group" "public" {
  name        = "saalab-public-sg"
  description = "No inbound rules, all outbound allowed"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  name        = "saalab-private-sg"
  description = "No inbound rules, all outbound allowed"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- 新 SG:仅承载 SSH 入站规则(不改动老 SG) ----------
resource "aws_security_group" "public_ssh" {
  name        = "saalab-public-ssh-sg"
  description = "SSH from admin IP only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
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

# ---------- EC2 实例(无 SSH 密钥,走 Session Manager) ----------
resource "aws_instance" "public" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id, aws_security_group.public_ssh.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  tags = { Name = "saalab-public" }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  tags = { Name = "saalab-private" }
}
