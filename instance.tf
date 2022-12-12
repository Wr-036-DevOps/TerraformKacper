terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"

    }
  }

}
# provider "aws" { -  
#   region     = ""
#   access_key = ""
#   secret_key = ""
# }

resource "aws_iam_role" "test_role" {
  name = "Training-test_role"
permissions_boundary = "arn:aws:iam::536460581283:policy/boundaries/CustomPowerUserBound" 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
    
      },

    ]
  })
}

resource "aws_iam_role_policy_attachment" "SQSQueue-execution-policy" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}
resource "aws_iam_instance_profile" "test_profile" { // ec2 need to have access to sqs 
  name = "test_profile"
  role = aws_iam_role.test_role.name
}

resource "aws_instance" "app_server" { 

  ami                    = "ami-0caef02b518350c8b"
  instance_type          = "t2.micro"
  key_name               = "FrankfurtKey"
  vpc_security_group_ids = ["sg-04c151761c241c520"]
  subnet_id="subnet-088a0df0e650d36fb"
  tags = {
    ita_group = "Wr-36"
    Name      = "terraform2"
  }
  volume_tags = {
    ita_group = "Wr-36"
  }
iam_instance_profile = aws_iam_instance_profile.test_profile.name

  user_data = <<-EOF
                #!/bin/bash
                exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
                apt update -y
                git clone https://github.com/Wr-036-DevOps/DiscordKacper
                apt install python3-pip -y
                cd DiscordKacper
                pip install -r requirements.txt 
                echo 'TOKEN=${var.token}' > .env
                chmod +x apka.sh
                ./apka.sh


EOF
}




 