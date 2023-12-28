#!/bin/bash
# Files are ordered in proper order with needed wait for the dependent custom resource definitions to get initialized.
# Usage: bash kubectl-apply.sh

usage(){
 cat << EOF

 Usage: $0 -f
 Description: To apply k8s manifests using the default \`kubectl apply -f\` command
[OR]
 Usage: $0 -k
 Description: To apply k8s manifests using the kustomize \`kubectl apply -k\` command
[OR]
 Usage: $0 -s
 Description: To apply k8s manifests using the skaffold binary \`skaffold run\` command

EOF
exit 0
}

logSummary() {
    echo ""
        echo "#####################################################"
        echo "Please find the below useful endpoints,"
        echo "Gateway - http://minikube_ip_placeholder:30200"
        echo "Keycloak - http://minikube_ip_placeholder:30001/"
        echo "#####################################################"
}

default() {
    suffix=k8s
    kubectl apply -f namespace.yml
    kubectl create configmap minikube-cm  --from-literal=minikube-ip=$(kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}') -n go
    kubectl apply -f keycloak-${suffix}/
    until [ $(curl -LI http://minikube_ip_placeholder:30001/realms/master -o /dev/null -w '%{http_code}\n' -s) == 200 ]; do
        echo "Waiting for the keycloak server to get initialised";
        sleep 5;
    done
    kubectl apply -f deploygo-${suffix}/
}

kustomize() {
    kubectl apply -k ./
}

scaffold() {
    // this will build the source and apply the manifests the K8s target. To turn the working directory
    // into a CI/CD space, initilaize it with `skaffold dev`
    skaffold run
}

[[ "$@" =~ ^-[fks]{1}$ ]]  || usage;

while getopts ":fks" opt; do
    case ${opt} in
    f ) echo "Applying default \`kubectl apply -f\`"; default ;;
    k ) echo "Applying kustomize \`kubectl apply -k\`"; kustomize ;;
    s ) echo "Applying using skaffold \`skaffold run\`"; scaffold ;;
    \? | * ) usage ;;
    esac
done

logSummary
