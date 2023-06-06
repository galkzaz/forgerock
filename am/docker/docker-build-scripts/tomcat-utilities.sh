#!/bin/bash

# Command Syntax: tomcat-utilities.sh start|stop <tomcat_directory>

if [ $# -ne 2 ]; then
  printf "Command Syntax: install-utilities.sh start|stop <tomcat_directory>\n"
  exit 1
fi

if [ -d $2 ]; then
  if [ ! -f ${2}/bin/catalina.sh ]; then
    printf "The directory '${2}' is not a valid tomcat directory\n"
    exit 1
  fi

  case $1 in
    start|START)
      printf "Startting the tomcat instance in the directory ${2}\n"

  	  rm -f ${2}/logs/catalina.out

      ${2}/bin/catalina.sh start

      count=30
      printf "\nWaiting for server startup"
      while [[ -z "$(cat ${2}/logs/catalina.out | grep "Server startup")" && count -gt 0 ]]; do
          sleep 2 && printf "."
          ((count--))
      done

      if [[ count -eq 0 ]]; then
          printf "\nServer failed to startup normally. Tomcat log:\n\n"
          cat ${2}/logs/catalina.out
          pkill -9 -f tomcat
      else
          printf "\nServer started\n"
          printf "\nServer started...........................\n"
          cat ${2}/logs/catalina.out
      fi

      ;;
    stop|STOP)
      printf "Stopping the tomcat instance in the directory ${2}\n"

      ${2}/bin/catalina.sh stop

      count=30
      printf "\nWaiting for server shutdown\n"
      while [[ -z "$(cat ${2}/logs/catalina.out | grep "Destroying ProtocolHandler")" && count -gt 0 ]]; do
          sleep 2 && printf "."
          ((count--))
      done

      if [[ count == 0 ]]; then
          printf "Server failed to shutdown normally. Tomcat log:\n\n"
          cat ${2}/logs/catalina.out
          pkill -9 -f tomcat
      else
          printf "\nServer stopped\n"
      fi

      ;;
    *)
      printf "The command '${1}' is not valid; valid commands are start or stop.\n"

      ;;
  esac
else
  printf "Unable to locate the directory '${2}'\n"
fi
