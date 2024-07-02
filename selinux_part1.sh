#!/bin/bash

[[ $(id -u) -ne 0 ]] && echo "Скрипт требует запуска от имени администратора">&2

#install epel-release
yum install -y epel-release policycoreutils-python
#install nginx
yum install -y nginx
#change nginx port
sed -ie 's/:80/:4881/g' /etc/nginx/nginx.conf
sed -i 's/listen       80;/listen       4881;/' /etc/nginx/nginx.conf
#disable SELinux
#setenforce 0
#start nginx
systemctl start nginx
systemctl status nginx
#check nginx port
ss -tlpn | grep 4881

systemctl status firewalld && echo "Файрволл включён">&2

nginx -t || echo "Конфигурация nginx некорректна">&2
# Пропускаем в этом скриптке диагностику, сразу включаем параметр:
setsebool -P nis_enabled on
# И перезапускаем nginx
systemctl restart nginx
systemctl status nginx

# Убедившись, что всё работает, отключаем параметр:
setsebool -P nis_enabled off
# И перезапускаем nginx
systemctl restart nginx

# ищем типы для http-траффика:
semanage port -l | grep http
# Добавим наш порт
semanage port -a -t http_port_t -p tcp 4881
# И перезапускаем nginx
systemctl restart nginx
systemctl status nginx

# Убедившись, что всё работает, убираем порт:

semanage port -d -t http_port_t -p tcp 4881

# Создаём модуль для рабты nginx на нестандартном порту:

grep nginx /var/log/audit/audit.log | audit2allow -M nginx
# Применим модуль:
semodule -i nginx.pp
# И перезапускаем nginx
systemctl restart nginx
systemctl status nginx
# Удалим модуль
semodule -r nginx
# И перезапускаем nginx
systemctl restart nginx
systemctl status nginx