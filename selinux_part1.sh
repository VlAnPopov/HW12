#!/bin/bash

[[ $(id -u) -ne 0 ]] && echo "Скрипт требует запуска от имени администратора">&2

sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo

#install epel-release
yum install -y epel-release
yum install -y policycoreutils-python
#install nginx
yum install -y nginx
#change nginx port
sed -ie 's/:80/:4881/g' /etc/nginx/nginx.conf
sed -i 's/listen       80;/listen       4881;/' /etc/nginx/nginx.conf
#disable SELinux
#setenforce 0
#start nginx
systemctl start nginx
echo "Проверяем статус nginx - работать не должен"
systemctl status nginx
#check nginx port
ss -tlpn | grep 4881

systemctl status firewalld && echo "Файрволл включён">&2

nginx -t || echo "Конфигурация nginx некорректна">&2
echo "Пропускаем в этом скриптке диагностику, сразу включаем параметр"
setsebool -P nis_enabled on
echo "Перезапускаем nginx"
systemctl restart nginx
echo "Проверяем статус nginx - работать должен (реализовали первый способ)"
systemctl status nginx

echo "Убедившись, что всё работает, отключаем параметр"
setsebool -P nis_enabled off
echo "перезапускаем nginx"
systemctl restart nginx
echo "Проверяем статус nginx - работать не должен"
systemctl status nginx
echo "ищем типы для http-траффика"
semanage port -l | grep http
echo "Добавим наш порт"
semanage port -a -t http_port_t -p tcp 4881
echo "перезапускаем nginx"
systemctl restart nginx
echo "Проверяем статус nginx - работать должен (реализовали второй способ)"
systemctl status nginx

echo "Убедившись, что всё работает, убираем порт"

semanage port -d -t http_port_t -p tcp 4881

echo "Создаём модуль для рабты nginx на нестандартном порту"

grep nginx /var/log/audit/audit.log | audit2allow -M nginx
echo "Применим модуль:"
semodule -i nginx.pp
echo "перезапускаем nginx"
systemctl restart nginx
echo "Проверяем статус nginx - работать должен (реализовали третий способ)"
systemctl status nginx
echo "Удалим модуль"
semodule -r nginx
echo "И перезапускаем nginx"
systemctl restart nginx
echo "Проверяем статус nginx - работать не должен"
systemctl status nginx