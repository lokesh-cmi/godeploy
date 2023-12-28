#!/bin/bash

# Define the functions to call

#minikube
function minikube {
     echo -e "You have opted for minikube cluster"
    # Add code here to execute the action for minikube
    echo "Initiating the minikube...."
    echo ""
    echo -n "Continue with the destroying Infrastructure,(yes/no):"
    read user_continue_action
    if [ "$user_continue_action" == "yes" ]; then
    echo "Destroying the Infrastructure in our Minikube cluster....."
        # List of directories to process
        directories=(
        "./istio-monitoring"
        "./istio"
        "./eck"
        )

        # Loop through each directory and execute command
        for dir in "${directories[@]}"
        do
            if [ -d "$dir" ]; then
                echo "Processing directory: $dir"
                cd "$dir" || exit
                # Execute your command here
                echo "Auto destroying terraform in $dir"
                terraform destroy -auto-approve
                cd ..
            else
                echo "Directory $dir does not exist"
            fi
        done
      echo ""
      echo -e "Minikube Infrastructure was destroyed successfully!\U0001F63B\033[0m"
      echo ""
      echo -e "\033[1;31mMake sure you delete the ECR manually.\U0001F431\033[0m"
      echo ""
    else
        echo ""
        echo -e "Looks like you have already destroyed the Infrastructure, Thank you!\U0001F431"
        echo ""
    fi
}

############################ SCRIPT STARTS ##########################

# Check if figlet is installed
if [ "$(uname -m)" = "x86_64" ]; then
    if ! which figlet > /dev/null; then
        # Install figlet using apt-get
        sudo apt-get -y install figlet
    fi
elif [ "$(uname -m)" = "arm64" ]; then
    if ! which figlet > /dev/null; then
        # Install figlet using Homebrew
        brew install figlet
    fi
else
    echo "Unsupported architecture: $(uname -m)"
    exit 1
fi

# Use figlet to print "AutoDeploy"
figlet -f slant "AutoDestroy"
echo ""
minikube
