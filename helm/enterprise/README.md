## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

## Setup
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

2. Use the Env parameters shared

```
environment:
  ...
  data:
    SERVICE_NAME: 
    LOG_STORE: 
    MONGO_DB_CONNECTION_URL: 
    MONGO_DATABASE: 
    MONGO_COLLECTION_NAME: 
    LOG_STORE_REGION: 
    LOG_STORE_ACCESS_KEY: 
    LOG_STORE_SECRET_KEY: 
    LOG_STORE_GENERATIONS_BUCKET: 
    ANALYTICS_STORE: 
    ANALYTICS_STORE_ENDPOINT: 
    ANALYTICS_STORE_USER: 
    ANALYTICS_STORE_PASSWORD: 
    ANALYTICS_LOG_TABLE: 
    ANALYTICS_FEEDBACK_TABLE: 
    CACHE_STORE: 
    REDIS_URL: 
    REDIS_TLS_ENABLED: 
    PORTKEY_CLIENT_AUTH: 
    ORGANISATIONS_TO_SYNC: 
```
### Analytics Store

Supported `ANALYTICS_STORE` is `clickhouse`.
The following values are needed for storing analytics data.

```
    ANALYTICS_STORE_ENDPOINT: 
    ANALYTICS_STORE_USER: 
    ANALYTICS_STORE_PASSWORD: 
    ANALYTICS_LOG_TABLE:
    ANALYTICS_FEEDBACK_TABLE:
```

### Log Store
`LOG_STORE` can be `mongo`, `s3`, `wasabi` or `gcs`.

If `LOG_STORE` is `mongo`, the following are needed
```
    MONGO_DB_CONNECTION_URL: 
    MONGO_DATABASE: 
    MONGO_COLLECTION_NAME: 
```

If `LOG_STORE` is `s3` or `wasabi` or `gcs`, the following values are mandatory
```
    LOG_STORE_REGION: 
    LOG_STORE_ACCESS_KEY: 
    LOG_STORE_SECRET_KEY: 
    LOG_STORE_GENERATIONS_BUCKET:
```

All the above mentioned are S3 Compatible document storages and interopable with S3 API. You need to  generate `Access Key` and `Secret Key` from the respective providers.

### Cache Store
If `CACHE_STORE` is set as `redis`, redis instance also get deployed in the cluster. 

If you are using custom redis, then leave it blank.

The following values are mandatory

```
    REDIS_URL: 
    REDIS_TLS_ENABLED: 
```

`REDIS_URL` defaults to `redis://redis:6379`
`REDIS_TLS_ENABLED` defaults to `false`

### Sync

The following are  mandatory

```
    PORTKEY_CLIENT_AUTH:
    ORGANISATIONS_TO_SYNC:
```

## Installation
Install the portkeyenterprise chart:

    helm install portkey-app ./helm/enterprise --namespace portkeyai --create-namespace  

## Uninsatallation
Uninstall the chart:

    helm uninstall portkey-app --namespace portkeyai 

## Port Tunnel
Optional tunneling port (for local testing)

    kubectl port-forward <kubectl-pod> -n portkeyai 8787:8787