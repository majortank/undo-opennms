# OpenNMS Undo Script

## Overview

This repository provides a script to undo the installation and setup of OpenNMS, which includes stopping the OpenNMS service, removing installed packages, dropping the PostgreSQL database and user, and deleting configuration files.

## Prerequisites

Before running the undo script, ensure you have:

- Root or sudo privileges to execute the script.
- The setup script should have been executed previously to install OpenNMS and its dependencies.

## Installation

Clone the repository to your local machine:

```sh
git clone https://github.com/majortank/opennms-undo-script.git
cd opennms-undo-script
```

## Usage

1. Open the terminal.
2. Navigate to the directory where the script is located.
3. Make the script executable:
   ```sh
   chmod +x undo_opennms_setup.sh
   ```
4. Run the script with root privileges:
   ```sh
   sudo ./undo_opennms_setup.sh
   ```

## Script Details

### undo_opennms_setup.sh

```sh
#!/usr/bin/env bash
#
# Script to undo OpenNMS setup

set -eEuo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

DEBIAN_FRONTEND=noninteractive
ERROR_LOG="undo_bootstrap.log"
DB_NAME="opennms"
DB_USER="opennms"
OPENNMS_HOME="/usr/share/opennms"

checkError() {
  if [[ "${1}" -eq 0 ]]; then
    echo -e "[ OK ]"
  else
    echo -e "[ FAILED ]"
    exit 1
  fi
}

stopServices() {
  echo -n "Stopping OpenNMS service              ... "
  sudo systemctl stop opennms 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
}

removePackages() {
  echo -n "Removing OpenNMS packages             ... "
  sudo apt-get purge -y opennms opennms-webapp-hawtio 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
  echo -n "Removing PostgreSQL                   ... "
  sudo apt-get purge -y postgresql 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
  echo -n "Removing OpenJDK                      ... "
  sudo apt-get purge -y openjdk-17-jdk 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
  echo -n "Removing dependencies                 ... "
  sudo apt-get purge -y gnupg2 curl apt-transport-https 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
  echo -n "Cleaning up APT cache                 ... "
  sudo apt-get autoremove -y 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  sudo apt-get clean 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
}

dropDatabase() {
  echo -n "Dropping OpenNMS database             ... "
  sudo -i -u postgres psql -c "DROP DATABASE IF EXISTS ${DB_NAME};" 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
  echo -n "Dropping OpenNMS database user        ... "
  sudo -i -u postgres psql -c "DROP USER IF EXISTS ${DB_USER};" 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
}

removeConfig() {
  echo -n "Removing OpenNMS home directory       ... "
  sudo rm -rf "${OPENNMS_HOME}" 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
}

# Execute undo procedure
clear
stopServices
dropDatabase
removePackages
removeConfig

echo ""
echo "OpenNMS setup has been successfully undone."
echo ""
```

## Logging

The script logs all operations and errors to `undo_bootstrap.log` in the current directory. Check this file if you encounter any issues.
---

By following this documentation, users can easily understand how to use the undo script and contribute to the repository.
