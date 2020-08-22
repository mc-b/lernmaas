#!/bin/bash
#
#   Installiert den Gnome Desktop und stellt diesen via VNC zur Verfuegung

sudo apt-get install -y --no-install-recommends ubuntu-desktop gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal tightvncserver firefox

mkdir Desktop Downloads .vnc

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
nautilus &     
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
