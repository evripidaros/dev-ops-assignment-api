set -a
source .env
set +a

# Add Docker's official GPG key:
sudo apt-get -y update &&
sudo apt-get -y install ca-certificates curl &&
sudo install -m 0755 -d /etc/apt/keyrings &&
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &&
sudo chmod a+r /etc/apt/keyrings/docker.asc &&

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
sudo apt-get -y update  &&

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &&

# Create the docker group. Add your user to the docker group.
sudo groupadd docker 
sudo usermod -aG docker $USER

# Create fastapi-net network and pull the stable image
docker network create fastapi-net
docker pull tzionasev/fastapi:stable
docker tag tzionasev/fastapi:stable "${DOCKERHUB_USERNAME}"/fastapi:stable
docker push "${DOCKERHUB_USERNAME}"/fastapi:stable
