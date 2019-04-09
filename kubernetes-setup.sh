# sudo su -

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update && sudo apt install docker-ce

# Turn swap off
sudo swapoff -a

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install kubernetes
sudo apt-get update && sudo apt-get install -y apt-transport-https && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && sudo apt-get update


# kubectl install
sudo apt-get install kubeadm=1.13.4-00 kubelet=1.13.4-00 kubectl=1.13.4-00 kubernetes-cni=0.6.0-00


# Update iptables
sudo sysctl net.bridge.bridge-nf-call-iptables=1

# Run cluster (without remote kubectl access)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Run cluster with remote kubectl access
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=192.0.0.1

# Cluster permissions:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Running system dependencies of kubernetes
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

# Verify
kubectl get pods --all-namespaces

# Make master node as single node cluster
kubectl taint nodes --all node-role.kubernetes.io/master-

# Cleaning all iptables
sudo systemctl stop kubelet
sudo systemctl stop docker
sudo iptables --flush
sudo iptables -tnat --flush
sudo systemctl start kubelet
sudo systemctl start docker

References:

https://raaaimund.github.io/tech/2018/10/23/create-single-node-k8s-cluster/

https://medium.com/@vivek_syngh/setup-a-single-node-kubernetes-cluster-on-ubuntu-16-04-6412373d837a/
