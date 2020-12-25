---
title: "Setting up Visual Studio Code Server "
author: Kai Du
date: 21/12/2020
---

> This blog will explain how to set up a visual studio code server in an AWS instance (Ubuntu 18.04). The steps mentioned here are basically the commands I executed in my instance (launched using ami-0dba2cb6798deb6d8 64-bit x86) with security group rules allowing port 22,80 and 443 for all.

**Step1:** sudo apt update
**Step2:** wget https://github.com/cdr/code-server/releases/download/3.4.1/code-server-3.4.1-linux-x86_64.tar.gz
**Step3:** tar xvzf code-server-3.4.1-linux-x86_64.tar.gz
**Step4:** sudo mkdir -p ~/.config/code-server
**Step5:** sudo nano ~/.config/code-server/config.yaml
- - ->sudo cat ~/.config/code-server/config.yaml

Output: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bind-addr: 127.0.0.1:8080
auth: password            
password: Test1234         
cert: false
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Step6:** cd ~/code-server-3.4.1-linux-x86_64/bin
**Step7:** ./code-server

Output:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
info  Using config file ~/.config/code-server/config.yaml
info  Using user-data-dir ~/.local/share/code-server
info  code-server 3.4.1 48f7c2724827e526eeaa6c2c151c520f48a61259
info  HTTP server listening on http://127.0.0.1:8080
info      - Using password from ~/.config/code-server/config.yaml
info      - To disable use `--auth none`
info    - Not serving HTTPS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[Ctrl+C to stope this service]

**Step8:** sudo nano /lib/systemd/system/code-server.service
- - -> sudo cat /lib/systemd/system/code-server.service

Output:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[Unit]
Description=code-server
After=nginx.service

[Service]
Type=simple
Environment=PASSWORD=Test1234
ExecStart=/home/ubuntu/code-server-3.4.1-linux-x86_64/bin/code-server --bind-addr 127.0.0.1:8080 --user-data-dir /var/lib/code-server --auth password
Restart=always

[Install]
WantedBy=multi-user.target
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Step9:** sudo mkdir /var/lib/code-server
**Step10:** sudo systemctl daemon-reload
**Step11:** sudo systemctl start code-server
**Step12:** sudo systemctl enable code-server

Output:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Created symlink /etc/systemd/system/multi-user.target.wants/code-server.service → /lib/systemd/system/code-server.service.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Step13:** sudo systemctl status code-server

Output:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
● code-server.service - code-server
     Loaded: loaded (/lib/systemd/system/code-server.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2020-10-07 03:06:01 UTC; 22s ago
   Main PID: 2209 (node)
      Tasks: 22 (limit: 1164)
     Memory: 23.8M
     CGroup: /system.slice/code-server.service
             ├─2209 /home/ubuntu/code-server-3.4.1-linux-x86_64/lib/node /home/ubuntu/code-server-3.4.1-linux-x86_64 --bind-addr 127.0.0.1:8080 --user-data-d>
             └─2237 /home/ubuntu/code-server-3.4.1-linux-x86_64/lib/node /home/ubuntu/code-server-3.4.1-linux-x86_64 --bind-addr 127.0.0.1:8080 --user-data-d>

Oct 07 03:06:01 ip-172-31-18-5 systemd[1]: Started code-server.
Oct 07 03:06:01 ip-172-31-18-5 code-server[2209]: info  Wrote default config file to ~/.config/code-server/config.yaml
Oct 07 03:06:01 ip-172-31-18-5 code-server[2209]: info  Using config file ~/.config/code-server/config.yaml
Oct 07 03:06:01 ip-172-31-18-5 code-server[2237]: info  Using user-data-dir /var/lib/code-server
Oct 07 03:06:01 ip-172-31-18-5 code-server[2237]: info  code-server 3.4.1 48f7c2724827e526eeaa6c2c151c520f48a61259
Oct 07 03:06:01 ip-172-31-18-5 code-server[2237]: info  HTTP server listening on http://127.0.0.1:8080
Oct 07 03:06:01 ip-172-31-18-5 code-server[2237]: info      - Using password from $PASSWORD
Oct 07 03:06:01 ip-172-31-18-5 code-server[2237]: info      - To disable use `--auth none`
Oct 07 03:06:01 ip-172-31-18-5 code-server[2237]: info    - Not serving HTTPS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Step14:** sudo apt install nginx -y
**Step15:** sudo nano /etc/nginx/sites-available/code-server.conf
- - - ->sudo cat /etc/nginx/sites-available/code-server.conf

Output:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
server {
   listen 80;
   listen [::]:80;
   server_name 54.XXX.XX.253;
   location / {
      proxy_pass http://localhost:8080/;
      proxy_set_header Host $host;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection upgrade; 
      proxy_set_header Accept-Encoding gzip;
   }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[ *NOTE:* Remember to change “54.XXX.XX.253” to the public IP of your instance ]

**Step16:** cd /etc/nginx/sites-available/
**Step17:** (OPTIONAL) sudo mv default BackUp_default
**Step18:** sudo rm /etc/nginx/sites-enabled/default
**Step19:** sudo ln -s /etc/nginx/sites-available/code-server.conf /etc/nginx/sites-enabled/code-server.conf
**Step20:** sudo systemctl start nginx
**Step21:** sudo systemctl enable nginx


Output:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Synchronizing state of nginx.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable nginx
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Step22:** sudo systemctl status nginx

Output:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2020-10-07 03:06:47 UTC; 3min 12s ago
       Docs: man:nginx(8)
   Main PID: 2696 (nginx)
      Tasks: 2 (limit: 1164)
     Memory: 6.6M
     CGroup: /system.slice/nginx.service
             ├─2696 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             └─2697 nginx: worker process

Oct 07 03:06:46 ip-172-31-18-5 systemd[1]: Starting A high performance web server and a reverse proxy server...
Oct 07 03:06:47 ip-172-31-18-5 systemd[1]: Started A high performance web server and a reverse proxy server.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Step23:** sudo systemctl daemon-reload
**Step24:** Refresh  both the services by starting and stopping them. You can follow the below commands in order:-
sudo systemctl stop nginx
sudo systemctl stop code-server
sudo systemctl daemon-reload
sudo systemctl start code-server
sudo systemctl start nginx
sudo systemctl enable code-server
sudo systemctl enable nginx
sudo systemctl status nginx <=== To check if nginx is running
sudo systemctl status code-server <=== To check if the code-server is active

**Step25:** Open browser and try accessing the Public IP of the instance

*Then*, the VS code server should work now. 
