# Revue K3S Deployment

K3S has been chosen as the orchestrator for the deployment of the Revue system,
a lightweight Kubernetes distribution that is easy to install and operate.
In this repo, an example of cluster and all configurations needed to deploy the system are provided. 
It is composed by Raspberry PIs 5.


Configurations for Raspberry PI 5 Cluster.
This guide starts with the prerequisites of at least two raspberries that can communicate with each other,
with a preinstalled OS and an available ssh connection.

sudo nano /etc/NetworkManager/system-connections/
[ipv4]
method=manual
address1=192.168.1.30/24,192.168.1.1
dns=192.168.1.1;8.8.8.8;

sudo systemctl restart NetworkManager


Then, to set properly configuration of k3s in raspberries, according too k3s docs, you have to go to the config.txt and cmdline.txt files in /boot/firmware/ folder and:

In config.txt: add line enabling arm_64bit=1
And in cmdline.txt add this: (not new line allowed)
cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory


Then activate iptables:

sudo apt-get update
sudo apt-get install iptables
sudo iptables -F

Install K3S in the master node:

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -


Then: get the token of the master: K10a77c97505255c35f9ab16e8e8f9cf652ae2c2261c84f942ba73bd095befed1b0::server:95151f2b88811168b863e47118935d0c

With

sudo cat /var/lib/rancher/k3s/server/node-token command.

Then: add child with:

curl -sfL https://get.k3s.io | K3S_TOKEN="K106b7da6871bbae660bcf2012e7c38617b00c4de18d8cdab619fd12c184ba388c1::server:0d0ead5bedbcacc01a74878f1dcc597a" K3S_URL="https://192.168.1.10:6443" K3S_NODE_NAME="slave1" sh -



Add a Load Balancer:

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

Socket transport websocket


helm upgrade traefik traefik/traefik -f /path/to/your/values.yaml



If you want to use helm
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml






Comandi utili:

Passaggio file e specifiche su master usando ssh.
scp -r Desktop/remote_specs/specifications/ master@192.168.1.10:/home/master/

Passaggio file DA master:
scp -r master@192.168.1.10:/home/master/specifications Desktop/specs_remote_frontend_test


Comandi utile per pushare le nuove immagini sul docker hub:

docker buildx build --platform linux/arm64 --push . -f frontend/Dockerfile -t letsdothisshared/revue-frontend:test

docker buildx build --platform linux/arm64 --push . -f auth/Dockerfile -t letsdothisshared/revue-auth:test


docker.io/letsdothisshared/revue-auth:test
docker.io/letsdothisshared/revue-auth@sha256:3a77211bbabc230d7bceb315b1f4304810bfd494131e7d4080c1505d5e06f44b


