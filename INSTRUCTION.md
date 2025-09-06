### 1. Run the bootstrap script:

```bash
./bootstrap.sh
```

This script will deploy the following resources: PersistentVolume (pv.yml), PersistentVolumeClaim (pvc.yml), ConfigMap, Secret, Deployment using the PVC, ConfigMap, and Secret

### 2. Validate that the application is running

Check the status of the pods:

```bash
kubectl get pods
kubectl describe pod <pod-name>
```

### 3. Validate PersistentVolume and PersistentVolumeClaim

```bash
kubectl get pv
kubectl get pvc
```

### 4. Validate Secret mount

```bash
ls -l /app/secrets
cat /app/secrets/<secret-file-name>
```
