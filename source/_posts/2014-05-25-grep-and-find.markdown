---
layout: post
title: "grep and find"
date: 2014-05-25 17:54:49 +0800
comments: true
tags: linux shell
categories: linux
---

##grep
###1.从文件中查找关键词
**grep 'linux' text.txt //查找包含 linux的关键词**

```
[root@localhost ~]# grep 'root' /etc/group
root:x:0:root
bin:x:1:root,bin,daemon
```

###2.从多个文件中查找关键词
```
[root@localhost ~]# grep 'root' /etc/group /etc/my.cnf
/etc/group:root:x:0:root
/etc/my.cnf:user = root
```

###3.查找当前目录下以及下辖子目录下所有包含str字符串的文件,会列出文件名.以及该行的内容.以及行号  

**-n是打印行号，-r是在子目录也要查询**

```
grep -n "str" -r ./
```
**用 -i 搜索的时候可以忽略大小写**

**利用 -r 来完成所有的子目录下面执行相应的查找**

**用-l是打印所有的结果**

```
grep -ril 'str' ./
```

##find 是查找文件的常用命令


###1.查找在 /etc 目录下所有文件名中含有 mail 的文件
```
[root@localhost ]# find /etc/ -name '*mail*'
/etc/mail.rc
/etc/rc.d/rc5.d/K30sendmail
/etc/rc.d/rc4.d/K30sendmail
```
###2.查找文件大小超过指定值的文件
```
[root@localhost ]# find ./ -type f -size +100M
./test.sql
```
###3.最近几天被修改过的文件
```
find . -mtime -2 
```
