#!/bin/bash
#
#   Installiert den Gnome Desktop und stellt diesen via VNC zur Verfuegung
#
#   braucht ca. 1.2 GB HD 

sudo apt-get install -y --no-install-recommends ubuntu-desktop gnome-panel gnome-settings-daemon metacity gnome-terminal tightvncserver firefox gedit gitg nemo

# nemo als Default File Explorer
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
gsettings set org.gnome.desktop.background show-desktop-icons false

# nemo Templates
mkdir Templates
cat <<%EOF% >>Templates/README.md
# Titel 1
## Titel 2

![Markdown Demo](https://markdown-it.github.io/)

%EOF%

cat <<%EOF% >>Templates/Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"

  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # config.vm.network "private_network", ip: "192.168.33.10"

  # Enable provisioning with a shell script. 
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end

%EOF%

cat <<%EOF% >>Templates/Dockerfile
FROM alpine:latest
CMD "echo" "hello world"
%EOF%

cd $HOME
mkdir Desktop Downloads .vnc

if [ -f .ssh/passwd ]
then
    vncpasswd -f <<<$(cat .ssh/passwd) >.vnc/passwd
else
    vncpasswd -f <<<$(echo password) >.vnc/passwd
fi    
chmod 600 .vnc/passwd

# X11 Startup

cat <<%EOF% >~/.vnc/xstartup
#!/bin/sh
export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

xsetroot -solid grey

gnome-panel &
gnome-settings-daemon &
metacity &
nemo &   
gitg &  
%EOF%

chmod 755 .vnc/xstartup

# VNC Server als Service
cat <<%EOF% | sudo tee /etc/systemd/system/vncserver@.service
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu

PIDFile=/home/ubuntu/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 16 -geometry 1920x1024 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target  
%EOF%

sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1
