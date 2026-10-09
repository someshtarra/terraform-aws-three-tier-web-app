#!/bin/bash
sudo apt update -y
sudo pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo systemctl start pm2-root
sudo systemctl enable pm2-root
sudo apt install mysql-server -y
cd /home/ubuntu/aws_three_tier_code/backend
sudo pm2 start index.js --name "backendapi"
mysql -h book.rds.com -u admin -pSomesh12345 test < test.sql