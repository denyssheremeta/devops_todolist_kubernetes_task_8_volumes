#!/bin/bash

echo "Creating Kubernetes cluster using kind"
kind create cluster --config cluster.yml

echo "Creating namespace"
kubectl apply -f ./.infrastructure/namespace.yml

echo "Creating other manifests"
kubectl apply -f ./.infrastructure/

echo "Done!"