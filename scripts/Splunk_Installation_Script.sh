#!/bin/bash

# Increase the maximum number of open files
ulimit -n 64000

# Disable Transparent Huge Pages (THP)
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null 2>&1
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag > /dev/null 2>&1 && echo -e "\033[33mulimit and defrag values have been changed successfully\033[0m"

# Prompt for the Linux distribution name
while true; do
    read -p "Enter Linux Distribution Name [amazon-linux, ubuntu, red-hat, centos]: " OS_RELEASE
    if [[ "$OS_RELEASE" == "amazon-linux" || "$OS_RELEASE" == "ubuntu" || "$OS_RELEASE" == "red-hat" || "$OS_RELEASE" == "centos" ]]; then
        break
    else
        echo -e "\033[31mInvalid input. Please enter a valid Linux Distribution Name: amazon-linux, ubuntu, red-hat, centos\033[0m"
    fi
done

# Install the wget command based on the Linux distribution
if [[ "$OS_RELEASE" == "amazon-linux" || "$OS_RELEASE" == "red-hat" || "$OS_RELEASE" == "centos" ]]; then
    sudo yum install wget -y > /dev/null 2>&1
elif [[ "$OS_RELEASE" == "ubuntu" ]]; then
    sudo apt-get install wget -y > /dev/null 2>&1
fi

# Prompt for username and password
while true; do
    read -p "Enter username: " USERNAME

     while true; do
        # Get password from the user (hidden input)
        read -p "Enter password for $USERNAME: " -s PASSWORD
        echo -e "\n"

        # Ensure password is not empty
        if [[ -z "$PASSWORD" ]]; then
            echo -e "\033[31mError: Password cannot be empty!\033[0m"
        else
            break
        fi
    done

    # Create the user with home directory and set password
    echo "$PASSWORD" | sudo useradd -m -s /bin/bash "$USERNAME" --password "$(openssl passwd -1 "$PASSWORD")" > /dev/null 2>&1 && echo -e "\033[33mNew Password was set to the user $USERNAME\033[0m"

    # Check for successful user creation
    if [[ $? -eq 0 ]]; then
        echo -e "\033[33mUser $USERNAME created successfully!\033[0m"
        break
	elif id "$USERNAME" >/dev/null 2>&1; then
        echo -e "\033[33mUser $USERNAME already exists!\033[0m"
        break
    else
        echo -e "\033[31mError: Failed to create user $USERNAME !\033[0m"
    fi
done

# Add the new user to the appropriate admin group based on the Linux distribution
if [[ "$OS_RELEASE" == "amazon-linux" || "$OS_RELEASE" == "red-hat" || "$OS_RELEASE" == "centos" ]]; then
    sudo usermod -aG wheel "$USERNAME"
else
    sudo usermod -aG sudo "$USERNAME"
fi

# Prompt for the Splunk component and version
while true; do
    read -p "Enter The Splunk Component [indexer, search_head, heavy_forwarder, universal_forwarder]: " COMPONENT
    if [[ "$COMPONENT" == "indexer" || "$COMPONENT" == "search_head" || "$COMPONENT" == "heavy_forwarder" || "$COMPONENT" == "universal_forwarder" ]]; then
        break
    else
        echo -e "\033[31mInvalid input. Please enter a valid Splunk Component: indexer, search_head, heavy_forwarder, universal_forwarder\033[0m"
    fi
done

if [[ "$COMPONENT" == "indexer" || "$COMPONENT" == "search_head" || "$COMPONENT" == "heavy_forwarder" ]]; then
    valid_versions=('9.2.2' '9.2.0.1' '9.2.0' '9.1.5' '9.1.4' '9.1.3' '9.1.2' '9.1.1' '9.1.0.2' '9.1.0.1' '9.1.0' '9.0.9' '9.0.8' '9.0.7' '9.0.6' '9.0.5.1' '9.0.5' '9.0.4.1' '9.0.4' '9.0.3' '9.0.2' '9.0.10' '9.0.1' '9.0.0.1' '9.0.0' '8.2.9' '8.2.8' '8.2.7.1' '8.2.7' '8.2.6.1' '8.2.6' '8.2.5' '8.2.4.3' '8.2.4.1' '8.2.4' '8.2.3.3' '8.2.3.2' '8.2.3' '8.2.2.2' '8.2.2.1' '8.2.12' '8.2.11.2' '8.2.11' '8.2.10' '8.2.1' '8.2.0' '8.1.9' '8.1.8' '8.1.7.2' '8.1.7.1' '8.1.7' '8.1.6' '8.1.14' '8.1.13' '8.1.12' '8.1.11' '8.1.10.1')
