obtener el fichero config de kubernetes desde gke con gcloud una vez creado el cluster:

gcloud container clusters get-credentials my-gke-cluster-lab --region us-central1

instalar ingress nginx

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml