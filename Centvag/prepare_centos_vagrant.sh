#For CentOS8 new installation with options - "server install"/"headless"/"kdump off"

echo Configuring vagrant user
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers
mkdir -p -m 0700 /home/vagrant/.ssh
curl https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
groupadd vagrant
useradd vagrant -g vagrant
chown -R vagrant:vagrant /home/vagrant

echo Configuring Linix
sed -i -e 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
sed -i -e 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
echo "blacklist i2c_piix4" >> /etc/modprobe.d/modprobe.conf
echo "blacklist intel_rapl" >> /etc/modprobe.d/modprobe.conf
sed -i -e 's/installonly_limit=5/installonly_limit=2/' /etc/yum.conf
sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i -e 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

echo Updating and cleaning linux
yum -y install yum-utils
yum -y update
package-cleanup -y --oldkernels --count=1
yum -y autoremove
yum clean all
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c