elif [[ "$COMPONENT" == "universal_forwarder" ]]; then
    valid_versions=('9.2.1' '9.2.0.1' '9.2.0' '9.1.5' '9.1.4' '9.1.3' '9.1.2' '9.1.1' '9.1.0.1' '9.1.0' '9.0.9' '9.0.8' '9.0.7' '9.0.6' '9.0.5' '9.0.4' '9.0.3' '9.0.2' '9.0.10' '9.0.1' '9.0.0.1' '9.0.0' '8.2.9' '8.2.8' '8.2.7.1' '8.2.7' '8.2.6.1' '8.2.6' '8.2.5' '8.2.4' '8.2.3' '8.2.2.1' '8.2.2' '8.2.12' '8.2.11' '8.2.10' '8.2.1' '8.2.0' '8.1.9' '8.1.8' '8.1.7' '8.1.6' '8.1.5' '8.1.4' '8.1.3' '8.1.2' '8.1.14' '8.1.13' '8.1.12' '8.1.11' '8.1.10.1' '8.1.10' '8.1.1' '8.1.0.1' '8.1.0' '8.0.9' '8.0.8' '8.0.7' '8.0.6' '8.0.10')
else
    echo -e "\033[31mInvalid component. Please choose either 'indexer', 'search_head', 'heavy_forwarder', or 'universal_forwarder'.\033[0m"
    exit 1
fi

while true; do
    read -p "Enter The Splunk $COMPONENT Version :" VERSION
    if [[ " ${valid_versions[@]} " =~ " ${VERSION} " ]]; then
        break
    else
        echo -e "\033[31mInvalid version. only these version are available for download ${valid_versions[@]}\033[0m"
    fi
done

while true; do
    read -p "Enter the file extension [tgz, rpm, deb]: " EXTENSION
    if [[ "$EXTENSION" == "tgz" || "$EXTENSION" == "rpm" || "$EXTENSION" == "deb" ]]; then
        break
    else
        echo -e "\033[31mInvalid extension. Please enter either 'tgz', 'rpm', or 'deb'.\033[0m"
    fi
done

if [[ "$EXTENSION" == "rpm" || "$EXTENSION" == "deb" ]]; then
    read -p "Enter The Splunk File Name (copy it from the wget link, e.g., splunk-9.2.2-d76edf6f0a15-linux-2.6-amd64.deb, splunk-9.2.2-d76edf6f0a15.x86_64.rpm): " FILENAME
