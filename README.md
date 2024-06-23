# docker-vaultwarden-backup

A simple Alpine based docker image with sqlite3 to run online backups against the vaultwarden database as part of a Kubernetes CronJob.

## Todo
Investigate statically compiling sqlite3 to further reduce container image footprint. 

## Kubernetes Cronjob Example
After the Cronjob, you can run another job to ship the PVC to a Restic repository.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: ghcr.io/trexx/docker-vaultwarden-backup:3.20.1
            command:
              - /bin/sh
              - -c
              - sqlite3 "${DATA_DIR}/db.sqlite3" ".backup '${DATA_DIR}/db.sqlite3.bak'"
            env:
              - name: DATA_DIR
                value: /data
            volumeMounts:
              - mountPath: /data
                name: data
          restartPolicy: OnFailure
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: data-vaultwarden-0
```