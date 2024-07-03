# Hadoop_hardening
This script is designed to automate the hardening of a Hadoop environment by checking compliance with best security practices and CIS benchmarks. It ensures your Hadoop cluster is configured securely to protect critical data and mitigate potential security risks.

Usage
Clone the Repository:

bash
Copy code
git clone https://github.com/yourusername/hadoop-hardening-script.git](https://github.com/Rootoo7/Cyber_Hardening.git
cd hadoop-hardening-script
Make the Script Executable:

bash
Copy code
chmod +x hadoop_hardening_check.sh
Run the Script:

bash
Copy code
./hadoop_hardening_check.sh
Customization

Update paths, filenames, and configuration values (e.g., <your-namenode>, <your-resourcemanager>, <kms-server>, EXAMPLE.COM) to match your Hadoop environment.

Modify any checks as per your specific security requirements.

**Prerequisites**

Hadoop environment set up with configuration files located in /etc/hadoop/conf.
Proper access permissions to check and modify Hadoop configuration files and directories.
