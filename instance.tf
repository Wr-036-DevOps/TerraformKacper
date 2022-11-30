terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
            
        }
    }
}


resource "aws_instance" "app_server" {

  ami           = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  key_name="kacperterraform"
   	vpc_security_group_ids       = ["sg-09f5a92afde0ec14b"]		     
	tags = {
        ita_group = "Wr-36"
        Name="terraform2"
        } 
	volume_tags = {
        ita_group = "Wr-36"
        } 
 
     user_data = <<-EOF
                #!/bin/bash
                exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
                apt update -y
                git clone https://github.com/Wr-036-DevOps/DiscordKacper
                apt install python3-pip -y
                cd DiscordKacper
                pip install -r requirements.txt 
                echo 'TOKEN=BotTokenHere' > .env
                apt install awscli -y
                python3 app.py
                EOF
                
}