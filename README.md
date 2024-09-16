# Revue Kubernetes Deployment

In this repository, you can find all the configuration files needed to deploy the Revue within a Kubernetes cluster.

Remember that to deploy Revue, you have to use `deploy` script present in the main [Revue repository](https://github.com/revue-org/revue).

In the following, you can find a step-by-step guide to create a [K3s](https://k3s.io/) (a lightweight Kubernetes distribution) cluster on Raspberry PIs 5.

## Creating a K3s cluster running on Raspberries PI 5

### Prerequisites

-   At least two Raspberry PIs that can communicate with each other.
-   Preinstalled OS and available SSH connection.
-   A basic understanding of Kubernetes, K3s and kubectl.

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

### ARP problem

Running the cluster on Raspberries can bring to a problematic about ARP tables.
This happen because Raspberries by default does not respond to ARP request when using Wi-Fi.
The possible workaround is to set the raspberries in promiscuous mode runnning the command:

```bash
sudo ifconfig <<DEVICE>> promisc
E.g. sudo ifconfig wlan0 promisc
```

More info in the [MetalLB troubleshooting](https://metallb.io/troubleshooting/) section.

### Helm

To properly run Revue, you need to install Helm, a package manager for Kubernetes.

Helm is used to install Traefik, Prometheus and Grafana, which are needed to run Revue.

Note that you have to set the `KUBECONFIG` environment variable to the path of the K3s configuration file:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

### SSH

To access the Raspberry PIs, you can use the `ssh` command,
but to make it easier, you can add the Raspberry PIs to the `~/.ssh/config` file.

To copy some configuration files in the Raspberry PIs, you can use the `scp` command:

```bash
scp -r your_folder/ pi@your_pi_ip:/path/to/destination
```

## Revue deployment

Take a look to the [deployment section](link-to-deployment-section) of the Revue repository for a detailed guide to run Revue on the cluster
