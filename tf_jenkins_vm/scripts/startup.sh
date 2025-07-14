# Define un marcador para saber si el script ya se ejecutó
MARKER_FILE="/var/lib/google/startup-script-executed"

# Verifica si el marcador existe
if [ -f "$MARKER_FILE" ]; then
    echo "Script de inicio ya ejecutado. Saliendo."
    exit 0
fi

echo "Ejecutando script de inicio por primera vez..."

#sources for gcloud y docker
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
## apt install 
sudo apt update 
sudo apt upgrade -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin iputils-ping iputils-ping telnet apt-transport-https ca-certificates gnupg curl google-cloud-cli kubectl google-cloud-sdk-gke-gcloud-auth-plugin ca-certificates curl bash-completion vim fontconfig openjdk-21-jdk jenkins nginx
#snap certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx --non-interactive --agree-tos --domains ${domain} --email carlosmarind@gmail.com

#configuracion host
sudo usermod -aG sudo,docker jenkins
echo "jenkins:${password}" | sudo chpasswd;
sudo echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
sudo rm /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
sudo systemctl restart jenkins
sudo systemctl restart sshd

# --- Script de configuración de Nginx ---
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
upstream jenkins {
  keepalive 32; # keepalive connections
  server 127.0.0.1:8080; # jenkins ip and port
}

# Required for Jenkins websocket agents
map \$http_upgrade \$connection_upgrade {
  default upgrade;
  '' close;
}

server {

 server_name ${domain}; # managed by Certbot

  # this is the jenkins web root directory
  # (mentioned in the output of "systemctl cat jenkins")
  root            /var/run/jenkins/war/;

  access_log      /var/log/nginx/jenkins.access.log;
  error_log       /var/log/nginx/jenkins.error.log;

  # pass through headers from Jenkins that Nginx considers invalid
  ignore_invalid_headers off;

  location ~ "^/static/[0-9a-fA-F]{8}\/(.*)$" {
    # rewrite all static files into requests to the root
    # E.g /static/12345678/css/something.css will become /css/something.css
    rewrite "^/static/[0-9a-fA-F]{8}\/(.*)" /\$1 last;
  }

  location /userContent {
    # have nginx handle all the static requests to userContent folder
    # note : This is the \$JENKINS_HOME dir
    root /var/lib/jenkins/;
    if (!-f \$request_filename){
      # this file does not exist, might be a directory or a /**view** url
      rewrite (.*) /\$1 last;
      break;
    }
    sendfile on;
  }

  location / {
      sendfile off;
      proxy_pass         http://jenkins;
      proxy_redirect     default;
      proxy_http_version 1.1;

      # Required for Jenkins websocket agents
      proxy_set_header   Connection        \$connection_upgrade;
      proxy_set_header   Upgrade           \$http_upgrade;

      proxy_set_header   Host              \$http_host;
      proxy_set_header   X-Real-IP         \$remote_addr;
      proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Proto \$scheme;
      proxy_max_temp_file_size 0;

      #this is the maximum upload size
      client_max_body_size       10m;
      client_body_buffer_size    128k;

      proxy_connect_timeout      90;
      proxy_send_timeout         90;
      proxy_read_timeout         90;
      proxy_request_buffering    off; # Required for HTTP CLI commands
  }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
    if (\$host = ${domain}) {
        return 301 https://\$host\$request_uri;
    } # managed by Certbot


    listen 80 ;
    listen [::]:80 ;
    server_name ${domain};
    return 404; # managed by Certbot
}
EOF
sudo systemctl restart nginx
echo "Nginx configurado y reiniciado."

sudo touch "$MARKER_FILE"
echo "Script de inicio completado y marcador creado."

exit 0