# install some pkgs
yum install -y bash-completion vim mlocate wget bind-utils net-tools nmap

# disable SElinux
sed -i 's/^\(SELINUX=\).*/\1disabled/' /etc/selinux/config
setenforce 0 | true
