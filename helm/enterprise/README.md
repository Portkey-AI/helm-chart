## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Update the following details in `values.yaml`
1. Use Docker token details shared
```
imageCredentials:
- name: portkeyenterpriseregistrycredentials
  create: true
  registry: kubernetes.io/dockerconfigjson
  username: <docker-user>
  password: <docker-pwd>
```

Use the Env parameters shared

```
environment:
  ...
  data:
    MONGO_DB_CONNECTION_URL: 
    MONGO_DATABASE: 
    MONGO_COLLECTION_NAME: 
    CLICKHOUSE_USER: 
    CLICKHOUSE_PASSWORD: 
    CLICKHOUSE_HOST: 
    CLICKHOUSE_LOG_TABLE: 
    CLICKHOUSE_FEEDBACK_TABLE: 
    CLICKHOUSE_KV_HASH_MAP_TABLE:
    PORTKEY_API_KEY: 
    PORTKEY_ORGANISATION_ID: 
    SERVICE_NAME: portkeyenterprise
```

To install the portkeyenterprise chart:

    helm install portkey-app ./helm/enterprise --namespace portkeyai --create-namespace  

To uninstall the chart:

    helm uninstall portkey-app --namespace portkeyai 

Optional tunneling port (for local testing)

    kubectl port-forward <kubectl-pod> -n portkeyai 8787:8787