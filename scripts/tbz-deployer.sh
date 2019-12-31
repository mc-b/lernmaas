#!/bin/bash
#
#   Veroeffentlicht den TBZ-Deployer.
#
#   Der TBZ-Deployer ermoeglicht fuer jeden Lehrenden einer Klasse mehrere Container in einem Namespace zu starten.
#
#   Der TBZ-Deployer basiert auf einer Vertiefungsarbeit an der TBZ HF von Niklaus Liechti - https://github.com/nliechti/tbz_hf_va
#

cat <<%EOF% | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: tbz-deployer
  labels:
    app: tbz-deployer
spec:
  type: LoadBalancer
  ports:
    - port: 7000
      nodePort: 32700       
      protocol: TCP
  selector:
    app: tbz-deployer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tbz-deployer
  labels:
    app: tbz-deployer
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tbz-deployer
  template:
    metadata:
      labels:
        app: tbz-deployer
    spec:
      containers:
        - name: tbz-deployer
          image: nliechti/tbz_deployer:2
          ports:
            - containerPort: 7000
              name: tbz-deployer
          env:
            - name: EMAIL_SMTP_SERVER
              value: "smtp.gmail.com"
            - name: EMAIL_SMTP_PORT
              value: "587"
            - name: EMAIL_SMTP_USER
              value: ""
            - name: EMAIL_SMTP_PASSWORD
              value: ""
            - name: KUBERNETES_MASTER_URL
              value: "$(kubectl config view -o=jsonpath='{ .clusters[0].cluster.server }')"
            - name: KUBERNETES_CLIENT_CERT_DATA
              value: "$(kubectl config view --raw -o=jsonpath='{ .users[0].user.client-certificate-data }')"
            - name: KUBERNETES_CLIENT_KEY_DATA
              value: "$(kubectl config view --raw -o=jsonpath='{ .users[0].user.client-key-data }')"
%EOF%
               