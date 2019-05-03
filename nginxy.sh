#!/usr/bin/env bash
#===============================================================================================================================================
# (C) Copyright 2019 NGINXY a project under the Crypto World Foundation (https://cryptoworld.is).
#
# Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================================================================================
# title            :NGINXY
# description      :This script will make it super easy to setup a Reverse Proxy with NGINX.
# author           :The Crypto World Foundation.
# contributors     :beard, ksaredfx
# date             :04-28-2019
# version          :0.1.3 Beta
# os               :Debian/Ubuntu
# usage            :bash nginxy.sh
# notes            :If you have any problems feel free to email the maintainer: beard [AT] cryptoworld [DOT] is
#===============================================================================================================================================

# Force check for root
  if ! [ "$(id -u)" = 0 ]; then
    echo "You need to be logged in as root!"
    exit 1
  fi

  # Setting up an update/upgrade global function
    function upkeep() {
      echo "Performing upkeep.."
        apt-get update -y
        apt-get dist-upgrade -y
        apt-get clean -y
    }

  # Setting up different NGINX branches to prep for install
    function nginx_stable() {
        echo deb http://nginx.org/packages/"$system"/ "$flavor" nginx > /etc/apt/sources.list.d/"$flavor".nginx.stable.list
        echo deb-src http://nginx.org/packages/"$system"/ "$flavor" nginx >> /etc/apt/sources.list.d/"$flavor".nginx.stable.list
          wget https://nginx.org/keys/nginx_signing.key
          apt-key add nginx_signing.key
      }

    function nginx_mainline() {
        echo deb http://nginx.org/packages/mainline/"$system"/ "$flavor" nginx > /etc/apt/sources.list.d/"$flavor".nginx.mainline.list
        echo deb-src http://nginx.org/packages/mainline/"$system"/ "$flavor" nginx >> /etc/apt/sources.list.d/"$flavor".nginx.mainline.list
          wget https://nginx.org/keys/nginx_signing.key
          apt-key add nginx_signing.key
      }

      # Attached func for NGINX branch prep.
        function nginx_default() {
          echo "Installing NGINX.."
            apt-get install nginx
            service nginx status
          echo "Raising limit of workers.."
            ulimit -n 65536
            ulimit -a
          echo "Setting up Security Limits.."
            wget -O /etc/security/limits.conf https://raw.githubusercontent.com/beardlyness/NGINXY/master/etc/security/limits.conf
          echo "Setting up background NGINX workers.."
            wget -O /etc/default/nginx https://raw.githubusercontent.com/beardlyness/NGINXY/master/etc/default/nginx
          echo "Setting up configuration file for NGINX main configuration.."
            wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/beardlyness/NGINXY/master/etc/nginx/nginx.conf
          echo "Setting up folders.."
        }

        function proxy_default()  {
          read -r -p "Domain Name: (Leave { HTTPS:/// | HTTP:// | WWW. } out of the domain) " DOMAIN
            if [[ -n "${DOMAIN,,}" ]]
              then
                echo "Setting up configuration file for NGINX Proxy.."
                  wget -O /etc/nginx/conf.d/"$DOMAIN".conf https://raw.githubusercontent.com/beardlyness/NGINXY/master/etc/nginx/conf.d/nginx-proxy.conf
                echo "Changing 'server_name foobar' >> server_name '$DOMAIN' .."
                  sed -i 's/server_name foobar/server_name '"$DOMAIN"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                echo "Fixing up the site configuration file for NGINX.."
                  sed -i 's/domain/'"$DOMAIN"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                echo "Domain Name has been set to: '$DOMAIN' "
                echo "Removing Default NGINX Configuration files.."
                  mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.old
                echo "Setting up folders.."
                  mkdir -p /etc/engine/ssl/"$DOMAIN"
                  mkdir -p /var/www/html/"$DOMAIN"/live
              else
                echo "You have entered an invalid Domain Name."
            fi

            read -r -p "Please enter the IP Address for the Backend IP: " IPA
              if [[ "${IPA},,}" =~ (25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) ]]
                then
                  echo "Changing 'server Main-A' >> server '$IPA' .."
                    sed -i 's/backend/'"$IPA"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                  echo "Backend IP Address has been set to: '$IPA' "
                else
                  echo "You have entered an invalid IP Address.."
              fi
        }

        function proxy_upstream() {
          read -r -p "Domain Name: (Leave { HTTPS:/// | HTTP:// | WWW. } out of the domain) " DOMAIN
            if [[ -n "${DOMAIN,,}" ]]
              then
                echo "Setting up configuration file for NGINX Proxy.."
                  wget -O /etc/nginx/conf.d/"$DOMAIN".conf https://raw.githubusercontent.com/beardlyness/NGINXY/master/etc/nginx/conf.d/nginx-upstream.conf
                echo "Changing 'server_name foobar' >> server_name '$DOMAIN' .."
                  sed -i 's/server_name foobar/server_name '"$DOMAIN"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                echo "Fixing up the site configuration file for NGINX.."
                  sed -i 's/domain/'"$DOMAIN"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                echo "Domain Name has been set to: '$DOMAIN' "
                echo "Removing Default NGINX Configuration files.."
                  mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.old
                echo "Setting up folders.."
                  mkdir -p /etc/engine/ssl/"$DOMAIN"
                  mkdir -p /var/www/html/"$DOMAIN"/live
              else
                echo "Sorry we cannot live on! RIP Dead.."
            fi

            read -r -p "Please enter the IP Address for Upstream IP: " IPA
              if [[ "${IPA},,}" =~ (25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) ]]
                then
                  echo "Changing 'server Main-A' >> server '$IPA' .."
                    sed -i 's/server Main-A/server '"$IPA"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                  echo "Upstream IP Address has been set to: '$IPA' "
                else
                  echo "You have entered an invalid IP Address.."
              fi

              read -r -p "Please enter the IP Address for Upstream IP: " IPB
                if [[ "${IPB},,}" =~ (25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) ]]
                  then
                    echo "Changing 'server Main-B' >> server '$IPB' .."
                      sed -i 's/server Main-B/server '"$IPB"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                    echo "Upstream IP Address has been set to: '$IPB' "
                  else
                    echo "You have entered an invalid IP Address.."
                fi

                read -r -p "Please enter the IP Address for Upstream IP: " IPC
                  if [[ "${IPC},,}" =~ (25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) ]]
                    then
                      echo "Changing 'server Main-C' >> server '$IPC' .."
                        sed -i 's/server Main-C/server '"$IPC"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                      echo "Upstream IP Address has been set to: '$IPC' "
                    else
                      echo "You have entered an invalid IP Address.."
                  fi

                  read -r -p "Please enter the IP Address for Upstream IP: " IPD
                    if [[ "${IPD},,}" =~ (25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) ]]
                      then
                        echo "Changing 'server Main-D' >> server '$IPD' .."
                          sed -i 's/server Main-D/server '"$IPD"'/g' /etc/nginx/conf.d/"$DOMAIN".conf
                        echo "Upstream IP Address has been set to: '$IPD' "
                      else
                        echo "You have entered an invalid IP Address.."
                    fi
        }

        #Prep for Custom Error Page Handling
          function custom_errors() {
            echo "Setting up folders.."
              mkdir -p /var/www/html/"$DOMAIN"/live/errors
            echo "Grabbing Custom Error Pages & Handling from GitHub.."
              wget https://github.com/beardlyness/nginxy-custom-errors/archive/master.tar.gz -O - | tar -xz -C /var/www/html/"$DOMAIN"/live/errors/  && mv /var/www/html/"$DOMAIN"/live/errors/NGINXY-Custom-Errors-master/* /var/www/html/"$DOMAIN"/live/errors/
            echo "Removing temporary files/folders.."
              rm -rf /var/www/html/"$DOMAIN"/live/NGINXY-Custom-Errors-master && rm -rf /var/www/html/"$DOMAIN"/live/errors/LICENSE
          }

        #Prep for SSL setup & install via ACME.SH script | Check it out here: https://github.com/Neilpang/acme.sh
          function ssldev() {
            echo "Preparing for SSL install.."
              wget -O -  https://raw.githubusercontent.com/Neilpang/acme.sh/master/acme.sh | INSTALLONLINE=1  sh
              reset
              service nginx stop
              openssl dhparam -out /etc/engine/ssl/"$DOMAIN"/dhparam.pem 2048
              bash ~/.acme.sh/acme.sh --issue --standalone -d "$DOMAIN" -ak 4096 -k 4096 --force
              bash ~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" \
                --key-file    /etc/engine/ssl/"$DOMAIN"/ssl.key \
                --fullchain-file    /etc/engine/ssl/"$DOMAIN"/certificate.cert \
                --reloadcmd   "service nginx restart"
          }

          #Prep for SSL setup for Qualys rating
          function sslqualy() {
            echo "Preparing to setup NGINX to meet Qualys 100% Standards.."
              sed -i 's/ssl_prefer_server_ciphers/#ssl_prefer_server_ciphers/g' /etc/nginx/conf.d/"$DOMAIN".conf
              sed -i 's/#ssl_ciphers/ssl_ciphers/g' /etc/nginx/conf.d/"$DOMAIN".conf
              sed -i 's/#ssl_ecdh_curve/ssl_ecdh_curve/g' /etc/nginx/conf.d/"$DOMAIN".conf
            echo "Generating a 4096 DH Param. This may take a while.."
              openssl dhparam -out /etc/engine/ssl/"$DOMAIN"/dhparam.pem 4096
            echo "Restarting NGINX Service..."
              service nginx restart
          }

      # Setting up different PHP Version branches to prep for install
        function phpdev() {
          echo "Setting up PHP Branches for install.."
            wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
          echo "deb https://packages.sury.org/php/ ""$flavor"" main" | tee /etc/apt/sources.list.d/php.list
        }


