#!/usr/bin/env bash

echo "--- Good morning, master. Let's get to work. Installing now. ---"

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- MySQL time ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "--- Installing base packages ---"
sudo apt-get install -y wget vim tmux curl python-software-properties

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- We want the bleeding edge of PHP, right master? ---"
sudo add-apt-repository -y ppa:ondrej/php5

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y openssh-server php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-readline mysql-server-5.5 php5-mysql git-core phpunit

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite

echo "--- Setting document root ---"
sudo ln -fs /vagrant /var/www

echo "--- Change DocumentRoot for Apache ---"
sed -i "s|DocumentRoot .*|DocumentRoot /var/www/vagrant/public|" /etc/apache2/sites-available/000-default.conf

echo "--- What developer codes without errors turned on? Not you, master. ---"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

echo "--- Restarting Apache ---"
sudo service apache2 restart

echo "--- Composer is the future. But you knew that, did you master? Nice job. ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "--- Install Laravel.phar, sweetie stuff for create laravel project  ---"
wget http://laravel.com/laravel.phar
sudo mv laravel.phar /usr/local/bin/laravel
sudo chmod +x /usr/local/bin/laravel

mysql -u root -p root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"

#echo "--- Installing Oh-My-Zsh ---"
#sudo apt-get install -y zsh
#sudo su - vagrant -c 'wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh'
#sudo su - vagrant -c 'chsh -s `which zsh`'

# Modify bashrc file
cat << EOF | tee -a /home/vagrant/.bashrc
# Laravel
alias artisan="php artisan"
alias migrate="php artisan migrate"
alias serve="php artisan serve"
alias dump="php artisan dump"
alias t="phpunit"

# Generators Package
alias g:c="php artisan generate:controller"
alias g:m="php artisan generate:model"
alias g:v="php artisan generate:view"
alias g:mig="php artisan generate:migration"
alias g:t="php artisan generate:test"
alias g:r="php artisan generate:resource"
alias g:s="php artisan generate:scaffold"
alias g:f="php artisan generate:form"
alias g:p="php artisan generate:pivot"

# Git
alias ga="git add"
alias gaa="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gs="git status"
alias gl="git log"

# Apache restart
alias restartApache="sudo apachectl restart"
EOF

echo "--- All set to go! Would you like to play a game? ---"
