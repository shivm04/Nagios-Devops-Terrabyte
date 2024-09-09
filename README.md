# Nagios Installation Guide for Ubuntu

## Step 1: Update and Upgrade the System
   ```
     sudo apt update && apt upgrade -y
   ```

## Step 2: Install Required Dependencies
   ```
   sudo apt install autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev libmcrypt-dev libssl-dev bc gawk dc build-essential snmp libnet-snmp-perl gettext
   ```

## Step 3: Create Nagios User and Groups 
   ```
      sudo useradd -m -s /bin/bash nagios
      sudo groupadd nagcmd
      sudo usermod -a -G nagcmd nagios
      sudo usermod -a -G nagcmd www-data
   ```

## Step 4: Download and Extract Nagios
   ```
      cd /tmp
      wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
      tar -zxvf nagios-4.4.6.tar.gz
      cd nagios-4.4.6
   ```

## Step 5: Compile and Install Nagios
```
      ./configure --with-nagios-group=nagios --with-command-group=nagcmd
       make all
       sudo make install
       sudo make install-commandmode
       sudo make install-init
       sudo make install-config
       sudo /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf
```

## Step 6: Install Nagios Plugins
   
       sudo apt update
       sudo apt install nagios-plugins
       cp /usr/lib/nagios/plugins/* /usr/local/nagios/libexec/


## Step 7: Verify Nagios Configuration
   ```
       sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
   ```

## Step 8: Restart Nagios and Apache Services
   ```
      sudo systemctl restart nagios
      sudo systemctl restart apache2
   ```

## Step 9: Enable Nagios in Apache
   ```
      sudo ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/
      sudo a2enmod cgi rewrite
   ```

## Step 10: Set up Nagios Admin User
   ```
      sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
   ```

## Step 11: Enable Nagios and Apache to Start on Boot
   ```
      sudo systemctl enable nagios
      sudo systemctl enable apache2
   ```

## Step 12: Final Restart of Nagios and Apache
    
      sudo systemctl restart nagios
      sudo systemctl restart apache2
    
