# docker-static-sqlite3

A statically compiled sqlite3 in an empty container image (~1.1 MB)

## Applications
I use this image as part of a Kubernetes Cronjob to run .backup against VaultWardens sqlite database. Volsync will then ship the PVC off to BackBlaze.

## Kubernetes Cronjob Example

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
            image: ghcr.io/trexx/docker-static-sqlite3:3.46.0
            command:
              - /sqlite3
              - /data/db.sqlite3
              - .backup /data/db.sqlite3.bak
            volumeMounts:
              - mountPath: /data
                name: data
          restartPolicy: OnFailure
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: data-vaultwarden-0
```
