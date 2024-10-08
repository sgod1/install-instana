#!/bin/bash

source ../instana.env
source ./release.env
source ./help-functions.sh

INSTALL_HOME=$(get_install_home)
BIN_HOME=$(get_bin_home)
INSTANA_KUBECTL=$BIN_HOME/kubectl-instana
MANIFEST_DIR=$INSTALL_HOME/instana-operator-manifests

template=${1:-"no-template"}
replace_template=${2:-"no-replace"}
replace=${1:-"no-replace"}

function check_manifest_dir() {
   replace=${1:-"no-replace"}

   check_replace_manifest_dir $MANIFEST_DIR $replace

   if test -d $MANIFEST_DIR; then
      rm -r $MANIFEST_DIR
   fi

   mkdir -p $MANIFEST_DIR
}

function template_manifests() {
   replace_template={1:-"no-replace"}

   if test ! -f $INSTANA_KUBECTL; then
      echo Instana plugin $INSTANA_KUBECTL not found
      exit 1
   fi

   check_manifest_dir $replace_template

   echo ""
   echo Generating Instana operator manifests in $MANIFEST_DIR directory
   echo ""

   $INSTANA_KUBECTL operator template --output-dir $MANIFEST_DIR
}

if compare_values "template" "$template"; then
   template_manifests $replace_template

else
check_manifest_dir $replace

# serviceaccounts/instana-operator
# serviceaccounts/instana-operator created
echo "writing $MANIFEST_DIR/serviceaccounts-instana-operator.yaml"
cat << EOF > $MANIFEST_DIR/serviceaccounts-instana-operator.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: operator
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator
  namespace: instana-operator
EOF

# serviceaccounts/instana-operator-webhook
# serviceaccounts/instana-operator-webhook created
echo "writing $MANIFEST_DIR/serviceaccounts-instana-operator-webhook.yaml"
cat << EOF > $MANIFEST_DIR/serviceaccounts-instana-operator-webhook.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-webhook
  namespace: instana-operator
EOF

# clusterroles/instana-operator
# clusterroles/instana-operator created
echo "writing $MANIFEST_DIR/clusterroles-instana-operator.yaml"
cat << EOF > $MANIFEST_DIR/clusterroles-instana-operator.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/component: operator
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ""
  resources:
  - endpoints
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - get
  - list
  - patch
  - watch
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - persistentvolumeclaims
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ""
  resources:
  - persistentvolumes
  verbs:
  - get
  - list
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - create
  - delete
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - pods/exec
  verbs:
  - create
- apiGroups:
  - ""
  resources:
  - pods/log
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ""
  resources:
  - serviceaccounts
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apiextensions.k8s.io
  resourceNames:
  - cores.instana.io
  resources:
  - customresourcedefinitions
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apiextensions.k8s.io
  resourceNames:
  - datastores.instana.io
  resources:
  - customresourcedefinitions
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apiextensions.k8s.io
  resourceNames:
  - units.instana.io
  resources:
  - customresourcedefinitions
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apps
  resources:
  - deployments/finalizers
  verbs:
  - update
- apiGroups:
  - apps
  resources:
  - statefulsets
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - config.openshift.io
  resources:
  - clusterversions
  verbs:
  - get
- apiGroups:
  - instana.io
  resources:
  - cores
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - instana.io
  resources:
  - cores/finalizers
  verbs:
  - update
- apiGroups:
  - instana.io
  resources:
  - cores/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - instana.io
  resources:
  - units
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - instana.io
  resources:
  - units/finalizers
  verbs:
  - update
- apiGroups:
  - instana.io
  resources:
  - units/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - metrics.k8s.io
  resources:
  - nodes
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - networkpolicies
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - update
  - watch
- apiGroups:
  - projectcontour.io
  resources:
  - httpproxies
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - projectcontour.io
  resources:
  - httpproxies/finalizers
  verbs:
  - update
- apiGroups:
  - projectcontour.io
  resources:
  - httpproxies/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - projectcontour.io
  resources:
  - tlscertificatedelegations
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - projectcontour.io
  resources:
  - tlscertificatedelegations/finalizers
  verbs:
  - update
