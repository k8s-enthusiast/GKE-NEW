# ssh to VM and run this to debug
# sudo google_metadata_script_runner --script-type startup --debug

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/bin/kubectl
# Configure cluster
export KUBECONFIG="~/.kube/config"
gcloud container clusters get-credentials ${cluster_name} --region ${region} --project ${project}
export cluster_admin_user=$(gcloud config get-value account)
echo $cluster_admin_user
# Apply kubectl for API proxy
kubectl get clusterrolebinding bastion-sa-admin-binding &> /dev/null || kubectl create clusterrolebinding bastion-sa-admin-binding --clusterrole cluster-admin --user $cluster_admin_user
echo "${deployment_yaml}" > k8s_api_proxy_deployment.yaml
echo "${service_yaml}" > k8s_api_proxy_service.yaml
echo "${pod_security_policy_yaml}" > psp.yaml
echo "${ip_masq_agent_yaml}" > ip-masq-agent.yaml

# Apply policy for pod security and api-proxy
kubectl create namespace api-proxy

kubectl apply -f psp.yaml
kubectl apply -f k8s_api_proxy_deployment.yaml -n api-proxy
kubectl apply -f k8s_api_proxy_service.yaml -n api-proxy

#Wait for api-proxy to be up and allow cross region access to it
while [ $(curl -I --write-out %%{http_code} -m 4 -s -o /dev/null http://${internal_loadbalancer_ip}:8443) != 400 ]; do
  sleep 5;
done
FORWARDING_RULE_NAME=$(gcloud compute forwarding-rules list --filter="IP_ADDRESS='${internal_loadbalancer_ip}'" | tail -1 | cut -d ' ' -f 1 )
gcloud compute forwarding-rules update $FORWARDING_RULE_NAME --allow-global-access --region=${region}

# Adding ip-masq-agent configMap
sed -i "s|NONMASQUERADECIDRS|${non_masquerade_cidrs}|g" ip-masq-agent.yaml
kubectl delete configmap ip-masq-agent -n kube-system
kubectl apply -f ip-masq-agent.yaml
