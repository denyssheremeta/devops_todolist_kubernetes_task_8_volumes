# INSTRUCTION.md

## 1. Deploy resources

    ./bootstrap.sh

Creates:

- Namespace: `todoapp`
- PV: `pv-data` (1Gi, RWX, standard, Delete)
- PVC: `pvc-data` (1Gi, RWX, standard)
- ConfigMap: `app-config`
- Secret: `app-secret`
- Deployment: `todoapp` (PVC → `/app/data`, ConfigMap → `/app/configs` (RO), Secret → `/app/secrets` (RO))

---

## 2. Validate app is running

    kubectl -n todoapp get pods -l app=todoapp -o wide
    kubectl -n todoapp rollout status deploy/todoapp
    kubectl -n todoapp logs deploy/todoapp --tail=50

    POD=$(kubectl -n todoapp get pod -l app=todoapp -o jsonpath='{.items[0].metadata.name}')
    kubectl -n todoapp exec "$POD" -- curl -sf http://localhost:8080/api/health
    kubectl -n todoapp exec "$POD" -- curl -sf http://localhost:8080/api/ready

---

## 3. Validate PV/PVC

    kubectl get pv pv-data
    kubectl -n todoapp get pvc pvc-data

Expected: `STATUS Bound`, `CAPACITY 1Gi`, `ACCESS MODES RWX`, `STORAGECLASS standard`, `RECLAIMPOLICY Delete`.

---

## 4. Validate ConfigMap mount

    kubectl -n todoapp exec "$POD" -- ls -l /app/configs
    kubectl -n todoapp exec "$POD" -- ls -1 /app/configs
    kubectl -n todoapp exec "$POD" -- sh -c 'for f in /app/configs/*; do echo "--- $f"; cat "$f"; echo; done'
    kubectl -n todoapp exec "$POD" -- sh -c 'touch /app/configs/_write_test' \
      && echo "Unexpected: /app/configs is writable" || echo "OK: /app/configs is read-only"

---

## 5. Validate Secret mount

    kubectl -n todoapp exec "$POD" -- ls -l /app/secrets
    kubectl -n todoapp exec "$POD" -- cat /app/secrets/<secret-file>
    kubectl -n todoapp exec "$POD" -- sh -c 'touch /app/secrets/_write_test' \
      && echo "Unexpected: /app/secrets is writable" || echo "OK: /app/secrets is read-only"

---

## 6. Validate PVC mount at `/app/data`

    kubectl -n todoapp exec "$POD" -- sh -c 'echo ok > /app/data/pv_write_test && ls -l /app/data && cat /app/data/pv_write_test'

---

## 7. Success criteria

- Pod is **Running**, readiness/liveness return OK
- `/app/configs` contains **ConfigMap files**, **read-only**
- `/app/secrets` contains **Secret files**, **read-only**
- `/app/data` allows **write** (test file visible)
- PV/PVC are in **Bound** state and match requirements
