#!/bin/sh


echo 'Determine OS platform'
if [ -f /etc/os-release ]; then
  # freedesktop.org and systemd
  . /etc/os-release
  OS=$NAME
  VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
  # linuxbase.org
  OS=$(lsb_release -si)
  VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
  # For some versions of Debian/Ubuntu without lsb_release command
  . /etc/lsb-release
  OS=$DISTRIB_ID
  VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
  # Older Debian/Ubuntu/etc.
  OS=Debian
  VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
  # Older SuSE/etc.
  ...
elif [ -f /etc/redhat-release ]; then
  # Older Red Hat, CentOS, etc.
  ...
else
  # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
  OS=$(uname -s)
  VER=$(uname -r)
fi

echo "${OS}-${VER}"

echo 'Install gpuview service:'

user=$USER
path=$(which gpuview)

echo ''
echo 'Installing supervisor...'
if [ "$OS" = "Ubuntu" ]; then
  sudo apt install -y supervisor
elif [ "$OS" = "CentOS Linux" ]; then
  sudo yum install -y epel-release
  sudo yum install -y supervisor
else
  echo "Unsupported OS"
fi

echo ''
echo 'Deploying service...'

LOG_PATH=$HOME/.gpuview
mkdir -p ${LOG_PATH}

if [ "$OS" = "Ubuntu" ]; then
  CONF_PATH=/etc/supervisor/conf.d/gpuview.conf
elif [ "$OS" = "CentOS Linux" ]; then
  CONF_PATH=/etc/supervisord.d/gpuview.ini
else
  echo "Unsupported OS"
fi

sudo echo "[program:gpuview]
user = ${user}
environment = HOME=\"${HOME}\",USER=\"${user}\"
directory = /home/${user}
command = ${path} run ${1}
autostart = true
autorestart = true
stderr_logfile = ${LOG_PATH}/stderr.log
stdout_logfile = ${LOG_PATH}/stdout.log" \
| sudo tee "${CONF_PATH}" > /dev/null

if [ "$OS" = "CentOS Linux" ]; then
  sudo touch /var/run/supervisor.sock
  sudo chmod 777 /var/run/supervisor.sock
fi

sudo supervisorctl reread
if [ "$OS" = "Ubuntu" ]; then
  sudo systemctl enable supervisor
  sudo systemctl restart supervisor
  sudo systemctl status supervisor
elif [ "$OS" = "CentOS Linux" ]; then
  sudo systemctl enable supervisord
  sudo systemctl restart supervisord
  sudo systemctl status supervisord
else
  echo "Unsupported OS"
fi

echo ''
echo 'Starting gpuview service'
sudo supervisorctl restart gpuview
sudo supervisorctl status gpuview

echo '~DONE~'
