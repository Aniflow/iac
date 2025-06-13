# iac
Infrastructure as code

Authenticate AKS to access dockerhub
```bash
kubectl create secret docker-registry dockerhub-secret \
  --docker-username=<docker-user> \
  --docker-password=<docker-pat> \
  --docker-email=<docker-email> \
  --docker-server=https://index.docker.io/v1/
```

Create service principle for CICD actions
```bash
az ad sp create-for-rbac \
  --name "<your-sp-name>" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/<your-resource-group> \
  --sdk-auth
```