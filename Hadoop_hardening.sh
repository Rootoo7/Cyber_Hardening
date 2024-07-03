#!/bin/bash

# Define the Hadoop configuration directory
HADOOP_CONF_DIR=/etc/hadoop/conf

# Define the files and directories to check
HADOOP_ENV_SH="$HADOOP_CONF_DIR/hadoop-env.sh"
CORE_SITE_XML="$HADOOP_CONF_DIR/core-site.xml"
HDFS_SITE_XML="$HADOOP_CONF_DIR/hdfs-site.xml"
YARN_SITE_XML="$HADOOP_CONF_DIR/yarn-site.xml"
MAPRED_SITE_XML="$HADOOP_CONF_DIR/mapred-site.xml"
LOG_DIR="/var/log/hadoop"
KEYTAB_DIR="/etc/security/keytabs"

# Function to check if a property exists and is set correctly in an XML file
check_property() {
  local file=$1
  local property=$2
  local expected_value=$3
  if grep -q "<name>$property</name>" $file; then
    actual_value=$(xmllint --xpath "string(//property[name='$property']/value)" $file)
    if [[ "$actual_value" == "$expected_value" ]]; then
      echo "PASS: $property is set to $expected_value in $file"
    else
      echo "FAIL: $property is set to $actual_value in $file (expected: $expected_value)"
    fi
  else
    echo "FAIL: $property is not set in $file"
  fi
}

# Function to check file permissions
check_permission() {
  local file=$1
  local expected_permission=$2
  local actual_permission=$(stat -c "%a" $file)
  if [[ "$actual_permission" -eq "$expected_permission" ]]; then
    echo "PASS: $file has correct permissions ($expected_permission)"
  else
    echo "FAIL: $file does not have correct permissions (expected: $expected_permission, found: $actual_permission)"
  fi
}

# Check if Hadoop services are running
if jps | grep -q 'NameNode\|DataNode\|ResourceManager\|NodeManager\|JobHistoryServer'; then
  echo "PASS: Hadoop services are running"
else
  echo "FAIL: Hadoop services are not running"
fi

# CIS Benchmark: Ensure secure ports and protocol
check_property $CORE_SITE_XML "hadoop.ssl.enabled" "true"
check_property $CORE_SITE_XML "fs.defaultFS" "hdfs://<your-namenode>:8020"
check_property $HDFS_SITE_XML "dfs.datanode.address" "0.0.0.0:1004"
check_property $HDFS_SITE_XML "dfs.datanode.http.address" "0.0.0.0:1006"
check_property $YARN_SITE_XML "yarn.resourcemanager.webapp.address" "<your-resourcemanager>:8090"
check_property $YARN_SITE_XML "yarn.nodemanager.webapp.address" "0.0.0.0:8042"

# CIS Benchmark: Enable Kerberos authentication
check_property $CORE_SITE_XML "hadoop.security.authentication" "kerberos"
check_property $HDFS_SITE_XML "dfs.namenode.kerberos.principal" "nn/_HOST@EXAMPLE.COM"
check_property $HDFS_SITE_XML "dfs.datanode.kerberos.principal" "dn/_HOST@EXAMPLE.COM"
check_property $YARN_SITE_XML "yarn.resourcemanager.principal" "rm/_HOST@EXAMPLE.COM"
check_property $YARN_SITE_XML "yarn.nodemanager.principal" "nm/_HOST@EXAMPLE.COM"
check_property $MAPRED_SITE_XML "mapreduce.jobhistory.principal" "jhs/_HOST@EXAMPLE.COM"

# CIS Benchmark: Ensure proper file permissions
check_permission $HADOOP_ENV_SH 600
check_permission $CORE_SITE_XML 600
check_permission $HDFS_SITE_XML 600
check_permission $YARN_SITE_XML 600
check_permission $MAPRED_SITE_XML 600
check_permission $LOG_DIR 750
check_permission $KEYTAB_DIR 700

# CIS Benchmark: Enable secure logging
if grep -q "hadoop.security.logger" $HADOOP_ENV_SH; then
  echo "PASS: Secure logging is enabled in $HADOOP_ENV_SH"
else
  echo "FAIL: Secure logging is not enabled in $HADOOP_ENV_SH"
fi

# CIS Benchmark: Check for encrypted shuffle
check_property $MAPRED_SITE_XML "mapreduce.shuffle.ssl.enabled" "true"

# CIS Benchmark: Ensure HDFS data transfer encryption
check_property $HDFS_SITE_XML "dfs.encrypt.data.transfer" "true"
check_property $HDFS_SITE_XML "dfs.encryption.key.provider.uri" "kms://http@<kms-server>:16000/kms"

# CIS Benchmark: Ensure audit logging is enabled
check_property $HDFS_SITE_XML "dfs.namenode.audit.loggers" "default,RFAAUDIT"
check_property $YARN_SITE_XML "yarn.resourcemanager.audit.logger.class" "org.apache.hadoop.yarn.server.resourcemanager.audit.RMAuditLogger"
check_property $CORE_SITE_XML "hadoop.security.audit.log" "true"

# CIS Benchmark: Ensure Hadoop services run as non-root user
hadoop_user=$(ps -eo user,comm | grep -E 'NameNode|DataNode|ResourceManager|NodeManager|JobHistoryServer' | awk '{print $1}' | sort | uniq)
if [[ "$hadoop_user" != "root" ]]; then
  echo "PASS: Hadoop services are running as non-root user"
else
  echo "FAIL: Hadoop services are running as root user"
fi

# CIS Benchmark: Ensure keytab files have restricted access
if [[ $(find $KEYTAB_DIR -type f -not -perm 600 | wc -l) -eq 0 ]]; then
  echo "PASS: All keytabs have correct permissions (600)"
else
  echo "FAIL: Some keytabs do not have correct permissions (600)"
fi

# CIS Benchmark: Ensure no sensitive information is present in logs
sensitive_info=$(grep -E -i 'password|secret|key' $LOG_DIR/*)
if [[ -z "$sensitive_info" ]]; then
  echo "PASS: No sensitive information found in logs"
else
  echo "FAIL: Sensitive information found in logs"
  echo "$sensitive_info"
fi

# CIS Benchmark: Ensure YARN NodeManager containers are secured
check_property $YARN_SITE_XML "yarn.nodemanager.container-executor.class" "org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor"
check_property $YARN_SITE_XML "yarn.nodemanager.linux-container-executor.group" "yarn"
check_permission "/etc/hadoop/container-executor.cfg" 640

# CIS Benchmark: Ensure YARN timeline service is secure
check_property $YARN_SITE_XML "yarn.timeline-service.enabled" "true"
check_property $YARN_SITE_XML "yarn.timeline-service.http-authentication.type" "kerberos"

echo "Hadoop hardening check completed."
