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
    PORTKEY_API_KEY: 
    PORTKEY_ORGANISATION_ID: 
    LOG_STORE: 
    MONGO_DB_CONNECTION_URL: 
    MONGO_DATABASE: 
    MONGO_COLLECTION_NAME: 
    S3_REGION: 
    S3_ACCESS_KEY: 
    S3_SECRET_KEY: 
    S3_GENERATIONS_BUCKET: 
    ANALYTICS_STORE: 
    CLICKHOUSE_USER: 
    CLICKHOUSE_PASSWORD: 
    CLICKHOUSE_HOST: 
    CLICKHOUSE_LOG_TABLE: 
    CLICKHOUSE_FEEDBACK_TABLE: 
    CLICKHOUSE_KV_HASH_MAP_TABLE:
    CACHE_STORE: 
    REDIS_URL: 
    REDIS_TLS_ENABLED: 
```
### Analytics Store

Supported `ANALYTICS_STORE` is `clickhouse`.
The following values are needed for storing analytics data.

```
    CLICKHOUSE_USER: 
    CLICKHOUSE_PASSWORD: 
    CLICKHOUSE_HOST: 
    CLICKHOUSE_LOG_TABLE: 
    CLICKHOUSE_FEEDBACK_TABLE: 
    CLICKHOUSE_KV_HASH_MAP_TABLE:
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
S3_REGION
S3_ACCESS_KEY
S3_SECRET_KEY
S3_GENERATIONS_BUCKET
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

## Installation
Install the portkeyenterprise chart:

    helm install portkey-app ./helm/enterprise --namespace portkeyai --create-namespace  

## Uninsatallation
Uninstall the chart:

    helm uninstall portkey-app --namespace portkeyai 

## Port Tunnel
Optional tunneling port (for local testing)

    kubectl port-forward <kubectl-pod> -n portkeyai 8787:8787