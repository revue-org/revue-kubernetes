# Revue: Kubernetes Deployment

[K3s](https://k3s.io/) has been chosen as the orchestrator for the deployment of the Revue system,
a lightweight Kubernetes distribution that is easy to install and operate.
In this repo, an example of cluster and all configurations
needed to deploy the system are provided and a description for every component of the system.
Moreover, you can find the step-by-step guide to create a K3s cluster on a Raspberry PIs 5.

Since Revue has a microservices architecture, 
it is necessary to create several configuration files for each service following their specific requirements.

For core services of the system, the following configurations are provided:
- **Deployment**: responsible for creating pods and managing their lifecycle.
- **Service**: type ClusterIP, with no need to be exposed outside the cluster due to the presence of the Ingress Controller (API Gateway).
- **Ingress**: to expose the service outside the cluster through the Ingress Controller.
- **Persistent Volume Claim**: to store data that needs to persist even after the pod is deleted.
- **ConfigMap**: to store configuration data and database initialization scripts.

Every service is accessible through the Ingress Controller, 
which is responsible for routing the requests to the correct service.
In this case, the Ingress Controller is [Traefik](https://traefik.io/), 
a modern HTTP reverse proxy and load balancer that can be used to expose services outside the cluster.


## Step-by-step guide to create a K3s cluster on Raspberry PIs 5

### Prerequisites
- At least two Raspberry PIs that can communicate with each other.
- Preinstalled OS and available SSH connection.
- A basic understanding of Kubernetes, K3s and kubectl.

First of all, you need to set up the network configuration of the Raspberry PIs to access them.
To do this, you have to edit the `/etc/NetworkManager/system-connections/` file and add the following configuration:

```bash
[ipv4]
method=manual
address1=RASPBERRY_STATIC_IP(`E.g.192.168.1.30/24,192.168.1.1`)
dns=192.168.1.1;8.8.8.8;
```
And then
```bash
sudo systemctl restart NetworkManager
```

Then, to set the configuration of K3s in the Raspberry PIs, 
you have to go to the `config.txt` and `cmdline.txt` files in the `/boot/firmware/` folder and:

In `config.txt`: add a line enabling `arm_64bit=1`
And in `cmdline.txt` add this: (N.B. no new line allowed)
`cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory`

Then activate iptables:

```bash
sudo apt-get update
sudo apt-get install iptables
sudo iptables -F
```
`iptables` has been activated because K3s will use it to manage the network internally.

Now everything is ready to install K3s in the primary node, to install it simply run:
```bash
curl -sfL https://get.k3s.io | K3s_KUBECONFIG_MODE="644" sh -
```

Everything can work only with one node, but to have a real cluster you need to add at least a child node. 
To do this, you have to get the token of the primary node and use it to add the child node.

Primary node token retrieval:

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```
The output will be something like this:
```
K106b7da6871bbae660bcf20134027051018d8cdab619fd12c184ba388c1::server:0d0ead5bedbcacc01a74878f1dcc597a
```

Now, repeat the installation of K3s on the child node, but this time you have to specify the token of the primary node:

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN="YOUR_TOKEN" K3S_URL="https://YOUR_PRIMARY_NODE_STATIC_IP:6443" K3S_NODE_NAME="YOUR_CHILD_NODE_NAME" sh -
```
The cluster, if everything went well, is now ready, and you can check the status of the nodes by running:
```bash
kubectl get nodes
```

Now one more part is needed to complete the cluster, the Load Balancer.
In this guide, [MetalLB](https://metallb.universe.tf/) is used, a load balancer for bare metal Kubernetes clusters.

Command to add a Load Balancer:
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
```
Now that MetalLB is installed, you have to configure it giving it an IP address pool to use. 
This pool must be in the same subnet as the Raspberry PIs, and it must be a range of IP addresses that are not used by other devices in the network.
The function is to assign an IP address to the Ingress Controller, which will be used to expose the services outside the cluster.
Moreover, every service that needs to be exposed outside the cluster will use an IP address from this pool.

Example of address pool configuration:
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ip-address-pool
  namespace: metallb-system # namespace of the LB MetalLB
spec:
  addresses:
  - 192.168.1.50-192.168.1.200
```
To apply the configuration, you have to save it in a file and then run:
```bash
kubectl apply -f your_file.yaml
```

## Other useful information

### Socket
Sockets are yet supported by Traefik, you have only to make sure that the transport is set to `websocket` in the configuration.

### Traefik installation
To install Traefik on the cluster, you can use Helm, a package manager for Kubernetes.
To install Helm, you can follow the official guide [here](https://helm.sh/docs/intro/install/).

N.B. If you want to use Helm, 
you have to set the `KUBECONFIG` environment variable to the path of the K3s configuration file:
```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

Now install Traefik by running:
```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm upgrade traefik traefik/traefik -f /path/to/your/values.yaml
```

### SSH
To access the Raspberry PIs, you can use the `ssh` command,
but to make it easier, you can add the Raspberry PIs to the `~/.ssh/config` file.

To copy some configuration files in the Raspberry PIs, you can use the `scp` command:
```bash
scp -r your_folder/ pi@your_pi_ip:/path/to/destination
```

