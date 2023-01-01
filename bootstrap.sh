#!/bin/bash

set -e
set -o pipefail
set -o nounset


kubectl create namespace argocd-common --dry-run=client -o yaml | kubectl apply -f -

kubectl -n argocd-common create secret tls custom-unsealing-keys \
  --cert="./secrets/unseal.crt" \
  --key="./secrets/unseal.key"

kubectl -n argocd-common label secret custom-unsealing-keys sealedsecrets.bitnami.com/sealed-secrets-key=active


adminpassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

# install ArgoCD
helm dependency update argocd

echo "If you want to allow access to k3s on TrueNAS from other machine run this on the TrueNAS box:"
echo "iptables -R INPUT 4 -s 192.168.0.0/16 -j ACCEPT"

# export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
helm upgrade --install argocd argocd -n argocd --create-namespace --wait --timeout 120s --values globalValues.yaml
kubectl patch secret -n argocd argocd-secret -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" ${adminpassword} | tr -d ':\n')'"}}'
echo "ArgoCD admin password has been set to: ${adminpassword}"

helm upgrade --install argocd-config argocd-config -n argocd --wait --timeout 120s --values globalValues.yaml


# kubectl port-forward -n argocd svc/argocd-server 8080:80
