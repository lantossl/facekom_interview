#!/bin/bash

# Function to prompt the user to choose a version from the available options
select_docker_version() {
    echo "Available versions of Docker Engine:"
    apt-cache madison docker-ce | awk '{ print $3 }'
    read -p "Enter the version you want to install (leave empty for the latest version): " version_choice
}

# Query the version and ask the user to choose
select_docker_version

# If the user's choice is empty, set the version to "latest"
if [ -z "$version_choice" ]; then
    VERSION_STRING="latest"
else
    VERSION_STRING="$version_choice"
fi

# 1. Uninstall old versions
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove -y $pkg;
done

# 2. Install dependencies
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 3. Add GPG key of the repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Set up Docker's repository
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine and docker-compose
sudo apt-get update # update the cache

# Use if statement to select the appropriate command based on VERSION_STRING
if [ "$VERSION_STRING" = "latest" ]; then
  # Install the latest version
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose
else
  # Install a specific version
  sudo apt-get install -y docker-ce="$VERSION_STRING" docker-ce-cli="$VERSION_STRING" containerd.io docker-buildx-plugin docker-compose
fi

# 6. Enable and start services at boot time
sudo systemctl enable docker.service --now
sudo systemctl enable containerd.service --now

# 7. Test the installed Docker Engine
sudo docker run hello-world

