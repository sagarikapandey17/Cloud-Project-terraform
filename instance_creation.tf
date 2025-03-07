terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45"
    }
  }

  required_version = ">= 1.9.0"
}

resource "aws_instance" "mysql" {

  ami                    = var.mysql_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id_private
  vpc_security_group_ids = [var.mysql_security_group]
  key_name               = "EC2_SSH_KEY"

  tags = {
    Name = "SQLApp"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -x
    while [ ! -e /dev/xvdh ]; do
      sleep 1
    done
    if ! blkid /dev/xvdh; then
      sudo mkfs -t ext4 /dev/xvdh
    fi
    sudo mkdir -p /mnt/mysql-data
    sudo mount /dev/xvdh /mnt/mysql-data
    sudo chown -R mysql:mysql /mnt/mysql-data
    sudo chmod 755 /mnt/mysql-data
    echo "/dev/xvdh /mnt/mysql-data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
    sudo systemctl stop mysql
    sudo rsync -av /var/lib/mysql/ /mnt/mysql-data/
    sudo sed -i 's|^#*\\s*datadir\\s*=.*|datadir = /mnt/mysql-data/|' /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo grep 'datadir' /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i '/^}/i \\n/mnt/mysql-data/ r,\\n/mnt/mysql-data/** rwk,' /etc/apparmor.d/usr.sbin.mysqld
    sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
    sudo systemctl restart apparmor
    sudo systemctl status apparmor
    sudo systemctl start mysql
  EOF
}

resource "aws_ebs_volume" "mysql_data" {
  availability_zone = aws_instance.mysql.availability_zone
  size              = 50
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "MySQL-Data-Volume"
  }
}

resource "aws_volume_attachment" "mysql_data_attach" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.mysql_data.id
  instance_id = aws_instance.mysql.id

  depends_on = [aws_ebs_volume.mysql_data]
}

output "mysql_private_ip" {
  value       = aws_instance.mysql.private_ip
  description = "The private IP of the MySQL instance"
}

resource "aws_instance" "webapp" {

  ami                         = var.webapp_ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id_public
  vpc_security_group_ids      = [var.webapp_security_group]
  key_name                    = "EC2_SSH_KEY"
  associate_public_ip_address = true

  tags = {
    Name = "WebApp"
  }
  user_data = <<-EOF
    #!/bin/bash
    # Create a file to store environment variables
    sudo tee /etc/environment.d/health-check.conf > /dev/null <<EOT
    MYSQL_IP=${aws_instance.mysql.private_ip}
    MYSQL_USER=${var.database_username}
    MYSQL_PASS=${var.database_password}
    EOT
    sudo chmod 644 /etc/environment.d/health-check.conf
    sudo systemctl enable health-check.service
    sudo systemctl start health-check.service
  EOF
}
output "webapp_public_ip" {
  value       = aws_instance.webapp.public_ip
  description = "The public IP of the MySQL instance"
}
