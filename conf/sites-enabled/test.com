     server {    listen      80;
                server_name *.test.com;
                root        /var/www/test.com/www/;
                index index.html index.php;

                access_log /var/log/nginx/www.test.com.access_log;
                error_log /var/log/nginx/www.test.com.error_log;

                location / {
                        try_files $uri $uri/ @handler;
                        expires 30d;
                }
                location  /. {
                        return 404;
                }

                location @handler {
                        rewrite / /index.php;
                }

                location ~ .php/ {
                        rewrite ^(.*.php)/ $1 last;
                }

                location ~ \.php$ {
                        try_files $uri =404;
                        expires off;
                        fastcgi_read_timeout 900s;
                        fastcgi_index index.php;
                        fastcgi_pass 127.0.0.1:9000;
                        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                        include /etc/tengine/fastcgi_params;
                }
                gzip on;
                #gzip_comp_level 9;
                gzip_min_length  1000;
                gzip_proxied any;
                gzip_types       text/plain application/xml  text/css text/js application/x-javascript;
        }
