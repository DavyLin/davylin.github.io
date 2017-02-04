---
layout: post
title: "Mysql安装配置"
date: 2015-12-19 21:52:27 +0800
comments: true
tags: mysql database
categories: mysql
---

- 原来是rpm安装，检查并卸载

```
rpm -qa|grep -i mysql
rpm -ev MySQL-service-5.6.25-1.el7.x86_64
rpm -ev MySQL-client-5.6.25-1.el7.x86_64
```
- 原来是yum安装，检查并卸载
`rpm -qa|grep mysql` 

一般输出内容如下：

```
mysql-community-release-el7-5.noarch
mysql-community-client-5.7.7-0.3.rc.el7.x86_64
mysql-community-libs-5.7.7-0.3.rc.el7.x86_64
mysql-community-server-5.7.7-0.3.rc.el7.x86_64
mysql-community-common-5.7.7-0.3.rc.el7.x86_64
mysql-community-libs-compat-5.7.7-0.3.rc.el7.x86_64
```
执行卸载命令`yum remove mysql-community-release-el7-5.noarch`

####安装说明

**0、先建mysql用户,mysql组，然后执行命令安装mysql**

```
rpm -ivh MySQL-server-5.6.25-1.el7.x86_64.rpm
rpm -ivh MySQL-client-5.6.25-1.el7.x86_64.rpm
```

**1、你可以自己弄个`cnf`配置文件，里面配置改好，命名随便，比如`my_3306.cnf`**

**2、mysql的目录配置好，`cnf`放到目录下**

**3、进行初始化`mysql_install_db`命令初始化**

**4、`mysqld_safe`启动mysql**

####安装详细步骤

**0、执行命令安装mysql（见上面安装说明）**
**1、配置my.cnf文件**

一般我会安装在`/data/mysql/3306/my_3306.cnf`这个位置

**2、安装目录初始化**

`mysql_install_db --user=mysql --basedir=/usr --datadir=/data/mysql/3306/data --defaults-extra-file=/data/mysql/3306/my_3306.cnf`

**3、启动服务**

`mysqld_safe --defaults-extra-file=/data/mysql/3306/my_3306.cnf &`

**4、停止服务**

`mysqladmin -uroot -p -S /data/mysql/3306/mysql_3306.sock shutdown`

#### 配置数据账户：

**1.mysql -uroot -h127.0.0.1 -P3306**

**2.修改密码 set password=PASSWORD('root');**

**3. 增加账号**

```
grant all on *.* to 'davylin'@'%' identified by 'davylin';

flush privileges; 
```

#### 停止服务

`mysqladmin -uroot -p -S /data/mysql/3306/mysql_3306.sock shutdown`


#### 开机自动启动（rc.local方式）

`vi /etc/rc.d/rc.local`最后一行增加

`export JAVA_HOME=/opt/jdk1.7.0_79` // 需要依赖jdk的服务，比如tomcat

`mysqld_safe --defaults-extra-file=/data/mysql/3306/my_3306.cnf &`