cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:      
  name: cluster-pod-reader
rules:
- apiGroups: [""] # '""' represents the "core" or "v1" API group.
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-pod-reader-binding 
subjects:
- kind: Group
  name: marketing-admin
  apiGroup: rbac.authorization.k8s.io
roleRef:  
  kind: ClusterRole 
  name: cluster-pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl config use-context terry.jones@kubernetes --kubeconfig=terry.jones.conf
kubectl auth can-i list pods -n marketing --kubeconfig=terry.jones.conf

kubectl auth can-i list pods -n default --kubeconfig=terry.jones.conf

kubectl auth can-i create deployments -n marketing --kubeconfig=terry.jones.conf

#Cleanup
kubectl delete ClusterRole cluster-pod-reader
kubectl delete ClusterRoleBinding cluster-pod-reader-binding 