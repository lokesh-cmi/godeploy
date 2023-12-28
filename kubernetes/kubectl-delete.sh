#!/bin/bash
# Files are ordered in proper order with needed wait for the dependent custom resource definitions to get initialized.
# Usage: bash kubectl-apply.sh

usage(){
 cat << EOF

 Usage: $0 -f
 Description: To delete k8s manifests using the default \`kubectl delete -f\` command
[OR]
 Usage: $0 -k
 Description: To delete k8s manifests using the kustomize \`kubectl delete -k\` command

EOF
exit 0
}

logSummary() {
    echo ""
        echo "#####################################################"
        echo "All resources got deleted successfully."
        echo "#####################################################"
}

default() {
    suffix=k8s
    kubectl delete -f deploygo-${suffix}/
    kubectl delete -f keycloak-${suffix}/
    kubectl delete -f namespace.yml
}

kustomize() {
    kubectl delete -k ./
}


[[ "$@" =~ ^-[fk]{1}$ ]]  || usage;

while getopts ":fk" opt; do
    case ${opt} in
    f ) echo "Applying default \`kubectl delete -f\`"; default ;;
    k ) echo "Applying kustomize \`kubectl delete -k\`"; kustomize ;;
    \? | * ) usage ;;
    esac
done

logSummary
