#!/bin/bash --login
source /etc/profile.d/globals.sh

if [[ $CSI_ROOT == '' ]]; then
  if [[ ! -d '/csi' ]]; then
    csi_root=$(pwd)
  else
    csi_root='/csi'
  fi
else
  csi_root="${CSI_ROOT}"
fi

$screen_cmd "${apt} install -y rpm alien nsis openvas redis-server ${assess_update_errors}"
grok_error

sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo openvas-setup
sudo openvas-check-setup

# Add a working systemd daemon
sudo cp $csi_root/etc/systemd/openvas.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable openvas.service
sudo systemctl start openvas.service
# Symlink to folder containing NASL files
sudo ln -s /var/lib/openvas/plugins /opt/openvas_plugins
