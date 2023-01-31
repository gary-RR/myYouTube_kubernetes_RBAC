export MASTER_IP_ADDRESS="192.168.0.64"

#Generte a private key
openssl genrsa -out jane.doe.key 2048

#Generate a CSR
#/CN (Common Name) is the username, and /O (Organization) is the group(s) the user belongs to
openssl req -new -key jane.doe.key -out jane.doe.csr \
 -subj "/CN=jane.doe/O=marketing-lead"


#Encode CSR (base64)
#And also have the header and trailer pulled out.
cat jane.doe.csr | base64 | tr -d "\n" > jane.doe.base64.csr

#Submit the CertificateSigningRequest to the API Server
#Key elements, name, request, signerName and usages (must be client auth)
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jane.doe
spec:
  groups:
  - system:authenticated  
  request: $(cat jane.doe.base64.csr)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF


#View the CSRs, it will show as "pending" status
kubectl get certificatesigningrequests

#Approve the CSR (Note, you'll have one hour to apprvoe it, otherwise it will be garbage collected!)
kubectl certificate approve jane.doe

#View the cert requets and its status
kubectl get certificatesigningrequests jane.doe 

#Retrieve the certificate from the CSR object and save it to a file:
kubectl get certificatesigningrequests jane.doe \
  -o jsonpath='{ .status.certificate }'  | base64 --decode > jane.doe.crt 

#Beging constructing a config file for our new user "jane.doe".
#Start by creating the "cluster" section of the config file
kubectl config set-cluster kubernetes \
  --server=https://$MASTER_IP_ADDRESS:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=jane.doe.conf

#Now lets add our "user" section of the config file
kubectl config set-credentials jane.doe \
  --client-key=jane.doe.key \
  --client-certificate=jane.doe.crt \
  --embed-certs=true \
  --kubeconfig=jane.doe.conf

#Create the context section
kubectl config set-context jane.doe@kubernetes  \
  --cluster=kubernetes\
  --user=jane.doe \
  --kubeconfig=jane.doe.conf

#View the completed config for our user "jane.doee"
kubectl config view --kubeconfig=jane.doe.conf


#Cleanup
kubectl delete certificatesigningrequests jane.doe 


