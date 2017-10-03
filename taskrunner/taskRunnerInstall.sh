#!/bin/bash

#This script has the purpose of helping to create new environments in local apache
#instances, the script also add (our standard) set of files for a Grunt/Gulp configuration
# The v2.0 now can guess automatically if you are using Linux or OSX

# Function to create new sites for apache osx
function osx_vhost() {

#We search for the default apache folder and store the first line. 
BULKAPACHESTR="$(apachectl -S | awk -F "[(:]" '{ for (i=2; i<NF; i+=2) print $i; }' | head -n 1)"

#We extract the name of the vhost file
APACHEFILE="$(basename "$BULKAPACHESTR")"
#We extract the extra configuration directory for apache
APACHEDIR="$(dirname "$BULKAPACHESTR")"

# We check that, actually the file is the vhost.conf one
if [ "$APACHEFILE" == "httpd-vhosts.conf" ]
then

	if ! grep -q $DOMAIN $APACHEDIR/$APACHEFILE
	then
		echo ""
		# Install apache configs
		echo -e "\033[1;32mInstalling apache config...\033[0m"
		echo -e "\033[1;31m###############################################\033[0m"
	
		#We copy the default osx vhost file to the folder
		sudo cp "$SOURCE/default_files/apache_files/default_apache_osx.conf" $APACHEDIR	
		#We store the name of the default temporal file in a var.
		TEMP_APACHE_FILE="$APACHEDIR/default_apache_osx.conf"
		
		#We replace the folder path pointing wherever you have the project 
		sudo sed -i ""  "s|{dir_folder_path}|$TARGET|" $TEMP_APACHE_FILE
	
		#We replce the log paths with the project path wherever you have the project
		sudo sed -i ""  "s|{apache_log_dir}|$TARGET|" $TEMP_APACHE_FILE
		#WE replace the name of the domain.
		sudo sed -i ""  "s/{local_tld}/$DOMAIN/" $TEMP_APACHE_FILE
	
		# We add to the config file the contents of the temporal file
		sudo cat $TEMP_APACHE_FILE >> $APACHEDIR/$APACHEFILE 
		# We remove the temp file
		rm -rf $TEMP_APACHE_FILE
	fi

	if ! grep -q $DOMAIN /etc/hosts
	then
		echo "" 
		echo -e "\033[1;32mCreating local DNS in hosts file\033[0m"
		#We add the new site DNS entry to /etc/hosts
		sudo -- sh -c -e "echo '127.0.0.1\t local.${DOMAIN}' >> /etc/hosts"
	fi

	echo ""	
	echo -e "\033[1;32mRestarting apache...\033[0m"
	#We restart apache.
	sudo apachectl restart

	echo -e "\033[1;32mAll tasks done... Have a nice day\033[0m"

fi

}

#Function to create vhosts on linux
function linux_vhost() {

	APACHEDIR="$(locate sites-available | head -n 1)"
	APACHEFILE="$APACHEDIR/local.$DOMAIN.conf"

	echo ""
	# Install apache configs
	echo -e "\033[1;32mInstalling apache config...\033[0m"
	echo -e "\033[1;31m###############################################\033[0m"
	sudo cp -v "$SOURCE/default_files/apache_files/default_apache.conf" $APACHEFILE

	sudo sed -i "s/{dir_folder_path}/$DOMAIN/g" $APACHEFILE
	sudo sed -i "s/{local_tld}/$DOMAIN/g" $APACHEFILE

	echo ""
	echo -e "\033[1;32mActivating site...\033[0m"
	sudo a2ensite "local.$DOMAIN.conf"
       
	if ! grep -q $DOMAIN /etc/hosts
	then
		echo "" 
		echo -e "\033[1;32mCreating local DNS in hosts file\033[0m"
		sudo -- sh -c -e "echo '127.0.0.1\t local.${DOMAIN}' >> /etc/hosts"
	fi
	echo ""	
	echo -e "\033[1;32mRestarting apache...\033[0m"
	sudo apachectl restart

	echo -e "\033[1;32mAll tasks done... Have a nice day\033[0m"
}

#Case to guess in which kind of system the script is run.
unameOut="$(uname -s)"
case "${unameOut}" in
	Linux*)
	  #We define the base dirs from where to copy files.
	  TARGET="$(pwd)"
	  SOURCE="$(dirname "$(readlink -f "$0")")"
	  PARENTDIR="$(dirname "$TARGET")"/
	  DOMAIN="${TARGET//$PARENTDIR}"
	  linux_vhost
	  ;;
	Darwin*)     
	  #We define the base dirs from where to copy files.
	  TARGET="$(pwd)"
          SOURCE="$(dirname "$(readlink "$0")")"
          PARENTDIR="$(dirname "$TARGET")"/
          DOMAIN="${TARGET//$PARENTDIR}"
  	  osx_vhost
	  ;;
	CYGWIN*)    
	  echo "No Windows support, muggle"
	  ;;
	MINGW*)     
	  echo "No Windows support, muggle"
	  ;;
	*)          
	  echo "What the hell are you using?? ${unameOut} is supposed to be a thing?"
esac

if [ -z "$1" ] || [ "$1" != "--host-only" ]
then
	#We create the git {username}/gruntification branch.
	echo -e "\033[1;32mCreating gruntification branch...\033[0m"
	echo -e "\033[1;31m###############################################\033[0m"
	git checkout -b "$(whoami)/gruntification"

	#We copy the files for grunt & gulp from the default location
	echo -e "\033[1;32mCopying files...\033[0m"
	echo -e "\033[1;31m###############################################\033[0m"
	cp -v "$SOURCE/default_files/package.json" $TARGET
	cp -Rv "$SOURCE/default_files/grunt_files/." $TARGET
	cp -Rv "$SOURCE/default_files/gulp_files/." $TARGET

	#We create the Sources foldersi
	echo -e "\033[1;32mCreating directories\033[0m"
	echo -e "\033[1;31m###############################################\033[0m"
	mkdir -vp $TARGET/Sources/Css
	mkdir -v $TARGET/Sources/Js
	mkdir -v $TARGET/Sources/Fonts

	echo ""
	# Install node dependencies
	echo -e "\033[1;32mInstalling node dependencies...\033[0m"
	echo -e "\033[1;31m###############################################\033[0m"
	npm install

fi
