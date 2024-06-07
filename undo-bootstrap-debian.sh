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
  sudo apt-get purge -y postgresql postgresql-contrib 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
  echo -n "Removing OpenJDK                      ... "
  sudo apt-get purge -y openjdk-17-jdk 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
  echo -n "Removing dependencies                 ... "
  sudo apt-get purge -y gnupg2 curl apt-transport-https lsb-release 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
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
  echo -n "Removing PostgreSQL configuration     ... "
  sudo rm -rf /etc/postgresql /var/lib/postgresql 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
  echo -n "Removing OpenJDK configuration        ... "
  sudo rm -rf /etc/java-11-openjdk 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
  checkError "${?}"
}

# Execute undo procedure
clear
stopServices
dropDatabase
removePackages
removeConfig

echo ""
echo "OpenNMS setup and dependencies have been successfully undone."
echo ""
