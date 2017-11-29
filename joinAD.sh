#!/bin/bash
# Credit: this script was originally written by user bjh7242 on Github.
# It was first used by the NECCDC black team to set up the competition network.
# Link: github.com/bjh7242/NECCDC-2017-Configs/blob/master/ansible/corp/playbooks/scripts/join.sh
# I modified the script to work on UMCST's network.

# Prerequisite: configure /etc/resolv.conf - set AD DC in nameserver and domain in search.
# Set the WORKGROUP and DOMAIN variables to desired values
# Set the admin username (ADMIN_USERNAME) with the correct value. You will have to enter the password later
# Run this script with sudo!
# dialog box: default Kerberos Realm: domain name in all caps with ending.
# To confirm connected to domain: wbinfo -u

WORKGROUP="HONEYPAQ"
DOMAIN="HONEYPAQ.COM"
ADMIN_USERNAME="queenbee"

# Install dependencies (-y for auto 'yes').
apt-get install winbind samba smbclient krb5-user libpam-winbind libnss-winbind -y

# Modify smb.conf: configure for auth to our domain.
cat <<EOF > /etc/samba/smb.conf
[global]
    workgroup = $WORKGROUP
    security = ads
    realm = $DOMAIN
    domain master = no
    local master = no
    preferred master = no
    idmap backend = tdb
    idmap uid = 10000-99999
    idmap gid = 10000-99999
    winbind enum users = yes
    winbind enum groups = yes
    winbind use default domain = yes
    winbind nested groups = yes
    winbind refresh tickets = yes
    template homedir = /home/%D/%U
    template shell = /bin/bash
    client use spnego = yes
    client ntlmv2 auth = yes
    encrypt passwords = yes
    restrict anonymous = 2
    log file = /var/log/samba/log.%m
    max log size = 50
    winbind offline logon = true
EOF

# Join the server to the domain (will query for pass)
net ads join -U $ADMIN_USERNAME

# Update pam to enable Windows authentication. 
pam-auth-update
# Edit config files for authentication.
sed -i 's/passwd.*/passwd:         compat winbind/g' /etc/nsswitch.conf
sed -i 's/group.*/group:          compat winbind/g' /etc/nsswitch.conf
sed -i 's/shadow.*/shadow:         compat winbind/g' /etc/nsswitch.conf
echo "session required			pam_mkhomedir.so skel=/etc/skel umask=0022" >> /etc/pam.d/common-account

#Make sure all the changes are reflected by services
systemctl restart smbd
systemctl enable smbd
systemctl start winbind
systemctl enable winbind

#Create home directories for all users. Don't seem to be created automatically?
for i in $( wbinfo -u ); do
	mkdir -p /home/$WORKGROUP/$i
	chown -R /home/$WORKGROUP/$i $i
done


echo 'Done!'