else
    if [[ "$COMPONENT" == "indexer" || "$COMPONENT" == "search_head" || "$COMPONENT" == "heavy_forwarder" ]]; then
        case "$VERSION" in
           "9.2.2") FILENAME="splunk-9.2.2-d76edf6f0a15-Linux-x86_64.tgz" ;;
	       "9.2.0.1") FILENAME="splunk-9.2.0.1-d8ae995bf219-Linux-x86_64.tgz" ;;
  	       "9.2.0") FILENAME="splunk-9.2.0-1fff88043d5f-Linux-x86_64.tgz" ;;
	       "9.1.5") FILENAME="splunk-9.1.5-29befd543def-Linux-x86_64.tgz" ;;
	       "9.1.4") FILENAME="splunk-9.1.4-a414fc70250e-Linux-x86_64.tgz" ;;
	       "9.1.3") FILENAME="splunk-9.1.3-d95b3299fa65-Linux-x86_64.tgz" ;;
	       "9.1.2") FILENAME="splunk-9.1.2-b6b9c8185839-Linux-x86_64.tgz" ;;
	       "9.1.1") FILENAME="splunk-9.1.1-64e843ea36b1-Linux-x86_64.tgz" ;;
	       "9.1.0.2") FILENAME="splunk-9.1.0.2-b6436b649711-Linux-x86_64.tgz" ;;
	       "9.1.0.1") FILENAME="splunk-9.1.0.1-77f73c9edb85-Linux-x86_64.tgz" ;;
	       "9.1.0") FILENAME="splunk-9.1.0-1c86ca0bacc3-Linux-x86_64.tgz" ;;
	       "9.0.9") FILENAME="splunk-9.0.9-6315942c563f-Linux-x86_64.tgz" ;;
	       "9.0.8") FILENAME="splunk-9.0.8-4fb5067d40d2-Linux-x86_64.tgz" ;;
	       "9.0.7") FILENAME="splunk-9.0.7-b985591d12fd-Linux-x86_64.tgz" ;;
	       "9.0.6") FILENAME="splunk-9.0.6-050c9bca8588-Linux-x86_64.tgz" ;;
	       "9.0.5.1") FILENAME="splunk-9.0.5.1-52d49260b188-Linux-x86_64.tgz" ;;
	       "9.0.5") FILENAME="splunk-9.0.5-e9494146ae5c-Linux-x86_64.tgz" ;;
	       "9.0.4.1") FILENAME="splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz" ;;
	       "9.0.4") FILENAME="splunk-9.0.4-de405f4a7979-Linux-x86_64.tgz" ;;
	       "9.0.3") FILENAME="splunk-9.0.3-dd0128b1f8cd-Linux-x86_64.tgz" ;;
	       "9.0.2") FILENAME="splunk-9.0.2-17e00c557dc1-Linux-x86_64.tgz" ;;
	       "9.0.10") FILENAME="splunk-9.0.10-f551b9b500f8-Linux-x86_64.tgz" ;;
	       "9.0.1") FILENAME="splunk-9.0.1-82c987350fde-Linux-x86_64.tgz" ;;
	       "9.0.0.1") FILENAME="splunk-9.0.0.1-9e907cedecb1-Linux-x86_64.tgz" ;;
	       "9.0.0") FILENAME="splunk-9.0.0-6818ac46f2ec-Linux-x86_64.tgz" ;;
	       "8.2.9") FILENAME="splunk-8.2.9-4a20fb65aa78-Linux-x86_64.tgz" ;;
	       "8.2.8") FILENAME="splunk-8.2.8-da25d08d5d3e-Linux-x86_64.tgz" ;;
	       "8.2.7.1") FILENAME="splunk-8.2.7.1-c2b65bc24aea-Linux-x86_64.tgz" ;;
	       "8.2.7") FILENAME="splunk-8.2.7-2e1fca123028-Linux-x86_64.tgz" ;;
	       "8.2.6.1") FILENAME="splunk-8.2.6.1-5f0da8f6e22c-Linux-x86_64.tgz" ;;
	       "8.2.6") FILENAME="splunk-8.2.6-a6fe1ee8894b-Linux-x86_64.tgz" ;;
	       "8.2.5") FILENAME="splunk-8.2.5-77015bc7a462-Linux-x86_64.tgz" ;;
	       "8.2.4.3") FILENAME="splunk-8.2.4.3-28869a19ae1b-Linux-x86_64.tgz" ;;
	       "8.2.4.1") FILENAME="splunk-8.2.4.1-a3e62cbc8550-Linux-x86_64.tgz" ;;
	       "8.2.4") FILENAME="splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz" ;;
	       "8.2.3.3") FILENAME="splunk-8.2.3.3-e40ea5a516d2-Linux-x86_64.tgz" ;;
	       "8.2.3.2") FILENAME="splunk-8.2.3.2-5281ae34c90c-Linux-x86_64.tgz" ;;
	       "8.2.3") FILENAME="splunk-8.2.3-cd0848707637-Linux-x86_64.tgz" ;;
	       "8.2.2.2") FILENAME="splunk-8.2.2.2-e89a7a0a7f22-Linux-x86_64.tgz" ;;
	       "8.2.2.1") FILENAME="splunk-8.2.2.1-ae6821b7c64b-Linux-x86_64.tgz" ;;
	       "8.2.12") FILENAME="splunk-8.2.12-e973afd6886e-Linux-x86_64.tgz" ;;
	       "8.2.11.2") FILENAME="splunk-8.2.11.2-84863c49dc5d-Linux-x86_64.tgz" ;;
	       "8.2.11") FILENAME="splunk-8.2.11-e73c56f930c5-Linux-x86_64.tgz" ;;
	       "8.2.10") FILENAME="splunk-8.2.10-417e74d5c950-Linux-x86_64.tgz" ;;	
	       "8.2.1") FILENAME="splunk-8.2.1-ddff1c41e5cf-Linux-x86_64.tgz" ;;
	       "8.2.0") FILENAME="splunk-8.2.0-e053ef3c985f-Linux-x86_64.tgz" ;;
	       "8.1.9") FILENAME="splunk-8.1.9-a16db3287b56-Linux-x86_64.tgz" ;;
	       "8.1.8") FILENAME="splunk-8.1.8-39da583cc695-Linux-x86_64.tgz" ;;
	       "8.1.7.2") FILENAME="splunk-8.1.7.2-dc318a6952c4-Linux-x86_64.tgz" ;;
	       "8.1.7.1") FILENAME="splunk-8.1.7.1-19e1d5d518a7-Linux-x86_64.tgz" ;;
	       "8.1.7") FILENAME="splunk-8.1.7-79650d4c9dc0-Linux-x86_64.tgz" ;;
	       "8.1.6") FILENAME="splunk-8.1.6-c1a0dd183ee5-Linux-x86_64.tgz" ;;
	       "8.1.14") FILENAME="splunk-8.1.14-7b72da4f30b8-Linux-x86_64.tgz" ;;
	       "8.1.13") FILENAME="splunk-8.1.13-898c6e996343-Linux-x86_64.tgz" ;;
	       "8.1.12") FILENAME="splunk-8.1.12-4eb558a8f0b7-Linux-x86_64.tgz" ;;
	       "8.1.11") FILENAME="splunk-8.1.11-aa854f643d76-Linux-x86_64.tgz" ;;
	       "8.1.10.1") FILENAME="splunk-8.1.10.1-8bfab9b850ca-Linux-x86_64.tgz" ;;
	    *) echo -e "\033[31mVersion $VERSION not found. Please enter a Splunk Enterprise Version between 9.2.2 and 8.1.10.1.\033[0m" && exit 1 ;;
        esac
    elif [[ "$COMPONENT" == "universal_forwarder" ]]; then
        case "$VERSION" in
           "9.2.1") FILENAME="splunkforwarder-9.2.1-78803f08aabb-Linux-x86_64.tgz" ;;
	       "9.2.0.1") FILENAME="splunkforwarder-9.2.0.1-d8ae995bf219-Linux-x86_64.tgz" ;;
	       "9.2.0") FILENAME="splunkforwarder-9.2.0-1fff88043d5f-Linux-x86_64.tgz" ;;
	       "9.1.5") FILENAME="splunkforwarder-9.1.5-29befd543def-Linux-x86_64.tgz" ;;
	       "9.1.4") FILENAME="splunkforwarder-9.1.4-a414fc70250e-Linux-x86_64.tgz" ;;
	       "9.1.3") FILENAME="splunkforwarder-9.1.3-d95b3299fa65-Linux-x86_64.tgz" ;;
	       "9.1.2") FILENAME="splunkforwarder-9.1.2-b6b9c8185839-Linux-x86_64.tgz" ;;
	       "9.1.1") FILENAME="splunkforwarder-9.1.1-64e843ea36b1-Linux-x86_64.tgz" ;;
	       "9.1.0.1") FILENAME="splunkforwarder-9.1.0.1-77f73c9edb85-Linux-x86_64.tgz" ;;
	       "9.1.0") FILENAME="splunkforwarder-9.1.0-1c86ca0bacc3-Linux-x86_64.tgz" ;;
	       "9.0.9") FILENAME="splunkforwarder-9.0.9-6315942c563f-Linux-x86_64.tgz" ;;
	       "9.0.8") FILENAME="splunkforwarder-9.0.8-4fb5067d40d2-Linux-x86_64.tgz" ;;
	       "9.0.7") FILENAME="splunkforwarder-9.0.7-b985591d12fd-Linux-x86_64.tgz" ;;
	       "9.0.6") FILENAME="splunkforwarder-9.0.6-050c9bca8588-Linux-x86_64.tgz" ;;
	       "9.0.5") FILENAME="splunkforwarder-9.0.5-e9494146ae5c-Linux-x86_64.tgz" ;;
	       "9.0.4") FILENAME="splunkforwarder-9.0.4-de405f4a7979-Linux-x86_64.tgz" ;;
	       "9.0.3") FILENAME="splunkforwarder-9.0.3-dd0128b1f8cd-Linux-x86_64.tgz" ;;
	       "9.0.2") FILENAME="splunkforwarder-9.0.2-17e00c557dc1-Linux-x86_64.tgz" ;;
	       "9.0.10") FILENAME="splunkforwarder-9.0.10-f551b9b500f8-Linux-x86_64.tgz" ;;
	       "9.0.1") FILENAME="splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz" ;;
	       "9.0.0.1") FILENAME="splunkforwarder-9.0.0.1-9e907cedecb1-Linux-x86_64.tgz" ;;
	       "9.0.0") FILENAME="splunkforwarder-9.0.0-6818ac46f2ec-Linux-x86_64.tgz" ;;
	       "8.2.9") FILENAME="splunkforwarder-8.2.9-4a20fb65aa78-Linux-x86_64.tgz" ;;
	       "8.2.8") FILENAME="splunkforwarder-8.2.8-da25d08d5d3e-Linux-x86_64.tgz" ;;
	       "8.2.7.1") FILENAME="splunkforwarder-8.2.7.1-c2b65bc24aea-Linux-x86_64.tgz" ;;
	       "8.2.7") FILENAME="splunkforwarder-8.2.7-2e1fca123028-Linux-x86_64.tgz" ;;
	       "8.2.6.1") FILENAME="splunkforwarder-8.2.6.1-5f0da8f6e22c-Linux-x86_64.tgz" ;;
	       "8.2.6") FILENAME="splunkforwarder-8.2.6-a6fe1ee8894b-Linux-x86_64.tgz" ;;
	       "8.2.5") FILENAME="splunkforwarder-8.2.5-77015bc7a462-Linux-x86_64.tgz" ;;
	       "8.2.4") FILENAME="splunkforwarder-8.2.4-87e2dda940d1-Linux-x86_64.tgz" ;;
	       "8.2.3") FILENAME="splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz" ;;
	       "8.2.2.1") FILENAME="splunkforwarder-8.2.2.1-ae6821b7c64b-Linux-x86_64.tgz" ;;
	       "8.2.2") FILENAME="splunkforwarder-8.2.2-87344edfcdb4-Linux-x86_64.tgz" ;;
	       "8.2.12") FILENAME="splunkforwarder-8.2.12-e973afd6886e-Linux-x86_64.tgz" ;;
	       "8.2.11") FILENAME="splunkforwarder-8.2.11-e73c56f930c5-Linux-x86_64.tgz" ;;
	       "8.2.10") FILENAME="splunkforwarder-8.2.10-417e74d5c950-Linux-x86_64.tgz" ;;
	       "8.2.1") FILENAME="splunkforwarder-8.2.1-ddff1c41e5cf-Linux-x86_64.tgz" ;;
	       "8.2.0") FILENAME="splunkforwarder-8.2.0-e053ef3c985f-Linux-x86_64.tgz" ;;
	       "8.1.9") FILENAME="splunkforwarder-8.1.9-a16db3287b56-Linux-x86_64.tgz" ;;
	       "8.1.8") FILENAME="splunkforwarder-8.1.8-39da583cc695-Linux-x86_64.tgz" ;;
	       "8.1.7") FILENAME="splunkforwarder-8.1.7-79650d4c9dc0-Linux-x86_64.tgz" ;;
	       "8.1.6") FILENAME="splunkforwarder-8.1.6-c1a0dd183ee5-Linux-x86_64.tgz" ;;
	       "8.1.5") FILENAME="splunkforwarder-8.1.5-9c0c082e4596-Linux-x86_64.tgz" ;;
	       "8.1.4") FILENAME="splunkforwarder-8.1.4-17f862b42a7c-Linux-x86_64.tgz" ;;
	       "8.1.3") FILENAME="splunkforwarder-8.1.3-63079c59e632-Linux-x86_64.tgz" ;;
	       "8.1.2") FILENAME="splunkforwarder-8.1.2-545206cc9f70-Linux-x86_64.tgz" ;;
	       "8.1.14") FILENAME="splunkforwarder-8.1.14-7b72da4f30b8-Linux-x86_64.tgz" ;;
	       "8.1.13") FILENAME="splunkforwarder-8.1.13-898c6e996343-Linux-x86_64.tgz" ;;
	       "8.1.12") FILENAME="splunkforwarder-8.1.12-4eb558a8f0b7-Linux-x86_64.tgz" ;;
	       "8.1.11") FILENAME="splunkforwarder-8.1.11-aa854f643d76-Linux-x86_64.tgz" ;;
	       "8.1.10.1") FILENAME="splunkforwarder-8.1.10.1-8bfab9b850ca-Linux-x86_64.tgz" ;;
	       "8.1.10") FILENAME="splunkforwarder-8.1.10-c7993e64d7f2-Linux-x86_64.tgz" ;;
	       "8.1.1") FILENAME="splunkforwarder-8.1.1-08187535c166-Linux-x86_64.tgz" ;;
	       "8.1.0.1") FILENAME="splunkforwarder-8.1.0.1-24fd52428b5a-Linux-x86_64.tgz" ;;
	       "8.1.0") FILENAME="splunkforwarder-8.1.0-f57c09e87251-Linux-x86_64.tgz" ;;
	       "8.0.9") FILENAME="splunkforwarder-8.0.9-153839c8b72f-Linux-x86_64.tgz" ;;
	       "8.0.8") FILENAME="splunkforwarder-8.0.8-70c2fa5ea15d-Linux-x86_64.tgz" ;;
	       "8.0.7") FILENAME="splunkforwarder-8.0.7-cbe73339abca-Linux-x86_64.tgz" ;;
	       "8.0.6") FILENAME="splunkforwarder-8.0.6-152fb4b2bb96-Linux-x86_64.tgz" ;;
	       "8.0.10") FILENAME="splunkforwarder-8.0.10-9f06f1f5a2e9-Linux-x86_64.tgz" ;;
            *) echo -e "\033[31mVersion $VERSION not found. Please enter a Splunk Universal Forwarder Version between 9.2.1 and 8.0.10.\033[0m" && exit 1 ;;
        esac
    fi
