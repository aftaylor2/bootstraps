#!/usr/bin/env bash
# Create autoscaling Kubernetes cluster on GKE
# Installs cluster, ingress-nginx and cert-manager configured for LetsEncrypt
# Installs helm locally on macOS or GNU/Linux
# by: Andrew Taylor < aftaylor2@gmail.com >

# NOTES:
# MUST HAVE kubectl and gcloud INSTALLED
# Basic examples of client install commented out in code. You may wish to
# review docs to ensure you have updated clients.
# gcloud: https://cloud.google.com/sdk/docs/install
# kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl/

# EDIT THESE VARIABLES
PROJECT=my-project
CLUSTER=cluster01
REGION=us-east1
ZONE=us-east1-b
MIN_NODES=3
MAX_NODES=5
MACHINE_TYPE=n2-standard-8
DISK_SIZE_GB=200
LETSENCRYPT_EMAIL=user@domain.com

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Install helm on GNU/Linux - Debian/Ubuntu based systems
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" |
        sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm

# Install kubectl
# curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"
# chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Install / Upgrade homebrew
    # export BREW_URL=https://raw.githubusercontent.com/Homebrew/install/master/install.sh)
    # /bin/bash -c "$(curl -fsSL ${BREW_URL}"
    # Install kubectl
    # brew install kubectl
    # Install helm on macOS
    brew install helm
fi

gcloud beta container --project "${PROJECT}" clusters create "${CLUSTER}" \
    --zone "${ZONE}" \
    --no-enable-basic-auth \
    --cluster-version "1.17.12-gke.500" \
    --machine-type "${MACHINE_TYPE}" \
    --image-type "COS" \
    --disk-type "pd-ssd" \
    --disk-size "${DISK_SIZE_GB}" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --num-nodes "${MIN_NODES}" \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --network "projects/${PROJECT}/global/networks/default" \
    --subnetwork "projects/${PROJECT}/regions/${REGION}/subnetworks/default" \
    --default-max-pods-per-node "110" \
    --enable-autoscaling \
    --min-nodes "${MIN_NODES}" \
    --max-nodes "${MAX_NODES}" \
    --no-enable-master-authorized-networks \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing \
    --enable-autoupgrade \
    --enable-autorepair \
    --max-surge-upgrade 1 \
    --max-unavailable-upgrade 0 \
    --enable-shielded-nodes

gcloud container clusters get-credentials $CLUSTER --zone $ZONE--project $PROJECT

kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)

# Deploy nginx Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx
kubectl scale --replicas=$MIN_NODES deployment/ingress-nginx-controller

# Deploy cert manager ( check github for newest version )
export CM_URL=https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml
kubectl apply --validate=false -f $CM_URL

# Get Load Balancer Public IP address
LB_IP=$(kubectl get svc -n default | grep ingress-nginx-controller | grep LoadBalancer | awk {'print $4'})

echo 'Load Balancer Public IP:' ${LB_IP}
echo 'Create DNS A records for hosts that need HTTPS Ingress. Use ./dnsAdd.sh script'

cat <<EOF >clusterissuer-prod.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: $LETSENCRYPT_EMAIL
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-issuer-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

kubectl apply -f clusterissuer-prod.yaml
