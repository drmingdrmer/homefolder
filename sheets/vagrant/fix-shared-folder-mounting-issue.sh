
yum update -y
yum install kernel-devel-$(uname -r) kernel-headers-$(uname -r) dkms -y
/etc/init.d/vboxadd setup

# If got OpenGL failed issue:

cd /usr/src/kernels/2.6.32-431.3.1.el6.x86_64/include/drm

ln -s /usr/include/drm/drm.h drm.h
ln -s /usr/include/drm/drm_sarea.h drm_sarea.h
ln -s /usr/include/drm/drm_mode.h drm_mode.h
ln -s /usr/include/drm/drm_fourcc.h drm_fourcc.h


# manually install or reboot vagrant

sudo mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant

