#!/bin/bash

CLUSTER_NAME=" my-gke-cluster-lab"
REGION="us-west1-a"
SA_NAME="admin-service-account"
NAMESPACE="default"

SERVER=$(gcloud container clusters describe $CLUSTER_NAME --region $REGION --format="value(endpoint)")
echo "La url del server es: https://$SERVER"

gcloud container clusters describe $CLUSTER_NAME --region $REGION --format="value(masterAuth.clusterCaCertificate)" | base64 --decode > ca.crt
echo "Descargado el certificado del cluster"

kubectl get secrets -n $NAMESPACE | grep $SA_NAME

TOKEN=$(kubectl get secret admin-sa-secret -n $NAMESPACE -o jsonpath='{.data.token}' | base64 --decode)
echo "token descargado"

echo "creando config kubeconfig-ci"
cat <<EOF > kubeconfig-ci
apiVersion: v1
kind: Config
clusters:
- name: gke-cluster
  cluster:
    server: https://$SERVER
    certificate-authority-data: $(base64 -w 0 ca.crt)  # Se usa el certificado del cluster
contexts:
- name: gke-ci-context
  context:
    cluster: gke-cluster
    user: ci-user
current-context: gke-ci-context
users:
- name: ci-user
  user:
    token: $TOKEN
EOF