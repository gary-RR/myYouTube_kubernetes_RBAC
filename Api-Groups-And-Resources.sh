#Establish the proxy. By default, it uses local port 8081 to interact with the API server.
kubectl proxy &
#View overall API hierarchy 
curl http://localhost:8001/

#The “core” API group “/api/v1” is the oldest group and contains many resources such as pods, namespaces, services, etc.
#If we execute the command below, we’ll see what resources are available under the core API group and for each resource what 
#verbs and other attributes are supported. For brevity, only the Pod resource listed below (Listing 4.1.2) but there are many other resources available in the core API group:
curl http://localhost:8001/api/v1

#To view all resource types 
kubectl api-resources -o wide    

#if say we are for looking for a specific resource, say “daemonsets”, we could do something like:
kubectl api-resources -o wide | grep daemonsets



