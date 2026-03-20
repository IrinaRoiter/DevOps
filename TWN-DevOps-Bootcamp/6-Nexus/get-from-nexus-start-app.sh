#!/bin/bash
#
function install-app {

    local app_name="$1"
    local log="install-$app_name.log"
    echo "$app_name is not installed."

    apt-get update -qq
    apt-get install -y "$app_name" > "$log" 2>&1
    
    if [[ $? -eq 0 ]]; then
       if command -v "$app_name" &> /dev/null ; then	    
           echo "Installation finished successfully. See $log for details."
       else
	    echo "Installation failed. $app_name command not found. See $log for details."
       fi    
    else
       echo "Installation failed! See $log for details."
    fi


}


function check-app-existence {

   local app_name="$1"
   if command -v "$app_name" &> /dev/null
   then
       echo "$app_name is installed."
       if [[ "$app_name" == "curl" ]]; then 
            version=$("$app_name" --version 2>&1 | head -n 1 | awk '{print $2}') 
       else	       
            version=$($app_name --version 2>&1| head -n 1)
       fi	    
       echo "$app_name version: $version"
    else     
       install-app $app_name
    fi	

}

# Entry point to script

if [[ $UID -ne 0 ]]; then
   echo "Please run this script with sudo"
   exit
fi


base_name="node-js-app"
service_account="$base_name-service"
app_install_path="/opt/nexus-$base_name"
base_nexus_url="http://165.22.230.88:8081"
nexus_assets_url="$base_nexus_url/service/rest/v1/assets?repository=irina-npm"


if [ ! -d "$app_install_path" ]; then
  echo "Installation directory does not exist. Creating it..."
  mkdir -p "$app_install_path"
else
   echo "Installation directory exist. Cleaning it up..."
   rm -R "$app_install_path"
   mkdir -p "$app_install_path"
fi

# Validate prerequisites 

check-app-existence curl
# check-app-existence ca-certificates : Included in the defualt Ubuntu distro

# Add NodeSource repo if it does not exist

if ls /etc/apt/sources.list.d/*nodesource* >/dev/null 2>&1; then
    echo "NodeSource repo already exists. Skipping."
else
    echo "Adding NodeSource repo..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    if [[ $? -ne 0 ]]; then
        echo "Adding NodeSource repo failed. Run command manually and fix the problem."
        exit 1
    fi
fi

#Validate  Node.js and npm
check-app-existence nodejs
check-app-existence npm
check-app-existence jq

#######################################

response=$(curl -s -u artifact-consumer:artifact-consumer "$nexus_assets_url")
# download_urls=$(echo "$response" | jq -r '.items[].downloadUrl | select(endswith(".tgz"))')
latest_url=$(echo "$response" | jq -r '.items[].downloadUrl | select(endswith(".tgz"))' | sort -V | tail -n 1)
echo "$latest_url"

tgz_file=$(basename "$latest_url")
 
curl -s -u artifact-consumer:artifact-consumer -fL -o "$app_install_path/$tgz_file" "$latest_url"
echo "$app_install_path/$tgz_file" 
tar -xvzf "$app_install_path/$tgz_file" -C "$app_install_path"

useradd "$service_account" -m
chown $service_account:$service_account "$app_install_path/package"

runuser -l "$service_account" -c "
      cd "$app_install_path/package" &&
      npm install
      "
runuser -l "$service_account" -c "
      cd "$app_install_path/package" &&
      node server.js &
      "
process_id=$(ps -u $service_account -o pid,cmd | grep 'node server.js' | grep -v grep | awk '{print $1}')
sleep 1
echo "Application is running as:"
ps -o user,pid,cmd -p "$process_id"

port=$(lsof -i -P -n | grep node | awk '{print $9}' | awk -F: '{print $2}')
echo "Port: $port"

