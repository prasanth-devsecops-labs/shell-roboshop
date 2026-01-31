The README.md file for the Roboshop Shell Scripting project describes automated shell scripts to deploy the Roboshop e-commerce application, focusing on infrastructure automation using Shell Scripting and AWS CLI with emphasis on DRY principles and modular design.

The project highlights include a modular architecture using a common.sh file, DRY principles via centralized application setup, reliability through idempotent checks, and detailed logging.

Prerequisites include 10 EC2 instances, configured AWS CLI, and root access to execute the scripts




## ignore ##
Requirements:
1. check user is having root permissions or not
2. If YES allow further to run commands, If NO exit and provide error message to the user
3. Add colors for logs for better readability
4. Capture logs in log file along with terminal
5. Handle errors/failure cases explicitly
6. Validate the commands running status
7. Optimise the code and keep the code DRY max possible
8. Scripts should not fail when running repeatedly, we need idempotent behaviour.