#START

# Checking for multiple "required" pieces of software.
    tools=( lsb-release wget curl dialog socat dirmngr apt-transport-https ca-certificates )
     grab_eware=""
       for e in "${tools[@]}"; do
         if command -v "$e" >/dev/null 2>&1; then
           echo "Dependency $e is installed.."
         else
           echo "Dependency $e is not installed..?"
            upkeep
            grab_eware="$grab_eware $e"
         fi
       done
      apt-get install $grab_eware


    # Grabbing info on active machine.
        flavor=$(lsb_release -cs)
        system=$(lsb_release -i | grep "Distributor ID:" | sed 's/Distributor ID://g' | sed 's/["]//g' | awk '{print tolower($1)}')


# NGINX Arg main
read -r -p "Do you want to setup NGINX as a Reverse Proxy? (Y/Yes | N/No) " REPLY
  case "${REPLY,,}" in
    [yY]|[yY][eE][sS])
      HEIGHT=20
      WIDTH=120
      CHOICE_HEIGHT=2
      BACKTITLE="NGINXY"
      TITLE="NGINX Branch Builds"
      MENU="Choose one of the following Build options:"

      OPTIONS=(1 "Stable"
               2 "Mainline")

      CHOICE=$(dialog --clear \
                      --backtitle "$BACKTITLE" \
                      --title "$TITLE" \
                      --menu "$MENU" \
                      $HEIGHT $WIDTH $CHOICE_HEIGHT \
                      "${OPTIONS[@]}" \
                      2>&1 >/dev/tty)