fi

if [ "$COMPONENT" == "universal_forwarder" ]; then
    sudo wget -O "$FILENAME" "https://download.splunk.com/products/universalforwarder/releases/$VERSION/linux/$FILENAME" > /dev/null 2>&1 && echo -e "\033[33mDownloaded $FILENAME successfully. proceeding to next stage of untaring the $FILENAME\033[0m"
else
    # Download the Splunk package
    sudo wget -O "$FILENAME" "https://download.splunk.com/products/splunk/releases/$VERSION/linux/$FILENAME" > /dev/null 2>&1 && echo -e "\033[33mDownloaded $FILENAME successfully. proceding to next stage of untaring the $FILENAME\033[0m"
fi

# Extract the filename without extension
filename_base="${FILENAME%.*}"

# Check the file extension and extract accordingly
case "${FILENAME##*.}" in 
    tgz|tar.gz)
        sudo tar xvzf "$FILENAME" -C /opt > /dev/null 2>&1 && echo -e "\033[33mCompleted the process of untaring $FILENAME\033[0m"
        ;;
    deb)
        sudo dpkg -i "$FILENAME" > /dev/null 2>&1 && echo -e "\033[33mCompleted the process of installing $FILENAME\033[0m"
        ;;
    rpm)
        chmod 644 "$FILENAME"
        sudo rpm -i "$FILENAME" > /dev/null 2>&1 && echo -e "\033[33mCompleted the process of installing $FILENAME\033[0m"
        ;;
    *)
        echo -e "\033[31mUnsupported file format: $FILENAME. Please check it.\033[0m"
        exit 1
        ;;
