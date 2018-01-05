测试用虚拟机
在 172.18.28.53 物理机上创建不同的虚拟机供测试用。

虚拟机 IP 地址
CentOS Version
172.18.28.224   CentOS 7.4
172.18.28.225   CentOS 7.0
172.18.28.226   CentOS 7.1
172.18.28.227   CentOS 7.2
172.18.28.228   CentOS 7.3

创建虚拟机的方法
所有虚拟机root密码为passw0rd，虚拟机生成后自己更改。

```sh
$ yum install -y qemu-kvm*
 
$ cd /opt/kvm-virt-repo/
 
$ bash quickboot-vm.sh
Usage: quickboot-vm.sh <vmtmpl> <vmname> <vmip>
# vmtmp: 虚拟机模板
# vmname: 虚拟机名字
# vmip: 虚拟机 IP
 
# 可用的模板
$ ls templates
centos-7.0-x64.raw
centos-7.1-x64.raw
centos-7.2-x64.raw
centos-7.3-x64.raw
centos-7.4-x64.raw
 
# 创建 CentOS 7.4 虚拟机，自动生成一个 2 核 4G 内存 20G 硬盘 的虚拟机
$ bash quickboot-vm.sh centos-7.4-x64 test-vm 172.18.28.229
 
# 删掉清除虚拟机
$ bash destroy-vm.sh test-vm
```

为了防止 IP 地址冲突，可用的 IP 地址为 172.18.28.223-253
建议虚拟机名字后面加上 IP 地址末位用以标识。 如： test-vm-229
如果需要按需指定配置大小，请直接使用 `deploy-vm-centos7.py` 脚本。
查看物理机上所有的虚拟机

```sh
$ virsh list --all
Id Name State
----------------------------------------------------
28 test74-224 running
33 test70-225 running
34 test71-226 running
35 test72-227 running
37 test73-228 running
- centos-7.0-x64 shut off # 模板
- centos-7.1-x64 shut off # 模板
- centos-7.2-x64 shut off # 模板
- centos-7.3-x64 shut off # 模板
- centos-7.4-x64 shut off # 模板
```
