export MASTER_IP_ADDRESS="192.168.0.64"

#Generte a private key
openssl genrsa -out terry.jones.key 2048

#system:masters
#marketing-admin
#Generate a CSR
#/CN (Common Name) is the username, and /O (Organization) is the group(s) the user belongs to
openssl req -new -key terry.jones.key -out terry.jones.csr \
 -subj "/CN=terry.jones/O=marketing-admin"


#Encode CSR (base64)
#And also have the header and trailer pulled out.
cat terry.jones.csr | base64 | tr -d "\n" > terry.jones.base64.csr

#Submit the CertificateSigningRequest to the API Server
#Key elements, name, request, signerName and usages (must be client auth)
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: terry.jones
spec:
  groups:
  - system:authenticated  
  request: $(cat terry.jones.base64.csr)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF


#View the CSRs, it will show as "pending" status
kubectl get certificatesigningrequests

#Approve the CSR (Note, you'll have one hour to apprvoe it, otherwise it will be garbage collected!)
kubectl certificate approve terry.jones

#View the cert requets and its status
kubectl get certificatesigningrequests terry.jones 

#Retrieve the certificate from the CSR object and save it to a file:
kubectl get certificatesigningrequests terry.jones \
  -o jsonpath='{ .status.certificate }'  | base64 --decode > terry.jones.crt 

#Beging constructing a config file for our new user "terry.jones".
#Start by creating the "cluster" section of the config file
kubectl config set-cluster kubernetes \
  --server=https://$MASTER_IP_ADDRESS:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=terry.jones.conf

#Now lets add our "user" section of the config file
kubectl config set-credentials terry.jones \
  --client-key=terry.jones.key \
  --client-certificate=terry.jones.crt \
  --embed-certs=true \
  --kubeconfig=terry.jones.conf

#Create the context section
kubectl config set-context terry.jones@kubernetes  \
  --cluster=kubernetes\
  --user=terry.jones \
  --kubeconfig=terry.jones.conf

#View the completed config for our user "terry.jonese"
kubectl config view --kubeconfig=terry.jones.conf


#Cleanup
kubectl delete certificatesigningrequests terry.jones 