esac

# Change ownership of the Splunk installation
if [ "$COMPONENT" == "universal_forwarder" ]; then
    sudo chown -R "$USERNAME":"$USERNAME" /opt/splunkforwarder 
    # Enable Splunk to start at boot with the new user
    sudo /opt/splunkforwarder/bin/splunk enable boot-start -user "$USERNAME" && echo -e "\033[33mEnabled boot start for $USERNAME for Splunk $COMPONENT\033[0m"
else
    # Change ownership of the Splunk installation
    sudo chown -R "$USERNAME":"$USERNAME" /opt/splunk
    # Enable Splunk to start at boot with the new user
    sudo /opt/splunk/bin/splunk enable boot-start -user "$USERNAME" && echo -e "\033[33mEnabled boot start for $USERNAME for Splunk $COMPONENT\033[0m"
fi

# The paths of the directories to check
dir_path1="/opt/splunk/bin"
dir_path2="/opt/splunkforwarder/bin"

# Use the `-d` test to check if the directories exist
if [ -d "$dir_path1" ] || [ -d "$dir_path2" ]; then
    echo -e "\n"
    echo -e "\033[33mSplunk $COMPONENT $VERSION is Installed Successfully\033[0m"
    echo -e "\n"
	if [ "$COMPONENT" == "universal_forwarder" ]; then
        echo -e "\033[32mStart The Splunk $COMPONENT $VERSION using sudo /opt/splunkforwarder/bin/splunk start --accept-license\033[0m"
	else
	    echo -e "\033[32mStart The Splunk $COMPONENT $VERSION using /opt/splunk/bin/splunk start --accept-license\033[0m"
	fi
else
    echo -e "\033[33mThe Splunk $COMPONENT $VERSION does not exist. Please execute the script once again\033[0m"
fi