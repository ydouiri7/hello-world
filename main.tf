provider "aws" {
  region = "us-east-1"
}

variable "jenkins_ports" {
  type    = list(number)
  default = [22, 8080, 80, 443]
}

variable "tomcat_ports" {
  type    = list(number)
  default = [22, 8080]
}

resource "aws_security_group" "jenkinsSG" {
  name        = "jenkinsSG"
  description = "Security group for Jenkins server"
  
  dynamic "ingress" {
    for_each = var.jenkins_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tomcatSG" {
  name        = "tomcatSG"
  description = "Security group for Tomcat server"
  
  dynamic "ingress" {
    for_each = var.tomcat_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins-server" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t2.micro"
  security_groups = [aws_security_group.jenkinsSG.name]
  
  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_instance" "tomcat-server" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t2.micro"
  security_groups = [aws_security_group.tomcatSG.name]
  
  tags = {
    Name = "tomcat-server"
  }
}
