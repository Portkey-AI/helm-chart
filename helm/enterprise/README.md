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
    LOG_STORE_AWS_ROLE_ARN:
    LOG_STORE_AWS_EXTERNAL_ID:
    AWS_ASSUME_ROLE_ACCESS_KEY_ID:
    AWS_ASSUME_ROLE_SECRET_ACCESS_KEY:
    AWS_ASSUME_ROLE_REGION:
    AZURE_STORAGE_ACCOUNT: 
    AZURE_STORAGE_KEY: 
    AZURE_STORAGE_CONTAINER:
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
`LOG_STORE` can be `mongo`, `s3`, `s3_assume`, `wasabi`, `gcs` or `azure`.

**1. Mongo**

If you want to use Mongo or Document DB for storage, `LOG_STORE` will be `mongo`. The following values are mandatory
```
  MONGO_DB_CONNECTION_URL: 
  MONGO_DATABASE: 
  MONGO_COLLECTION_NAME: 
```
If you are using pem file for authentication, you need to follow the below additional steps

- In `resources-config.yaml` file supply pem file details under data(for example, document_db.pem) along with its content.
- In `values.yaml` use the below config
```
volumes:
- name: shared-folder
  configMap:
    name: resource-config
volumeMounts:
- name: shared-folder
  mountPath: /etc/shared/<shared_pem>
  subPath: <shared_pem>
```
The `MONGO_DB_CONNECTION_URL` should use /etc/shared<shared_pem> in tlsCAFile param. For example, `mongodb://<user>:<password>@<host>?tls=true&tlsCAFile=/etc/shared/document_db.pem&retryWrites=false`

**2. S3 Compatible Blob storage**

Portkey supports following S3 compatible Blob storages 
- S3
- GCS
- Wasabi

The above mentioned S3 Compatible document storages are interopable with S3 API. 

The following values are mandatory
```
  LOG_STORE_REGION: 
  LOG_STORE_ACCESS_KEY: 
  LOG_STORE_SECRET_KEY: 
  LOG_STORE_GENERATIONS_BUCKET:
```

You need to  generate `Access Key` and `Secret Key` from the respective providers as mentioned below.

**2.1. AWS S3**

`LOG_STORE` will be `s3`.

Access Key can be generated as mentioned here - 
https://aws.amazon.com/blogs/security/wheres-my-secret-access-key

Security Credentials -> Access Keys -> Create Access Keys

**2.2. Google Cloud Storage**

`LOG_STORE` will be `gcs`.

Only s3 interoble way of gcs is supported currently. 
https://cloud.google.com/storage/docs/interoperability

https://cloud.google.com/storage/docs/authentication/hmackeys

Cloud Storage -> Settings -> Interopability -> Access keys for service accounts -> Create Key for Service Accounts

**2.3. Wasabi**

`LOG_STORE` will be `wasabi`.

Access Key can be generated from

Access Keys ->  Create Access Key

**3. Azure Blob Storage**

If you want to use Azure blob storage, `LOG_STORE` will be `azure`. 

The following values are mandatory
```
  AZURE_STORAGE_ACCOUNT: 
  AZURE_STORAGE_KEY: 
  AZURE_STORAGE_CONTAINER: 
```

**4. S3 Assumed Role**

If you want to use s3 using Assumed Role Authentication, the log store will be `s3_assume`. 

The following values are mandatory

```
  LOG_STORE_REGION
  LOG_STORE_GENERATIONS_BUCKET
  LOG_STORE_ACCESS_KEY
  LOG_STORE_SECRET_KEY
  LOG_STORE_AWS_ROLE_ARN
  LOG_STORE_AWS_EXTERNAL_ID
```

`LOG_STORE_ACCESS_KEY`,`LOG_STORE_SECRET_KEY` will be supplied by Portkey. Rest needs to be provisioned and supplied.

`LOG_STORE_AWS_ROLE_ARN` and `LOG_STORE_AWS_EXTERNAL_ID` need to be enabled by following the below steps

1. Go to the IAM console in the AWS Management Console.
2. Click "Roles" in the left sidebar, then "Create role".
3. Choose "Another AWS account" as the trusted entity.
4. Enter the Account ID of the Portkey Aws Account Id (which will be shared).
5. Select "Require external Id" for added security.
6. Attach the necessary permissions: 
- AmazonS3FullAccess (or a more restrictive custom policy for S3)
7. Name the role (e.g., "S3AssumedRolePortkey") and create it.
8. After creating the role, select it and go to the "Trust relationships" tab.
9. Edit the trust relationship and ensure it looks similar to this:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "<arn_shared_by_portkey>"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId":"<LOG_STORE_AWS_EXTERNAL_ID>"
        }
      }
    }
  ]
}
```
`LOG_STORE_AWS_ROLE_ARN` will be the same as arn for the above role.

Note: Share the `LOG_STORE_AWS_ROLE_ARN` created with Portkey.

### Aws Assumed Role (for Bedrock)

If Aws assumed Role is used for authentication Bedrock, following keys are mandatory
```
  AWS_ASSUME_ROLE_ACCESS_KEY_ID
  AWS_ASSUME_ROLE_SECRET_ACCESS_KEY 
  AWS_ASSUME_ROLE_REGION
```

Follow, similar steps to `S3 Assumed Role` in Log Store section above. In step #6, following accesses are needed
- AmazonBedrockFullAccess (or a more restrictive custom policy for Bedrock)

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