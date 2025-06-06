# iac
Infrastructure as code

kubectl create secret docker-registry dockerhub-secret \
  --docker-username=<docker-user> \
  --docker-password=<docker-pat> \
  --docker-email=<docker-email> \
  --docker-server=https://index.docker.io/v1/