# Attached Arg for dialogs $CHOICE output
    case $CHOICE in
      1)
        echo "Grabbing Stable build dependencies.."
          nginx_stable
          upkeep
          nginx_default

          # NGINX Proxy Sub Arg
          read -r -p "Do you want to setup NGINX as a single base Reverse Proxy or as an Multi-Upstream Reverse Proxy? (S/Single | M/Multi) " REPLY
            case "${REPLY,,}" in
              [sS]|[sS][iI][nN][gG][lL][eE])
                  echo "Grabbing Stable build dependencies.."
                    proxy_default
                    custom_errors
                    ssldev
                ;;
              [mM]|[mM][uU][lL][tT][iI])
                  echo "Grabbing Mainline build dependencies.."
                    proxy_upstream
                    custom_errors
                    ssldev
                ;;
              *)
                echo "Invalid response. You okay?"
                ;;
          esac

          ;;
      2)
        echo "Grabbing Mainline build dependencies.."
          nginx_mainline
          upkeep
          nginx_default

          # NGINX Proxy Sub Arg
          read -r -p "Do you want to setup NGINX as a single base Reverse Proxy or as an Multi-Upstream Reverse Proxy? (S/Single | M/Multi) " REPLY
            case "${REPLY,,}" in
              [sS]|[sS][iI][nN][gG][lL][eE])
                  echo "Grabbing Stable build dependencies.."
                    proxy_default
                    custom_errors
                    ssldev
                ;;
              [mM]|[mM][uU][lL][tT][iI])
                  echo "Grabbing Mainline build dependencies.."
                    proxy_upstream
                    custom_errors
                    ssldev
                ;;
              *)
                echo "Invalid response. You okay?"
                ;;
          esac

          ;;
    esac
clear

# Close Arg for Main Statement.
      ;;
    [nN]|[nN][oO])
      echo "You have said no? We cannot work without your permission!"
      ;;
    *)
      echo "Invalid response. You okay?"
      ;;
esac

