#!/bin/bash

# Remote Host
remote_host=""
remote_user=""
remote_root_path=""
remote_database=""
remote_database_host=""
remote_database_user=""
remote_database_password=""
remote_media_folder= # $remote_root_path/../pub/media
remote_import_folder= # $remote_root_path/../var/importexport/

# Local database credentials
local_database_host=""
local_database_user=""
local_database_password=""
local_database=""
local_database_tmp_file="" #/tmp/$remote_database.sql
local_root_path=""
local_media_folder=''
local_import_folder=''

# Backup and copy database
ssh $remote_user@$remote_host "mysqldump --user=$remote_database_user --password=$remote_database_password --host=$remote_database_host $remote_database > $remote_database.sql"
scp $remote_user@$remote_host:$remote_root_path/$remote_database.sql /tmp/.
ssh $remote_user@$remote_host "rm $remote_database.sql"

# Search & Replace domain name
sed -i 's///g' $local_database_tmp_file

# Import the database copy
# mysqladmin -u $local_database_user --host=$local_database_host -p$local_database_password drop $local_database
# mysqladmin -u $local_database_user --host=$local_database_host -p$local_database_password create $local_database
mysql -u $local_database_user -p$local_database_password $local_database < $local_database_tmp_file
rm $local_database_tmp_file

# Config changes for development
mysql -u $local_database_user -p$local_database_password $local_database -e "UPDATE core_config_data SET value = '0' WHERE core_config_data.path = 'dev/js/merge_files';"
mysql -u $local_database_user -p$local_database_password $local_database -e "UPDATE core_config_data SET value = '0' WHERE core_config_data.path = 'dev/js/enable_js_bundling';"
mysql -u $local_database_user -p$local_database_password $local_database -e "UPDATE core_config_data SET value = '0' WHERE core_config_data.path = 'dev/js/minify_files';"
mysql -u $local_database_user -p$local_database_password $local_database -e "UPDATE core_config_data SET value = '0' WHERE core_config_data.path = 'dev/css/merge_css_files';"
mysql -u $local_database_user -p$local_database_password $local_database -e "UPDATE core_config_data SET value = '0' WHERE core_config_data.path = 'dev/css/minify_files';"

# Sync media folder
rsync -avze ssh $remote_user@$remote_host:$remote_media_folder $local_media_folder
rsync -avze ssh $remote_user@$remote_host:$remote_import_folder $local_import_folder

# Clear Magento cache
cd $local_root_path && php bin/magento cache:flush
