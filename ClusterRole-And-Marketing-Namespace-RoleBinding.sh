cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:      
  name: cluster-pod-reader-role
rules:
- apiGroups: [""] # '""' represents the "core" or "v1" API group.
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: marketing-pod-reader-binding  
  namespace: marketing
subjects:
- kind: User
  name: jane.doe
  apiGroup: rbac.authorization.k8s.io
roleRef:  
  kind: ClusterRole 
  name: cluster-pod-reader-role # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl auth can-i list pods -n marketing --as=jane.doe

kubectl auth can-i list pods -n default --as=jane.doe

kubectl auth can-i create deployments -n marketing --as=jane.doe


#Cleanup
kubectl delete ClusterRole cluster-pod-reader-role
kubectl delete RoleBinding marketing-pod-reader-binding  -n marketing
