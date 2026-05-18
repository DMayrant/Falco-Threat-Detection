# Falco for Cloud Native Runtime Security 🦅

Validation and adding wiz-helm

```bash 
curl -L https://falcosecurity.github.io/charts 

helm repo add falcosecurity https://falcosecurity.github.io/charts

helm repo update
```
Installing Falco

create a ns first then install WIZ

```bash
kubectl create ns falco --dry-run=client -o yaml > falco-ns.yaml 

helm install my-falco falcosecurity/falco --version 8.0.5 -n falco -f values.yaml

helm repo add falcosecurity https://falcosecurity.github.io/charts -n falco
  ```