- apiGroups:
  - projectcontour.io
  resources:
  - tlscertificatedelegations/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - rbac.authorization.k8s.io
  resourceNames:
  - instana-selfhosted-operator
  resources:
  - clusterrolebindings
  verbs:
  - delete
- apiGroups:
  - rbac.authorization.k8s.io
  resourceNames:
  - instana-selfhosted-operator
  resources:
  - clusterroles
  verbs:
  - delete
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - rolebindings
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - roles
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - route.openshift.io
  resources:
  - routes
  - routes/custom-host
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
EOF


# clusterroles/instana-operator-webhook
# clusterroles/instana-operator-webhook created
echo "writing $MANIFEST_DIR/clusterroles-instana-operator-webhook.yaml"
cat << EOF > $MANIFEST_DIR/clusterroles-instana-operator-webhook.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-webhook
rules:
- apiGroups:
  - instana.io
  resources:
  - cores
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - instana.io
  resources:
  - datastores
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - instana.io
  resources:
  - units
  verbs:
  - get
  - list
  - watch
EOF

# clusterrolebindings/instana-operator
# clusterrolebindings/instana-operator created
echo "writing $MANIFEST_DIR/clusterrolebindings-instana-operator.yaml"
cat << EOF > $MANIFEST_DIR/clusterrolebindings-instana-operator.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/component: operator
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: instana-operator
subjects:
- kind: ServiceAccount
  name: instana-operator
  namespace: instana-operator
EOF

# clusterrolebindings/instana-operator-webhook
# clusterrolebindings/instana-operator-webhook created
echo "writing $MANIFEST_DIR/clusterrolebindings-instana-operator-webhook.yaml"
cat << EOF > $MANIFEST_DIR/clusterrolebindings-instana-operator-webhook.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-webhook
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: instana-operator-webhook
subjects:
- kind: ServiceAccount
  name: instana-operator-webhook
  namespace: instana-operator
EOF

# roles/instana-operator-leader-election
# roles/instana-operator-leader-election created
echo "writing $MANIFEST_DIR/roles-instana-operator-leader-election.yaml"
cat << EOF > $MANIFEST_DIR/roles-instana-operator-leader-election.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/component: operator
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-leader-election
  namespace: instana-operator
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete
- apiGroups:
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
EOF

# rolebindings/instana-operator-leader-election
# rolebindings/instana-operator-leader-election created
echo "writing $MANIFEST_DIR/rolebindings-instana-operator-leader-election.yaml"
cat << EOF > $MANIFEST_DIR/rolebindings-instana-operator-leader-election.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/component: operator
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-leader-election
  namespace: instana-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: instana-operator-leader-election
subjects:
- kind: ServiceAccount
  name: instana-operator
  namespace: instana-operator
EOF

# services/instana-operator-webhook
# services/instana-operator-webhook created
echo "writing $MANIFEST_DIR/services-instana-operator-webhook.yaml"
cat << EOF > $MANIFEST_DIR/services-instana-operator-webhook.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-webhook
  namespace: instana-operator
spec:
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
  sessionAffinity: None
  type: ClusterIP
EOF

