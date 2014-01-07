#!/bin/bash

echo "Let's get started."
echo "First of all, configuration"

echo -n "What is the name of your application? (Folder name) : "
read -e APP_NAME

echo -n "What is the name of the database for this app? : "
read -e DATABASE

echo -n "What is the password of your testing database? : "
read -e PASS_DB

echo Creating MySQL database
mysql -uroot -p -e "CREATE DATABASE $DATABASE"

echo "Create laravel project"
composer create-project laravel/laravel $APP_NAME --prefer-dist

cd $APP_NAME

echo Updating database configuration file
gsed -i "s/'database'  => 'database'/'database'  => '$DATABASE'/" app/config/database.php
gsed -i "s/'password'  => ''/'password'  => '$PASS_DB'/" app/config/database.php

echo -n "Do you need a users table? [yes|no] "
read -e ANSWER

if [ $ANSWER = 'yes' ]
then
    echo Creating users table migration
    php artisan migrate:make create_users_table --table="users" --fields="username:string:unique, email:string:unique, password:string, active:integer, level:integer" --create

    echo Migrating the database
    php artisan migrate

    echo Create users controller
    php artisan controller:make UsersController
fi

echo "Add fzaninotto faker and Jeffrey Way's Generators and Form packages"
composer require fzaninotto/faker
composer require way/generators
composer require way/form

php artisan config:publish way/form
composer dump-autoload -o

chmod -R 0777 app/storage

echo "Do not forget to add in app/config/app.php into providers array : "
echo "Way\Form\FormServiceProvider"
echo "Way\Generators\GeneratorsServiceProvider"
