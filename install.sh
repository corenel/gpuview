#!/usr/bin/env bash

# install python package
sudo -H -E python3 -m pip install -e .

# install as supevisord service
# gpuview service --safe-jone

# install as systemctl service
CURR_USER=${USER:-nobody}
CURR_EXEC_PATH=$(which gpuview)
sed -r "s/CURR_USER/${CURR_USER}/g" service/gpuview.service > service/gpuview.service.local
sed -ir "s+CURR_EXEC_PATH+${CURR_EXEC_PATH}+g" service/gpuview.service.local
sudo systemctl stop gpuview >> /dev/null 2>&1
sudo cp service/gpuview.service.local /etc/systemd/system/gpuview.service
sudo systemctl daemon-reload
sudo systemctl enable gpuview
sudo systemctl restart gpuview
