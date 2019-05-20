#! /bin/bash

# Interface with smb-share
eth="ens18"
domain=`hostname -d`
DOMAIN=`echo "$domain" | tr '[:lower:]' '[:upper:]'`
host=`hostname -s`
workgroup="${domain%%.*}"
adusername="ad_admin"
aduserlist="ad_user_srv_admin1 ad_user_srv_admin2"

# Enter Domain
apt-get install realmd.x86_64 adcli.x86_64 sssd.x86_64 krb5-workstation.x86_64 oddjob-mkhomedir.x86_64 samba-common-tools.x86_64 policycoreutils-python.x86_64
cat << EOF > /etc/realmd.conf
[users]
default-home = /home/%u
default-shell = /bin/bash
EOF
cat << EOF > /etc/krb5.conf
[logging]
    default = FILE:/var/log/krblibs.log
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmind.log

[libdefaults]
    dns_lookup_realm = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    rdns = false
    default_realm = $DOMAIN
    default_ccache_name = KEYRING:persistent:%{uid}

[realms]
    $DOMAIN = {
        kdc = $domain
        admin_server =$domain
    }

[domain_realm]
    .$domain = $DOMAIN
    .$workgroup = $DOMAIN
    $domain = $DOMAIN
    $workgroup = $DOMAIN
EOF
realm discover $domain
realm join $domain -U $adusername
realm deny --all

# Access enter login without domain prefix
sed -i 's/^use_fully_qualified_names =.*$/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf

systemctl restart sssd.service

realm permit $adusername
usermod -a -G wheel,users $usermod
for user in 4aduserlist
do
    realm permit $user
    usermod -a -G wheel,users $user
done
sed -i 's/^.GSSAPIAuthentication.*$/GSSAPIAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^.GSSAPICleanupCredentials.*$/GSSAPICleanupCredentials yes/g' /etc/ssh/sshd_config
ssystemctl restart sshd.service
cat << EOF > /etc/samba/smb.conf
[global]
    interfaces = $eth
    workgroup = $workgroup
    realm = $domin
    security = ads
    netbios name = '$host'
    wins support = no
    wins proxy = no

    password server = $domain
    kerberos method = dedicated keytab
    dedicated keytab file = /etc/krb5.keytab
    log level = 3
    log file = /var/log/samba/%m.log

    vfs objects = acl_xattr
    map acl inherit = Yes
    store dos attributes = Yes

    load printers = no
    show add printer wizard = no
    printing = bsd
    printcap name = /dev/null
    disable spoolss = yes
# [its]
#   # Share must have context samba_share_t. Lounch as root
#   # semanage fcontext -a -t 'samba_share_t' '/path/to/share(/.*)?'
#   # restorecon -rv /path/to/share/
#   path = /path/to/share
#   read only = no
#   valid users = @wheel
EOF