# deployments/instana-operator updated
# deployments/instana-operator created
echo "writing $MANIFEST_DIR/deployments-instana-operator.yaml"
cat << EOF > $MANIFEST_DIR/deployments-instana-operator.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: operator
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator
  namespace: instana-operator
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app.kubernetes.io/component: operator
      app.kubernetes.io/name: instana
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app.kubernetes.io/component: operator
        app.kubernetes.io/name: instana
        app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
    spec:
      containers:
      - args:
        - /app/instana-operator
        env:
        - name: WATCH_NAMESPACE
        - name: POD_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        image: ${PRIVATE_REGISTRY}/infrastructure/instana-operator:${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
        imagePullPolicy: IfNotPresent
        name: instana-operator
        ports:
        - containerPort: 8081
          name: http
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: http
            scheme: HTTP
          initialDelaySeconds: 5
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources:
          limits:
            ephemeral-storage: 1Gi
          requests:
            cpu: 500m
            ephemeral-storage: 1Gi
            memory: 2Gi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /tmp
          name: tmpdir
      dnsPolicy: ClusterFirst
      enableServiceLinks: false
      imagePullSecrets:
      - name: instana-registry
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      serviceAccount: instana-operator
      serviceAccountName: instana-operator
      terminationGracePeriodSeconds: 300
      tolerations:
      - effect: NoSchedule
        key: kubernetes.io/arch
        operator: Equal
        value: amd64
      volumes:
      - emptyDir: {}
        name: tmpdir
EOF

# deployments/instana-operator-webhook updated
# deployments/instana-operator-webhook created
echo "writing $MANIFEST_DIR/deployments-instana-operator-webhook.yaml"
cat << EOF > $MANIFEST_DIR/deployments-instana-operator-webhook.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-webhook
  namespace: instana-operator
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app.kubernetes.io/component: webhook
      app.kubernetes.io/name: instana
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app.kubernetes.io/component: webhook
        app.kubernetes.io/name: instana
        app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
    spec:
      containers:
      - args:
        - /app/instana-operator-webhook
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        image: ${PRIVATE_REGISTRY}/infrastructure/instana-operator:${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
        imagePullPolicy: IfNotPresent
        name: instana-operator-webhook
        ports:
        - containerPort: 9443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 5
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources:
          limits:
            ephemeral-storage: 1Gi
          requests:
            cpu: 500m
            ephemeral-storage: 1Gi
            memory: 2Gi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/webhook/certs
          name: cert
          readOnly: true
        - mountPath: /tmp
          name: tmpdir
      dnsPolicy: ClusterFirst
      enableServiceLinks: false
      imagePullSecrets:
      - name: instana-registry
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      serviceAccount: instana-operator-webhook
      serviceAccountName: instana-operator-webhook
      terminationGracePeriodSeconds: 30
      tolerations:
      - effect: NoSchedule
        key: kubernetes.io/arch
        operator: Equal
        value: amd64
      volumes:
      - name: cert
        secret:
          defaultMode: 420
          secretName: instana-operator-webhook
      - emptyDir: {}
        name: tmpdir
EOF

# certificates/instana-operator-webhook
# certificates/instana-operator-webhook created
echo "writing $MANIFEST_DIR/certificates-instana-operator-webhook.yaml"
cat << EOF > $MANIFEST_DIR/certificates-instana-operator-webhook.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  labels:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-webhook
  namespace: instana-operator
spec:
  dnsNames:
  - instana-operator-webhook.instana-operator
  - instana-operator-webhook.instana-operator.svc
  issuerRef:
    kind: Issuer
    name: instana-operator-webhook
  secretName: instana-operator-webhook
  subject:
    organizations:
    - instana
EOF

# issuers/instana-operator-webhook
# issuers/instana-operator-webhook created
echo "writing $MANIFEST_DIR/issuers-instana-operator-webhook.yaml"
cat << EOF > $MANIFEST_DIR/issuers-instana-operator-webhook.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  labels:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-webhook
  namespace: instana-operator
spec:
  selfSigned: {}
EOF

# validatingwebhookconfigurations/instana-operator-webhook-validating updated
# validatingwebhookconfigurations/instana-operator-webhook-validating created
echo "writing $MANIFEST_DIR/validatingwebhookconfigurations-instana-operator-webhook-validating.yaml"
cat << EOF > $MANIFEST_DIR/validatingwebhookconfigurations-instana-operator-webhook-validating.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app.kubernetes.io/component: webhook
    app.kubernetes.io/name: instana
    app.kubernetes.io/version: ${INSTANA_RELEASE}-${INSTANA_SUBRELEASE}
  name: instana-operator-webhook-validating
webhooks:
- admissionReviewVersions:
  - v1
  clientConfig:
    caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUROakNDQWg2Z0F3SUJBZ0lSQUp4TkV0WEZDcjd3YUNpVmZxZnJtUUl3RFFZSktvWklodmNOQVFFTEJRQXcKRWpFUU1BNEdBMVVFQ2hNSGFXNXpkR0Z1WVRBZUZ3MHlOREV3TURFeU16TTBORE5hRncweU5ERXlNekF5TXpNMApORE5hTUJJeEVEQU9CZ05WQkFvVEIybHVjM1JoYm1Fd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3CmdnRUtBb0lCQVFDVjNXdXM1WnA0endiczZTMjFpVWVCSXpmVlFYUXNjTjdoMERDVlhCNWU3a2kzcmNsbWNlNG0KaTVTT09DZUV2bEo3c2Q4WjdKeGw0SSt2elZnVDJQb05sUTVucTIyN05SY29BYkpob1JJNXdlN2I3a0MxS1ZBZwpDMmlDVXdEelJlRm1mS1h5cm9DSVgrM1NEdWZ4d1JScEMzQWRUWW15ekt1TElIeDZ0cFlpaTRjaWVKQUxxRVkwCkhmTEdkTEhkTStTZGZPSnNhZ0twYlhnTEFTQTFtU21IcC9iTGIrY2l6NHlpZStlaXhPa0cvOVdCTy9UN3RCcDAKQzU3NFk0ZzViL0pSeHk4L2EyTkpyMkFQVFJmRUtYMmdrQ2xTNEtYZWl1N0llNkxLU2R1cC9JTjlhWEl6TVJSYgpRazIxc0FDNlM1WWFSTTAwU2hKS21XYmlpZWtoUzFiSkFnTUJBQUdqZ1lZd2dZTXdEZ1lEVlIwUEFRSC9CQVFECkFnV2dNQXdHQTFVZEV3RUIvd1FDTUFBd1l3WURWUjBSQkZ3d1dvSXBhVzV6ZEdGdVlTMXZjR1Z5WVhSdmNpMTMKWldKb2IyOXJMbWx1YzNSaGJtRXRiM0JsY21GMGIzS0NMV2x1YzNSaGJtRXRiM0JsY21GMGIzSXRkMlZpYUc5dgpheTVwYm5OMFlXNWhMVzl3WlhKaGRHOXlMbk4yWXpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQVExRUUrUmFYClptTHNtTThrRzREeExCRlFGMC9rcGtlKzFzTDdxNlBDbjNuaXNXTFhXVnJJTzdVamRROFRia2dFMnFLSUhqOUMKQVZYZ0F1ME9rcmNoMjRDQkFJa0pkTzJHVDI3d3YwakhaVlh4Wld3QXAvV1BhMzZQNkVhTEZSeWpXU2FyYU1KNQo0QWE0dW1yNmV3Tkk3YmV0MkQ1MktUZEJicnFQbEdIeHIyd2o3Qy9WMlZITkZuYVJiTDFGUkYxdEZSei92SDNrCkoxN3dWcFBXczg2d1ZpRmxGc1pvaUlyZi9NdVB4M0JjUGxLMDVTT0pxNFdhb3FKYk9ZR1A2c28wd1JOZzdhWmgKRWRNL3ptQkxrcFFiTmNrbjNMcEM0TFdSRkNNM0p6Qm04ZmdFR1AzeHl2RWtMRnRuMmFra2YwN3RkYnpURUpPYQowSk1EOHpCTHNXbG9ydz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    service:
      name: instana-operator-webhook
      namespace: instana-operator
      path: /validate-instana-io-v1beta2-core
      port: 443
  failurePolicy: Fail
  matchPolicy: Equivalent
  name: vcore.kb.io
  namespaceSelector: {}
  objectSelector: {}
  rules:
  - apiGroups:
    - instana.io
    apiVersions:
    - v1beta2
    operations:
    - CREATE
    - UPDATE
    resources:
    - cores
    scope: '*'
  sideEffects: None
  timeoutSeconds: 10
- admissionReviewVersions:
  - v1
  clientConfig:
    caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUROakNDQWg2Z0F3SUJBZ0lSQUp4TkV0WEZDcjd3YUNpVmZxZnJtUUl3RFFZSktvWklodmNOQVFFTEJRQXcKRWpFUU1BNEdBMVVFQ2hNSGFXNXpkR0Z1WVRBZUZ3MHlOREV3TURFeU16TTBORE5hRncweU5ERXlNekF5TXpNMApORE5hTUJJeEVEQU9CZ05WQkFvVEIybHVjM1JoYm1Fd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3CmdnRUtBb0lCQVFDVjNXdXM1WnA0endiczZTMjFpVWVCSXpmVlFYUXNjTjdoMERDVlhCNWU3a2kzcmNsbWNlNG0KaTVTT09DZUV2bEo3c2Q4WjdKeGw0SSt2elZnVDJQb05sUTVucTIyN05SY29BYkpob1JJNXdlN2I3a0MxS1ZBZwpDMmlDVXdEelJlRm1mS1h5cm9DSVgrM1NEdWZ4d1JScEMzQWRUWW15ekt1TElIeDZ0cFlpaTRjaWVKQUxxRVkwCkhmTEdkTEhkTStTZGZPSnNhZ0twYlhnTEFTQTFtU21IcC9iTGIrY2l6NHlpZStlaXhPa0cvOVdCTy9UN3RCcDAKQzU3NFk0ZzViL0pSeHk4L2EyTkpyMkFQVFJmRUtYMmdrQ2xTNEtYZWl1N0llNkxLU2R1cC9JTjlhWEl6TVJSYgpRazIxc0FDNlM1WWFSTTAwU2hKS21XYmlpZWtoUzFiSkFnTUJBQUdqZ1lZd2dZTXdEZ1lEVlIwUEFRSC9CQVFECkFnV2dNQXdHQTFVZEV3RUIvd1FDTUFBd1l3WURWUjBSQkZ3d1dvSXBhVzV6ZEdGdVlTMXZjR1Z5WVhSdmNpMTMKWldKb2IyOXJMbWx1YzNSaGJtRXRiM0JsY21GMGIzS0NMV2x1YzNSaGJtRXRiM0JsY21GMGIzSXRkMlZpYUc5dgpheTVwYm5OMFlXNWhMVzl3WlhKaGRHOXlMbk4yWXpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQVExRUUrUmFYClptTHNtTThrRzREeExCRlFGMC9rcGtlKzFzTDdxNlBDbjNuaXNXTFhXVnJJTzdVamRROFRia2dFMnFLSUhqOUMKQVZYZ0F1ME9rcmNoMjRDQkFJa0pkTzJHVDI3d3YwakhaVlh4Wld3QXAvV1BhMzZQNkVhTEZSeWpXU2FyYU1KNQo0QWE0dW1yNmV3Tkk3YmV0MkQ1MktUZEJicnFQbEdIeHIyd2o3Qy9WMlZITkZuYVJiTDFGUkYxdEZSei92SDNrCkoxN3dWcFBXczg2d1ZpRmxGc1pvaUlyZi9NdVB4M0JjUGxLMDVTT0pxNFdhb3FKYk9ZR1A2c28wd1JOZzdhWmgKRWRNL3ptQkxrcFFiTmNrbjNMcEM0TFdSRkNNM0p6Qm04ZmdFR1AzeHl2RWtMRnRuMmFra2YwN3RkYnpURUpPYQowSk1EOHpCTHNXbG9ydz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    service:
      name: instana-operator-webhook
      namespace: instana-operator
      path: /validate-instana-io-v1beta2-unit
      port: 443
  failurePolicy: Fail
  matchPolicy: Equivalent
  name: vunit.kb.io
  namespaceSelector: {}
  objectSelector: {}
  rules:
  - apiGroups:
    - instana.io
    apiVersions:
    - v1beta2
    operations:
    - CREATE
    - UPDATE
    resources:
    - units
    scope: '*'
  sideEffects: None
  timeoutSeconds: 10
EOF

echo "writing $MANIFEST_DIR/cores-instana-io.yaml"
cp ./crd-cores-instana-io.yaml $MANIFEST_DIR

echo "writing $MANIFEST_DIR/units-instana-io.yaml"
cp ./crd-units-instana-io.yaml $MANIFEST_DIR

fi
