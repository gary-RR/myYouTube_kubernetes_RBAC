cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:      
    name: manage-pods
    labels: 
      acme.com/aggregate-to-support: "true"
rules:
- apiGroups: [""] 
  resources: ["pods","pods/logs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:      
    name: manage-endpoints-services
    labels:
      acme.com/aggregate-to-support: "true"
rules:
- apiGroups: [""] 
  resources: ["endpoints","services"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:      
    name: manage-deployments
    labels:
      acme.com/aggregate-to-support: "true"
rules:
- apiGroups: ["apps"] 
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:  
    name: manage-daemonsets
    labels:
      acme.com/aggregate-to-support: "true"
rules:
- apiGroups: ["apps"] 
  resources: ["daemonsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: support
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      acme.com/aggregate-to-support: "true"
rules: [] # The API Server fills in the rules form other ClusterRoles with matching label.
---
EOF


cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: marketing-support-binding  
  namespace: marketing
subjects:
- kind: User
  name: jane.doe
  apiGroup: rbac.authorization.k8s.io
roleRef:  
  kind: ClusterRole 
  name: support # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl auth can-i list pods -n marketing --as=jane.doe

kubectl auth can-i delete daemonsets -n marketing --as=jane.doe

kubectl auth can-i delete daemonsets -n marketing --as=jane.doe

#Remove "manage-daemonsets" ClusterRole role from "support" ClusterRole
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:  
    name: manage-daemonsets
    labels:
      acme.com/aggregate-to-support: "no"
rules:
- apiGroups: ["apps"] 
  resources: ["daemonsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
EOF

#Can Jane still operate on "daemonsets" 
kubectl auth can-i delete daemonsets -n marketing --as=jane.doe


#Cleanup
kubectl delete ClusterRole manage-pods 
kubectl delete ClusterRole manage-endpoints-services
kubectl delete ClusterRole manage-deployments
kubectl delete ClusterRole manage-daemonsets
kubectl delete RoleBinding marketing-support-binding -n marketing
kubectl delete ClusterRole support