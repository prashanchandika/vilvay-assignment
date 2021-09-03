#!/bin/bash

sudo yum install -y https://s3.region.amazonaws.com/amazon-ssm-region/latest/linux_amd64/amazon-ssm-agent.rpm
sudo start amazon-ssm-agent


echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFALEuxZbV0ZQoWu9lh+NyRkvehCg03rPLLvY9pCOZWlQrBon7f/pdFrEpH8AP8Whd5ENYofJ1uhSR+9ysGSTHZsov+Xn8JdRq2a098lzphFhL7eXkN3zrt038y7or2XwXFTBV3s/DyzuZlNGgUsOQrgg6PgL5bt+djM1YEvWTnNCJiGGJtAeOOLhXqDPqX1wx7NnY87YyQOIyUXhcds76ouk2XPVq8AXixZZa54jHDAnkZJZkucN3MFhMhEQNS0o0KKBcfEz3EHi0JXl2C0n4Rc52qnsNId2V1MHF/2atyGX3Xd7ZE3G/FIG62H3x2ad0mbt8q7sY8U5nu9Xl/Lrp root@ip-172-31-21-43.ec2.internal" >> /home/ec2-user/.ssh/authorized_keys

amazon-linux-extras install nginx1.12
systemctl start nginx
systemctl enable nginx
systemctl status nginx
