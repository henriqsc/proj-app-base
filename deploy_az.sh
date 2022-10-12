#Kubernetes provisioning script using Azure with az client
#Az client requires a principal account to be created and granted Contributor role for the signature

#docker build -t hscadore/projeto-backend:1.0 app-base/backend
#docker build -t hscadore/projeto-database:1.0 app-base/database
#docker push hscadore/projeto-backend:1.0
#docker push hscadore/projeto-database:1.0

#The following values are provided by the principal account
APP_CLIENT_ID=""
APP_CLIENT_SECRET=""
APP_CLIENT_TENANT=""

echo "Logging in..."
az login --service-principal -u $APP_CLIENT_ID -p $APP_CLIENT_SECRET -t $APP_CLIENT_TENANT

#These providers need to be registered on the subscription. Registration might take time (minutes), we're assuming that both providers are registered already.
echo "Checking providers (Make sure both are registered):"
az provider show -n Microsoft.OperationsManagement -o table
az provider show -n Microsoft.OperationalInsights -o table
#az provider register --namespace Microsoft.OperationsManagement
#az provider register --namespace Microsoft.OperationalInsights

echo "Creating AKS Cluster..."
az group create --name kubernetes2-deploy --location eastus
az aks create -g kubernetes2-deploy -n AKS_cluster --enable-managed-identity --node-count 2 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys

#After deploy install kubectl cli using az command. This might not be necessary if you already have kubectl.
#az aks install-cli

#Connects kubectl to AKS
echo "Connecting to Kubernetes cluster..."
az aks get-credentials --resource-group kubernetes2-deploy  --name AKS_cluster


echo "Provisionando..."
kubectl apply -f app-base/services.yml
kubectl apply -f app-base/azure-disk-pvc.yml
kubectl apply -f app-base/database/deployment.yml
kubectl apply -f app-base/backend/deployment.yml