read -r -p "Would you like to setup the sysctl.conf to harden the security of the host box? (Y/Yes | N/No) " REPLY
  case "${REPLY,,}" in
    [yY]|[yY][eE][sS])
        echo "Setting up sysctl.conf rules. Hold tight.."
          wget -O /etc/sysctl.conf https://raw.githubusercontent.com/beardlyness/NGINXY/master/etc/sysctl.conf
          ;;
    [nN]|[nN][oO])
      echo "You have said no? We cannot work without your permission!"
      ;;
    *)
    echo "Invalid response. You okay?"
    ;;
  esac

  # PHP Arg main
  read -r -p "Do you want to install and setup PHP? (Y/Yes | N/No) " REPLY
    case "${REPLY,,}" in
      [yY]|[yY][eE][sS])
        HEIGHT=20
        WIDTH=120
        CHOICE_HEIGHT=3
        BACKTITLE="NGINXY"
        TITLE="PHP Branch Builds"
        MENU="Choose one of the following Build options:"

        OPTIONS=(1 "7.1"
                 2 "7.2"
                 3 "7.3")

        CHOICE=$(dialog --clear \
                        --backtitle "$BACKTITLE" \
                        --title "$TITLE" \
                        --menu "$MENU" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${OPTIONS[@]}" \
                        2>&1 >/dev/tty)


  # Attached Arg for dialogs $CHOICE output
      case $CHOICE in
        1)
          echo "Installing PHP 7.1, and its modules.."
            phpdev
            upkeep
              apt install php7.1 php7.1-fpm php7.1-cli php7.1-common php7.1-curl php7.1-mbstring php7.1-mysql php7.1-xml
              sed -i 's/listen.owner = www-data/listen.owner = nginx/g' /etc/php/7.1/fpm/pool.d/www.conf
              sed -i 's/listen.group = www-data/listen.group = nginx/g' /etc/php/7.1/fpm/pool.d/www.conf
              sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini
              sed -i 's/phpx.x-fpm.sock/php7.1-fpm.sock/g' /etc/nginx/conf.d/"$DOMAIN".conf
              service php7.1-fpm restart
              service php7.1-fpm status
              service nginx restart
              pgrep -v root | pgrep php-fpm | cut -d\  -f1 | sort | uniq
            ;;
        2)
          echo "Installing PHP 7.2, and its modules.."
            phpdev
            upkeep
              apt install php7.2 php7.2-fpm php7.2-cli php7.2-common php7.2-curl php7.2-mbstring php7.2-mysql php7.2-xml
              sed -i 's/listen.owner = www-data/listen.owner = nginx/g' /etc/php/7.2/fpm/pool.d/www.conf
              sed -i 's/listen.group = www-data/listen.group = nginx/g' /etc/php/7.2/fpm/pool.d/www.conf
              sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.2/fpm/php.ini
              sed -i 's/phpx.x-fpm.sock/php7.2-fpm.sock/g' /etc/nginx/conf.d/"$DOMAIN".conf
              service php7.2-fpm restart
              service php7.2-fpm status
              service nginx restart
              pgrep -v root | pgrep php-fpm | cut -d\  -f1 | sort | uniq
            ;;
        3)
          echo "Installing PHP 7.3, and its modules.."
            phpdev
            upkeep
             apt install php7.3 php7.3-fpm php7.3-cli php7.3-common php7.3-curl php7.3-mbstring php7.3-mysql php7.3-xml
             sed -i 's/listen.owner = www-data/listen.owner = nginx/g' /etc/php/7.3/fpm/pool.d/www.conf
             sed -i 's/listen.group = www-data/listen.group = nginx/g' /etc/php/7.3/fpm/pool.d/www.conf
             sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.3/fpm/php.ini
             sed -i 's/phpx.x-fpm.sock/php7.3-fpm.sock/g' /etc/nginx/conf.d/"$DOMAIN".conf
             service php7.3-fpm restart
             service php7.3-fpm status
             service nginx restart
             pgrep -v root | pgrep php-fpm | cut -d\  -f1 | sort | uniq
            ;;
      esac
  clear

  # Close Arg for Main Statement.
        ;;
      [nN]|[nN][oO])
        echo "You have said no? We cannot work without your permission!"
        ;;
      *)
        echo "Invalid response. You okay?"
        ;;
  esac


  read -r -p "Do you want to setup NGINX to get a 100% Qualys SSL Rating? (Y/Yes | N/No) " REPLY
    case "${REPLY,,}" in
      [yY]|[yY][eE][sS])
            sslqualy
        ;;
      [nN]|[nN][oO])
          echo "You have said no? We cannot work without your permission!"
        ;;
      *)
        echo "Invalid response. You okay?"
        ;;
  esac
