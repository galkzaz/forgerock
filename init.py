#!/usr/local/bin/python3

import sys
import subprocess
import os
import platform
import shutil
import getopt

# Profile to build ...
MAVEN_PROFILE="local"

# Repo for openam web UI ...
OPEN_WEB_GIT_REPO=""

# Repo for dynamic claims UI ...
DYNAMIC_CLAIMS_GIT_REPO=""

# Repo for OpenIG ...
OPENIG_GIT_REPO=""

try:
  opts, args = getopt.getopt(sys.argv[1:], "P:w:d:i:", ["maven_build_profile=", "openam_web_git_dir=", "dynamic_claims_git_dir=", "openig_git_dir="])
except getopt.GetoptError:
  print("init.py -P <Maven Build Profile> -w <GIT REPO for openam_web> -d <GIT REPO for dynamic claims ui> -i <GIT REPO for OpenIG>")
  sys.exit(2)

for opt, arg in opts:
  if opt == '-h':
    print("init.py -P <maven build profile> -w <GIT open_web working directory>")
    sys.exit()
  elif opt in ("-P", "--maven_build_profile"):
    MAVEN_PROFILE = arg
  elif opt in ("-w", "--openam_web_git_dir"):
    OPEN_WEB_GIT_REPO = arg
  elif opt in ("-d", "--dynamic_claims_git_dir"):
    DYNAMIC_CLAIMS_GIT_REPO = arg
  elif opt in ("-i", "--openig_git_dir"):
    OPENIG_GIT_REPO = arg

if not os.path.exists(OPEN_WEB_GIT_REPO):
  print("Unable to located the directory for the OPENAM_WEB_GIT_REPO")
  sys.exit(2)

if not os.path.exists(OPENIG_GIT_REPO):
  print("Unable to located the directory for the OPENIG_GIT_REPO")
  sys.exit(2)

#if not os.path.exists(DYNAMIC_CLAIMS_GIT_REPO):
#  print("Unable to located the directory for the DYNAMIC_CLAIMS_REPO")
#  sys.exit(2)

print("Initialization of your ForgeRock Personal Development Environment, Profile = (" + MAVEN_PROFILE + ")")
print("=================================================================")
print("")
print("This will initialize (on first run) or reset (on subsequent runs)")
print("your ForgeRock Personal Development Environment (PDE). Use with")
print("caution!")
print("")

if platform.system() == "Windows":
  python_command = shutil.which("py")
elif platform.system() == "Darwin":
  python_command = shutil.which("python3")
else:
  sys.exit("Unsupported system has been found.")

# build and package the openam war file
if os.path.exists(os.path.join(".", "build", "build_and_package_openam_war.py")):
  subprocess.call([python_command, os.path.join(".", "build", "build_and_package_openam_war.py"), MAVEN_PROFILE])

# build and package the custom UI code
if os.path.exists(os.path.join(".", "build", "build_and_package_openig.py")):
  subprocess.call([python_command, os.path.join(".", "build", "build_and_package_openig.py"), MAVEN_PROFILE, OPENIG_GIT_REPO])

# build and package the custom UI code
if os.path.exists(os.path.join(".", "build", "build_and_package_custom_ui.py")):
  subprocess.call([python_command, os.path.join(".", "build", "build_and_package_custom_ui.py"), MAVEN_PROFILE, OPEN_WEB_GIT_REPO])

# build and package the custom UI code
if os.path.exists(os.path.join(".", "build", "build_and_package_dynamicclaims_ui.py")):
  subprocess.call([python_command, os.path.join(".", "build", "build_and_package_dynamicclaims_ui.py"), MAVEN_PROFILE, DYNAMIC_CLAIMS_GIT_REPO])

# copy wars from am/code builds
if os.path.exists(os.path.join(".", "build", "copy_build_artifacts.py")):
  subprocess.call([python_command, os.path.join(".", "build", "copy_build_artifacts.py")])

# update am.war
#if os.path.exists(os.path.join("am", "build", "resources/update_war.py")):
#  subprocess.call([python_command, os.path.join("am", "build", "resources/update_war.py")])

# encode am (openam) scripts ...
if os.path.exists(os.path.join(".", "build", "encode_am_scripts.py")):
  subprocess.call([python_command, os.path.join(".", "build", "encode_am_scripts.py")])

# initialize IDM config
if os.path.exists(os.path.join(".", "idm", "run", "init_config.py")):
  subprocess.call([python_command, os.path.join(".", "idm", "run", "init_config.py")])

# Make sure we have a the following directories, or the docker-compose will fail.
if not os.path.isdir(os.path.join(".", "env")):
  os.makedirs(os.path.join(".", "env"))
