# Hadoop_hardening
This script is designed to automate the hardening of a Hadoop environment by checking compliance with best security practices and CIS benchmarks. It ensures your Hadoop cluster is configured securely to protect critical data and mitigate potential security risks.

Features
Service Verification: Confirms Hadoop services (NameNode, DataNode, ResourceManager, NodeManager, JobHistoryServer) are running.
Secure Ports and Protocols: Verifies secure configurations for ports and protocols.
Kerberos Authentication: Ensures Kerberos authentication is enabled and correctly configured.
File Permissions: Checks and enforces correct file permissions for configuration files and directories.
Secure Logging: Verifies secure logging settings.
Encrypted Shuffle: Ensures the map-reduce shuffle is encrypted.
HDFS Data Transfer Encryption: Confirms HDFS data transfer encryption is enabled.
Audit Logging: Checks if audit logging is enabled for Hadoop services.
Non-root Service Execution: Ensures Hadoop services run as a non-root user.
Keytab File Security: Verifies that keytab files have restricted access.
Sensitive Information: Checks logs for any sensitive information leakage.
YARN NodeManager Container Security: Ensures NodeManager containers are secure.
YARN Timeline Service Security: Verifies the security of the YARN timeline service.
Usage
Clone the Repository:

bash
Copy code
git clone https://github.com/yourusername/hadoop-hardening-script.git
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
Prerequisites
Hadoop environment set up with configuration files located in /etc/hadoop/conf.
Proper access permissions to check and modify Hadoop configuration files and directories.
