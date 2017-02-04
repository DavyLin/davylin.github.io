---
layout: post
title: "centos vsftpd的安装配置"
date: 2015-12-19 21:53:07 +0800
comments: true
tags: vsftpd centos
categories: linux
---

**1. yum install vsftpd**

**2. 配置/etc/vsftpd/vsftpd.conf**

- 配置参考如下：

```
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
ascii_upload_enable=YES
ascii_download_enable=YES
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
use_localtime=YES
allow_writeable_chroot=YES
```

**3. 配置iptables策略，开放 20，21，22等端口，默认21**

**4. systemctl start vsftpd.service**


