kubectl create ns marketing

kubectl auth can-i list pods -n marketing --as=john.doe

cat <<EOF | kubectl -n marketing apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: marketing
  name: marketing-pod-reader
rules:
- apiGroups: [""] # '""' represents the "core" or "v1" API group.
  resources: ["pods"]
  #resourceNames: ["marketing-pod"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: marketing-pod-reader-binding
  namespace: marketing
subjects:
- kind: User
  name: john.doe
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: marketing-pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl auth can-i list pods -n marketing --as=john.doe
kubectl auth can-i create deployments -n marketing --as=john.doe

#Cleanup
kubectl delete Role marketing-pod-reader -n marketing
kubectl delete RoleBinding marketing-pod-reader-binding -n marketing