if not os.path.isdir(os.path.join(".", "am", "build", "amster", "am-snapshot")):
  os.makedirs(os.path.join(".", "am", "build", "amster", "am-snapshot"))
if not os.path.isdir(os.path.join(".", "am", "build", "resources", "docker-build-scripts")):
  os.makedirs(os.path.join(".", "am", "build", "resources", "docker-build-scripts"))
if not os.path.isdir(os.path.join(".", "am", "build", "resources", "ssoadm-config-data")):
  os.makedirs(os.path.join(".", "am", "build", "resources", "ssoadm-config-data"))
if not os.path.isdir(os.path.join(".", "am", "build", "resources", "policy-config-xml")):
  os.makedirs(os.path.join(".", "am", "build", "resources", "policy-config-xml"))
if not os.path.isdir(os.path.join(".", "am", "build", "resources", "entities")):
  os.makedirs(os.path.join(".", "am", "build", "resources", "entities"))
if not os.path.isdir(os.path.join(".", "am", "build", "resources", "agents")):
  os.makedirs(os.path.join(".", "am", "build", "resources", "agents"))

# Update build directories with files for userid/password updates
if platform.system() == "Windows":
  subprocess.call(['Xcopy', '/h', '/y', '/i', ".env", "env"])
  subprocess.call(['Xcopy', '/h', '/y', '/i', ".env6523", "env"])
  subprocess.call(['Xcopy', '/h', '/y', '/i', ".env653", "env"])

  subprocess.call(['Xcopy', '/s', '/i', '/e', '/y', os.path.join(".", "am", "agents" + os.sep + "."), os.path.join(".", "am", "build", "resources", "agents" + os.sep) ])
  subprocess.call(['Xcopy', '/s', '/i', '/e', '/y', os.path.join(".", "am", "entities" + os.sep + "."), os.path.join(".", "am", "build", "resources", "entities" + os.sep) ])
  subprocess.call(['Xcopy', '/s', '/i', '/e', '/y', os.path.join(".", "am", "policy-config-xml" + os.sep + "."), os.path.join(".", "am", "build", "resources", "policy-config-xml" + os.sep) ])
  subprocess.call(['Xcopy', '/s', '/i', '/e', '/y', os.path.join(".", "am", "amster-config" + os.sep + "."), os.path.join(".", "am", "build", "resources", "amster-config" + os.sep) ])
  subprocess.call(['Xcopy', '/s', '/i', '/e', '/y', os.path.join(".", "am", "ssoadm-config-data" + os.sep + "."), os.path.join(".", "am", "build", "resources", "ssoadm-config-data" + os.sep) ])
  subprocess.call(['Xcopy', '/s', '/i', '/e', '/y', os.path.join(".", "am", "docker-build-scripts" + os.sep + "."), os.path.join(".", "am", "build", "resources", "docker-build-scripts" + os.sep) ])
elif platform.system() == "Darwin":
  subprocess.call(['cp', '-a', ".env", "env"])
  subprocess.call(['cp', '-a', ".env6523", "env"])
  subprocess.call(['cp', '-a', ".env653", "env" ])

  subprocess.call(['cp', '-a', os.path.join(".", "am", "agents" + os.sep + "."), os.path.join(".", "am", "build", "resources", "agents" + os.sep) ])
  subprocess.call(['cp', '-a', os.path.join(".", "am", "entities" + os.sep + "."), os.path.join(".", "am", "build", "resources", "entities" + os.sep) ])
  subprocess.call(['cp', '-a', os.path.join(".", "am", "policy-config-xml" + os.sep + "."), os.path.join(".", "am", "build", "resources", "policy-config-xml" + os.sep) ])
  subprocess.call(['cp', '-a', os.path.join(".", "am", "ssoadm-config-data" + os.sep + "."), os.path.join(".", "am", "build", "resources", "ssoadm-config-data" + os.sep) ])
  subprocess.call(['cp', '-a', os.path.join(".", "am", "docker-build-scripts" + os.sep + "."), os.path.join(".", "am", "build", "resources", "docker-build-scripts" + os.sep) ])
else:
  sys.exit("copy_ig_configuration: Unsupported system has been found.")

# Update userid/password(s)
if os.path.exists(os.path.join(".", "build", "update_passwords.py")):
  subprocess.call([python_command, os.path.join(".", "build", "update_passwords.py"), os.getcwd() + os.sep + "env", MAVEN_PROFILE])
  subprocess.call([python_command, os.path.join(".", "build", "update_passwords.py"), os.getcwd() + os.sep + "am" + os.sep + "build", MAVEN_PROFILE])
  subprocess.call([python_command, os.path.join(".", "build", "update_passwords.py"), os.getcwd() + os.sep + "ig" + os.sep + "build", MAVEN_PROFILE])
