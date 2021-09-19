sudo snap install multipass
multipass launch -c 4 -m 4G -d 10G --name paperless
multipass shell paperless

sudo apt update
sudo apt install python3 python3-pip python3-dev imagemagick fonts-liberation optipng gnupg libpq-dev libmagic-dev mime-support -y
sudo apt install unpaper ghostscript icc-profiles-free qpdf liblept5 libxml2 pngquant zlib1g tesseract-ocr -y
sudo apt install redis-server -y
sudo sed -i 's/^supervised no$/supervised systemd/' /etc/redis/redis.conf
sudo systemctl restart redis.service
sudo apt install postgresql -y

sudo -u postgres psql -c "create database paperless"
sudo -u postgres psql -c "create user paperless with password 'paperless'"
sudo -u postgres psql -c "grant all privileges on database paperless to paperless"

wget  https://github.com/jonaswinkler/paperless-ng/releases/download/ng-1.5.0/paperless-ng-1.5.0.tar.xz

tar -xf paperless-ng-1.5.0.tar.xz
sudo mkdir /opt/paperless
sudo mv paperless-ng/* /opt/paperless/
sudo adduser paperless --system --home /opt/paperless --group
sudo chown -R paperless:paperless /opt/paperless

# set the config under paperless-ng/paperless.conf
sudo -Hu paperless vim /opt/paperless/paperless.conf

cd /opt/paperless
sudo -Hu paperless pip3 install --upgrade pip
sudo -Hu paperless pip3 install -r requirements.txt
sudo -Hu paperless mkdir media consume
cd src
sudo -Hu paperless python3 manage.py migrate
sudo -Hu paperless DJANGO_SUPERUSER_PASSWORD=paperless python3 manage.py createsuperuser --noinput --username paperless --email paperless@paperles.com

sudo cp /opt/paperless/scripts/*.service /etc/systemd/system/

sudo systemctl enable paperless-consumer.service
sudo systemctl enable paperless-scheduler.service
sudo systemctl enable paperless-webserver.service

sudo systemctl start paperless-consumer.service
sudo systemctl start paperless-scheduler.service
sudo systemctl start paperless-webserver.service

sudo apt install nginx -y
sudo vim /etc/nginx/sites-available/paperless
put
```
client_max_body_size 10M;
server {
    location / {
        # Adjust host and port as required.
        proxy_pass http://localhost:8000/;
        # These configuration options are required for WebSockets to work.
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $server_name;
    }
}
```
sudo ln -sf /etc/nginx/sites-available/paperless /etc/nginx/sites-enabled/default
sudo /usr/sbin/nginx -s reload

# more stuff

Add dependency on postgresql for the systemd init files

## Use imagemagick for pdf

do something like
sudo sed -i 's/^<policy domain="coder" rights="none" pattern="PDF" />$/<policy domain="coder" rights="read|write" pattern="PDF" />/' /etc/ImageMagick-6/policy.xml

## install jbig2
https://ocrmypdf.readthedocs.io/en/latest/jbig2.html