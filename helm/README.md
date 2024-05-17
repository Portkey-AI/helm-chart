## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.


To install the portkeyenterprise chart:

    helm install portkey-app ./helm --namespace portkeyai --create-namespace  

To uninstall the chart:

    helm uninstall portkey-app --namespace portkeyai 

Optional tunneling port (for local testing)

    kubectl port-forward <kubectl-pod> -n portkeyai 8787:8787