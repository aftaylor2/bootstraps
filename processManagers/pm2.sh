#!/usr/bin/env bash
# Install & Configure PM2 + LetsEncrypt
# NOTE: Should be used on VMs and not in containers
##############################################################################
# TODO:
# Add optional Nginx + PM2 setup
# https://pm2.keymetrics.io/docs/tutorials/pm2-nginx-production-setup
##############################################################################

usage() {
    cat - >&2 <<EOF
NAME
    PM2 Bootstrap - Configure production nodeJS project using pm2

SYNOPSIS
    $0 [-h|--help]
    $0 [-n|--name]
                        [-b|--bar <arg>]
                        [--nginx[=<arg>]]
                        [--]
                        FILE ...

REQUIRED ARGUMENTS
  -n, --name
          Name of the project

OPTIONS
  -h, --help
          Prints this and exits

  -d, --dir
          Path of project root directory ( Default: /var/www/NAME_OF_PROJECT )

  -l, --log <arg>
          Optional path of log directory ( Default: /var/log/NAME_OF_PROJECT )

  -g, --group <arg>
          Optional group name for project ( Default: www-data )

  --nginx[=<boolean arg>]
          Option boolean argument <arg>. If <arg> is not specified, defaults
          to FALSE. OPTION NOT YET FUNCTIONAL.
  --
          Specify end of options
EOF

    exit
}

install_cert_bot() {
    echo 'Installing cert bot…'
    sudo apt update &&
        sudo apt -y install software-properties-common &&
        sudo add-apt-repository universe
    sudo apt update && sudo apt -y install certbot
    # sudo certbot certonly -n --standalone --agree-tos \
    # -m support@domain.com \
    # -d $HOST.domain.com
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -n | --name)
        PROJECT_NAME="$2"
        shift # past argument
        shift # past value
        ;;
    -d | --dir)
        PROJECT_DIR="$2"
        shift # past argument
        shift # past value
        ;;
    -g | --group)
        PROJECT_GROUP="$2"
        shift # past argument
        shift # past value
        ;;
    -l | --log_dir)
        LOG_DIR="$2"
        shift # past argument
        shift # past value
        ;;
    -h | --help)
        usage
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
    esac
done

# Defaults
[ -z "$PROJECT_DIR" ] && PROJECT_DIR="/var/www/${PROJECT_NAME}"
[ -z "$LOG_DIR" ] && LOG_DIR="/var/log/${PROJECT_NAME}"
[ -z "$PROJECT_GROUP" ] && PROJECT_GROUP="www-data"

LETS_ENCRYPT_DIR="/etc/letsencrypt"
NODE_PATH=$(which node)

set -- "${POSITIONAL[@]}" # restore positional parameters

[ -z $PROJECT_NAME ] && usage

echo "PROJECT NAME    = ${PROJECT_NAME}"
echo "PROJECT DIR     = ${PROJECT_DIR}"
echo "PROJECT GROUP   = ${PROJECT_GROUP}"
echo "LOG DIRECTORY   = ${LOG_DIR}"
echo "NODE PATH       = ${NODE_PATH}"

sudo usermod -a -G $PROJECT_GROUP $USER
# newgrp $PROJECT_GROUP # opens into new shell and causes issue
# https://unix.stackexchange.com/questions/18897/

# Lets encrypt permissions
[ ! -d "$LETS_ENCRYPT_DIR" ] && install_cert_bot

if [[ -d "$LETS_ENCRYPT_DIR/archive" ]]; then
    cd $LETS_ENCRYPT_DIR
    sudo chown -R root:$PROJECT_GROUP archive/ live/
    sudo chmod g+rx archive/ live
fi

echo 'Configuring node to run as non root user'
sudo setcap CAP_NET_BIND_SERVICE=+eip $NODE_PATH

[ ! -d "$LOG_DIR" ] && sudo mkdir -p $LOG_DIR

sudo chown -R root:$PROJECT_GROUP $LOG_DIR
sudo chmod g+rwx $LOG_DIR

touch $LOG_DIR/$PROJECT_NAME.log

cd /etc/logrotate.d/

cat <<EOT >/tmp/$PROJECT_NAME
${LOG_DIR}/${PROJECT_NAME}.log {
       su root
       daily
       rotate 7
       delaycompress
       compress
       notifempty
       missingok
       copytruncate
}
EOT

cat <<EOT >/tmp/$PROJECT_NAME-error
${LOG_DIR}/${PROJECT_NAME}-error.log {
       su root
       daily
       rotate 7
       delaycompress
       compress
       notifempty
       missingok
       copytruncate
}
EOT

sudo mv /tmp/$PROJECT_NAME /etc/logrotate.d/
sudo mv /tmp/$PROJECT_NAME-error /etc/logrotate.d/

cd $PROJECT_DIR

[ -f "${PROJECT_DIR}/app.js" ] && SCRIPT='app.js' || SCRIPT='server.js'

cat <<EOT >$PROJECT_DIR/ecosystem.config.js
module.exports = {
  apps: [
    {
      name: '${PROJECT_NAME}',
      cwd:  '${PROJECT_DIR}',
      script: '${SCRIPT}',
      watch: true,
      ignore_watch: ["node_modules", "public", "scripts", "test"],
      error_file: '${LOG_DIR}/${PROJECT_NAME}-error.log',
      # out_file: '${LOG_DIR}/${PROJECT_NAME}.log',
      log_file: '${LOG_DIR}/${PROJECT_NAME}.log'
    }
  ]
};
EOT

PM2_PATH=$(which pm2)
[ -z $PM2_PATH ] && sudo npm install -g pm2

pm2 start ecosystem.config.js
# pm2 startup ecosystem.config.js -u www --hp /home/www
INSTALL_STARTUP_CMD=$(pm2 startup | tail -n 1)
echo $INSTALL_STARTUP_CMD
pm2 save
