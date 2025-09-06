#!/usr/bin/env bash
set -euo pipefail

echo "[1/6] Ensure kind cluster"
if ! kind get clusters | grep -q '^kind$'; then
  kind create cluster ${KIND_CONFIG:+--config "$KIND_CONFIG"}
fi

echo "[2/6] Create namespace"
kubectl apply -f ./.infrastructure/namespace.yml

echo "[3/6] Apply PV"
kubectl apply -f ./.infrastructure/pv.yml

echo "[4/6] Apply PVC"
kubectl apply -f ./.infrastructure/pvc.yml
kubectl -n todoapp wait --for=condition=Bound pvc/pvc-data --timeout=60s || true
kubectl get pv,pvc

echo "[5/6] Apply ConfigMap & Secret"
kubectl apply -f ./.infrastructure/configmap.yml
kubectl apply -f ./.infrastructure/secret.yml

echo "[6/6] Apply Deployment"
kubectl apply -f ./.infrastructure/deployment.yml
kubectl -n todoapp rollout status deploy/todoapp --timeout=120s

echo "Done."
