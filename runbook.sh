#!/bin/bash 
set -euo pipefail

NS="falco" 
DEPLOY="falco"
FALCO_DEPLOY="my-falco-falcosidekick"
SVC="my-falco-falcosidekick"

# Helm installation verification
if ! helm list -n "$NS" | grep -q "$FALCO_DEPLOY"; then
  echo "Helm release $FALCO_DEPLOY not found in namespace $NS"
  exit 1
fi

echo "-----------------------------"
echo "Checking Helm release in falco namespace"
kubectl get all -n "$NS"
kubectl get pods -n "$NS"
kubectl get svc -n "$NS"

echo "-----------------------------"
echo "Checking logs for $FALCO_DEPLOY"
kubectl logs deploy/"$FALCO_DEPLOY" -n "$NS" --tail=50
kubectl describe deploy/"$FALCO_DEPLOY" -n "$NS"

echo "-----------------------------"
echo "Checking falco service"
kubectl get svc -n "$NS" | grep falco
kubectl describe svc "$SVC" -n "$NS"

echo "-----------------------------"
echo "Service endpoint testing with port-forwarding"
kubectl port-forward svc/"$SVC" -n "$NS" 2801:2801 &
PORT_FORWARD_PID=$!
cleanup() {
  kill "$PORT_FORWARD_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "------------------------------"
echo "Testing local forwarded endpoint"
curl -s http://"localhost:2801/healthz"

echo "-----------------------------"
echo "Testing falco service endpoint"
curl -s http://my-falco-falcosidekick.falco.svc.cluster.local:2801/healthz

echo "-----------------------------"
echo "Internal service discovery test"
POD=$(kubectl get pods -l run=curl -o jsonpath='{.items[0].metadata.name}')
kubectl --wait --for=condition=Ready pod/"$POD" --max-time=60s
kubectl exec -it "$POD" -- curl -s http://"$SVC"."$NS".svc.cluster.local:2801/healthz
