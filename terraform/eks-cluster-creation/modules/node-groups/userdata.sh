MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex

# EKS Bootstrap Script
/etc/eks/bootstrap.sh '${cluster_name}' \
  --b64-cluster-ca '${cluster_ca_cert}' \
  --apiserver-endpoint '${cluster_endpoint}' \
  --kubelet-extra-args '--max-pods=110'

# Custom userdata
${custom_userdata}

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure kubectl for ec2-user
mkdir -p /home/ec2-user/.kube
cat > /home/ec2-user/.kube/config <<EOFKUBE
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${cluster_ca_cert}
    server: ${cluster_endpoint}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - eks
        - get-token
        - --cluster-name
        - ${cluster_name}
EOFKUBE

chown -R ec2-user:ec2-user /home/ec2-user/.kube

# System optimizations
echo "vm.max_map_count=524288" >> /etc/sysctl.conf
echo "fs.file-max=131072" >> /etc/sysctl.conf
sysctl -p

--==MYBOUNDARY==--

