# define variables
resource_group="aks-demo-rg"
location="eastus"

az group create --name $resource_group --location $location

az network vnet create \
 --resource-group $resource_group \
 --name "aks-demo-vnet" \
 --address-prefixes 10.0.0.0/8 \
 --subnet-name "aks-demo-subnet" \
 --subnet-prefix 10.0.0.0/16

subnet_cluster_id=$(az network vnet subnet show --resource-group $resource_group --vnet-name "aks-demo-vnet" --name "aks-demo-subnet" --query id -o tsv)

# create AKS cluster
az aks create \
 --resource-group $resource_group \
 --name aks-demo \
 --enable-managed-identity \
 --network-plugin azure \
 --vnet-subnet-id $subnet_cluster_id \
 --docker-bridge-address 172.17.0.1/16 \
 --service-cidr 10.2.0.0/24 \
 --dns-service-ip 10.2.0.10 \
 --enable-cluster-autoscaler \
 --min-count 1 \
 --max-count 20 \
 --node-count 3 \
 --enable-managed-identity \
 --generate-ssh-keys \
--enable-aad \
--enable-azure-rbac \
--yes

# Assign youself AKS Azure RBAC cluster admin role
myuserid=$(az ad signed-in-user show --query "userPrincipalName" -o tsv)
# Get AKS cluster Resource ID
aks_id=$(az aks show -g $resource_group -n "aks-demo" --query id -o tsv)
# replace AAD-ENTITY-ID with your account email
az role assignment create --role "Azure Kubernetes Service RBAC Cluster Admin" --assignee $myuserid --scope $aks_id

# enable App Gateway ingress controller
az aks enable-addons --resource-group $resource_group \
    --name aks-demo -a ingress-appgw \
    --appgw-subnet-cidr 10.3.0.0/24 \
    --appgw-name aks-demo-appgw