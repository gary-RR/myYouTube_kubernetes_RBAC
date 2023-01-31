export MASTER_IP_ADDRESS="192.168.0.64"

#Generte a private key
openssl genrsa -out john.doe.key 2048

#Generate a CSR (Certificate Signing Request)
#/CN (Common Name) is the username, and /O (Organization) is the group(s) the user belongs to
openssl req -new -key john.doe.key -out john.doe.csr \
 -subj "/CN=john.doe/O=marketing-lead"


#Encode CSR (base64)
#And also have the header and trailer pulled out.
cat john.doe.csr | base64 | tr -d "\n" > john.doe.base64.csr

#Submit the CertificateSigningRequest to the API Server
#Key elements, name, request, signerName and usages (must be client auth)
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: john.doe
spec:
  groups:
  - system:authenticated  
  request: $(cat john.doe.base64.csr)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF


#View the CSRs, it will show as "pending" status
kubectl get certificatesigningrequests

#Approve the CSR (Note, you'll have one hour to apprvoe it, otherwise it will be garbage collected!)
kubectl certificate approve john.doe

#View the cert requets and its status
kubectl get certificatesigningrequests john.doe 

#Retrieve the certificate from the CSR object and save it to a file:
kubectl get certificatesigningrequests john.doe \
  -o jsonpath='{ .status.certificate }'  | base64 --decode > john.doe.crt 

#Beging constructing a config file for our new user "john.doe".
#Start by creating the "cluster" section of the config file
kubectl config set-cluster kubernetes \
  --server=https://$MASTER_IP_ADDRESS:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=john.doe.conf

#Now lets add our "user" section of the config file
kubectl config set-credentials john.doe \
  --client-key=john.doe.key \
  --client-certificate=john.doe.crt \
  --embed-certs=true \
  --kubeconfig=john.doe.conf

#Create the context section
kubectl config set-context john.doe@kubernetes  \
  --cluster=kubernetes\
  --user=john.doe \
  --kubeconfig=john.doe.conf

#View the completed config for our user "john.doee"
kubectl config view --kubeconfig=john.doe.conf

#Cleanup
kubectl delete certificatesigningrequests john.doe 
