#Install the NRPE on remote server and main nagios server

## Update the system
```
sudo apt update && sudo apt upgrade -y
```

## Install the NRPE agent on the remote server 
```
sudo apt install nagios-nrpe-server nagios-plugins nagios-nrpe-plugin
```

## Configuration file changes 
```
sudo vi /etc/nagios/nrpe.cfg
```

## Restart the NRPE service 
```
sudo systemctl restart nagios-nrpe-server
```


## Below steps are to execute on the Main nagios server 

## Move NRPE Plugin to the nagios libxec directory  
```
cd /usr/lib/nagios/plugins
cp check_nrpe /usr/local/nagios/libexec/
```

## Testing the nrpe agent 
```
./check_nrpe -H remote server IP
```


## Add the servers directory in the nagios configuration file so nagios will read the content 
```
mkdir -p /usr/local/nagios/etc/servers
sudo vi /usr/local/nagios/etc/nagios.cfg

Add the below content on line 30 in file 
cfg_dir=/usr/local/nagios/etc/servers/

## Create a remote server monitoring configuration file on main nagios server
```
cd /usr/local/nagios/etc/servers
vi remote-server.cfg

Add the below content in file , change the remote server IP

define host {

    use                     linux-server            ; Name of host template to use
                                                    ; This host definition will inherit all variables that are defined
                                                    ; in (or inherited by) the linux-server host template definition.
    host_name               remote-server
    alias                   remote-server
    address                 10.0.0.1
    contact_groups          admins
    notifications_enabled   1
    max_check_attempts      5
    check_period            24x7
    notification_interval   15
    notification_period     24x7

}



# Define a service to "ping" the remote machine

define service {

    use                     generic-service     ; Name of service template to use
    host_name               remote-server
    service_description     PING
    check_command           check_ping!100.0,20%!500.0,60%
}

# Define a service to check the disk space of the root partition
# on the remote machine.  Warning if < 20% free, critical if
# < 10% free space on partition.

define service {

    use                     generic-service           ; Name of service template to use
    host_name               remote-server
    service_description     Root Partition
    check_command           check_nrpe!check_disk
}

# Define a service to check the number of currently logged in
# users on the remote machine.  Warning if > 20 users, critical
# if > 50 users.

define service {

    use                     generic-service           ; Name of service template to use
    host_name               remote-server
    service_description     Current Users
    check_command           check_nrpe!check_users
}

# Define a service to check the number of currently running procs
# on the remote machine.  Warning if > 250 processes, critical if
# > 400 processes.

define service {

    use                     generic-service           ; Name of service template to use
    host_name               remote-server
    service_description     Total Processes
    check_command           check_nrpe!check_total_procs
}

# Define a service to check the load on the remote machine.

define service {

    use                     generic-service           ; Name of service template to use
    host_name               remote-server
    service_description     Current Load
    check_command           check_nrpe!check_load
}


# Define a service to check SSH on the remote machine.
# Disable notifications for this service by default, as not all users may have SSH enabled.

define service {

    use                     generic-service           ; Name of service template to use
    host_name               remote-server
    service_description     SSH
    check_command           check_nrpe!check_ssh
    notifications_enabled   1
}

# Define a service to check HTTP on the remote machine.
# Disable notifications for this service by default, as not all users may have HTTP enabled.

define service {

    use                     generic-service           ; Name of service template to use
    host_name               remote-server
    service_description     HTTP
    check_command           check_tcp!80
    notifications_enabled   1
}

#define service {

#    use                     generic-service           ; Name of service template to use
#    host_name               remote-server
#    service_description     check jenkins service
#    check_command           check_nrpe!check_jenkins_status
#    notifications_enabled   1
#}

```

### Once the file is added then check the nagios config valid or not 
```
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

## Restart the nagios server 
```
sudo systemctl restart nagios
```
