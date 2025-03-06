# Systemd

# Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова
Для начала создаём файл с конфигурацией для сервиса в директории /etc/default - из неё сервис будет брать необходимые переменные.

/etc/default/watcher.conf
Затем создаем /var/log/test.log и пишем туда строки на своё усмотрение,
плюс ключевое слово ‘ALERT’
Скрипт - /opt/watcher.sh
Делаем файл исполняемым - chmod +x /opt/watcher.sh
Юнит для сервиса - /etc/systemd/system/watcher.service
Юнит для таймера - /etc/systemd/system/watchler.timer

Включаем автозапуск сервиса и стартуем

```bash
systemctl daemon-reload
systemctl enable watcher.service watcher.timer
systemctl start watcher.service watcher.timer
```
Итог:

```bash
vagrant@boot:~$ sudo tail -n 1000 /var/log/syslog | grep monday
Mar  6 19:07:18 ubuntu2204 root: ======> oh,monday <======
Mar  6 19:07:48 ubuntu2204 root: ======> oh,monday <======
Mar  6 19:08:18 ubuntu2204 root: ======> oh,monday <======
Mar  6 19:08:48 ubuntu2204 root: ======> oh,monday <======
Mar  6 19:09:18 ubuntu2204 root: ======> oh,monday <======
Mar  6 19:09:49 ubuntu2204 root: ======> oh,monday <======
Mar  6 19:10:11 ubuntu2204 root: ======> oh,monday <======
vagrant@boot:~$ 
```

### Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта

Устанавливаем spawn-fcgi и необходимые для него пакеты:
```bash
vagrant@boot:~$ apt install spawn-fcgi php php-cgi php-cli \
 apache2 libapache2-mod-fcgid -y
```
Файл с настройками для будущего сервиса в файле /etc/spawn-fcgi/fcgi.conf.
Юнит-файл - /etc/systemd/system/spawn-fcgi.service

Проверяем

```bash
vagrant@boot:~$ systemctl status spawn-fcgi
vagrant@boot:~$ systemctl status spawn-fcgi
vagrant@boot:~$ sudo systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: enabled)
     Active: active (running) since Thu 2025-03-06 19:32:37 UTC; 7s ago
   Main PID: 14312 (php-cgi)
      Tasks: 33 (limit: 710)
     Memory: 20.1M
        CPU: 242ms
     CGroup: /system.slice/spawn-fcgi.service
             ├─14312 /usr/bin/php-cgi
             ├─14313 /usr/bin/php-cgi
             ├─14314 /usr/bin/php-cgi
             ├─14315 /usr/bin/php-cgi
             ├─14316 /usr/bin/php-cgi
             ├─14317 /usr/bin/php-cgi
             ├─14318 /usr/bin/php-cgi
             ├─14319 /usr/bin/php-cgi
             ├─14320 /usr/bin/php-cgi
             ├─14321 /usr/bin/php-cgi
             ├─14322 /usr/bin/php-cgi
             ├─14323 /usr/bin/php-cgi
             ├─14324 /usr/bin/php-cgi
             ├─14325 /usr/bin/php-cgi
             ├─14326 /usr/bin/php-cgi
             ├─14327 /usr/bin/php-cgi
             ├─14328 /usr/bin/php-cgi
             ├─14329 /usr/bin/php-cgi
             ├─14330 /usr/bin/php-cgi
             ├─14331 /usr/bin/php-cgi
             ├─14332 /usr/bin/php-cgi
             ├─14333 /usr/bin/php-cgi
             ├─14334 /usr/bin/php-cgi
             ├─14335 /usr/bin/php-cgi
             ├─14336 /usr/bin/php-cgi
             ├─14337 /usr/bin/php-cgi
             ├─14338 /usr/bin/php-cgi
             ├─14339 /usr/bin/php-cgi
             ├─14340 /usr/bin/php-cgi
             ├─14341 /usr/bin/php-cgi
             ├─14342 /usr/bin/php-cgi
             ├─14343 /usr/bin/php-cgi
             └─14344 /usr/bin/php-cgi

Mar 06 19:32:37 boot systemd[1]: Started Spawn-fcgi startup service by Otus.
lines 26-43/43 (END)


```

### Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно

Установим Nginx из стандартного репозитория:

[root@host ~#] apt install nginx -y

```bash
vagrant@boot:~$ apt install nginx -y
```

Отличия в конфигурациях сделал самое - порт у копий.
Новый Unit для работы с шаблонами /etc/systemd/system/nginx@.service
```bash
vagrant@boot:~$  systemctl start nginx@first
vagrant@boot:~$  systemctl start nginx@second
vagrant@boot:~$  systemctl status nginx@second
```
Проверяем.

```bash
vagrant@boot:~$ ps afx | grep nginx
...
  15605 ?        S      0:00  \_ nginx: worker process
  16063 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;
  16064 ?        S      0:00  \_ nginx: worker process
  16074 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on;
  16075 ?        S      0:00  \_ nginx: worker process
vagrant@boot:~$ ss -tnulp | grep 900
tcp   LISTEN 0      511           0.0.0.0:9001      0.0.0.0:*          
tcp   LISTEN 0      511           0.0.0.0:9002      0.0.0.0:*          
vagrant@boot:~$ 


```

