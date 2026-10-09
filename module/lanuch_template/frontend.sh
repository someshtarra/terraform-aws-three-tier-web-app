#!/bin/bash
sudo apt update -y
sleep 90
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2.service 

