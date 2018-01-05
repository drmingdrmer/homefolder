To install gcc 4.9 on centos:

```sh
yum install centos-release-scl-rh -y
yum install devtoolset-3-gcc -y

```

To use gcc-4.9 in devtoolset-3, start a new bash with devtoolset-3 enabled:

```sh
scl enable devtoolset-3 bash
```

To enable devtoolset-3 for ever, add the following line into `.bashrc`:

```sh
source /opt/rh/devtoolset-3/enable
```
