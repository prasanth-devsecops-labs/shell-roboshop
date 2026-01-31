# Roboshop Shell Scripting - DRY Version
This project automates the deployment of the Roboshop e-commerce application using Shell Scripting and AWS CLI. The primary focus of this version was to move away from repetitive code and implement DRY (Don't Repeat Yourself) principles for a professional, modular setup.

# 🚀 Project Highlights
Modular Architecture: Centralized logic using a common.sh file.
DRY Principles: Shared functions for Node.js, Java, Python, and Nginx application setups.
Reliability: Idempotent checks (prevents duplicate users/instances) and automated service lifecycle management.
Detailed Logging: Centralized logging in /var/log/shell-roboshop/ with script execution timers.

# 📋 Prerequisites
Infrastructure: 10 EC2 instances (RHEL 9 recommended) named according to the services.
Access: Root/Sudo access on all instances.
AWS CLI: Configured on your workstation to manage Route53 and EC2 states.

# 🛠️ How to Deploy
Clone the repository:
bash
git clone https://github.com/prasanth-devsecops-labs/shell-roboshop.git
cd shell-roboshop
Use code with caution.

Run the scripts:
Execute the scripts for each service. It is recommended to start with the databases first:
bash
# Databases
sudo bash mongodb.sh
sudo bash redis.sh
sudo bash mysql.sh
sudo bash rabbitmq.sh

# App Services
sudo bash catalogue.sh
sudo bash user.sh
sudo bash cart.sh
sudo bash shipping.sh
sudo bash payment.sh

# Web Server
sudo bash frontend.sh
Use code with caution.

# 📝 Learning Journey
This version was refactored from a "vague" initial script to a modular one. I spent significant time debugging sed quoting issues, S3 URL logic, and cross-service permissions (RabbitMQ). It was a great hands-on exercise in infrastructure automation!
