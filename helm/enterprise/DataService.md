
# Overview:
## Architecture:

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXffbhrnjyEjpmgafZtZ2qZVM55G6yCRB8FHf5BbbJAa-XTM4km6mfip2OnpZ5Ts-373avnjqMONLhaJOuQpDL-3pAPx7viYRrq1W-KJicd_OIu_0tJ1aDXAnPo_NjL6h7Jd0CuhmTqMcWKOE_FoGoYzsROg?key=GSWy0RPh6CRcV4iKuzA0zQ)

The above document describes the architecture of a hydrid data service system. 

- The gateway acts as an intermediary between control plane and deployed data service, providing a streamlined and secure method of communication.
- The data service is only accessible from within the cluster via gateway only.
- Gateway exposes following endpoints
    1. v1/datasets 
    2. v1/finetune 
    3. v1/dataservice/datasets 
    4. v1/dataservice/finetune
    
    Note: 
    - `v1/datasets` & `v1/finetune` are exposed via API with at least `completions.write` scope.
    - `v1/dataservice/datasets` and `v1/dataservice/finetune` are used internally by the Control Plane for communication with the data service via gateway.

## Fine-tuning Process
To start a fine-tune job, follow these steps:

Create a Dataset
Upload File to S3 (optional if file is already in S3)
Update the dataset with the uploaded S3 Key
Create Finetune
Update finetune with the dataset ID
Start dataset validation
Start finetune


> Note: 
When creating a dataset, the API returns an S3 Signed URL for file upload. Use this link to push the file to S3 before starting the fine-tune process.

Example cURL for each step as follows:
### Create Dataset
#### cURL:

```bash
curl --request POST \
  --url <deployed_url>/v1/datasets \
  --header 'content-type: application/json' \
  --header 'x-portkey-api-key: <api_key>' \
  --data '{
  "name": "{{filename}}",
  "provider": "string", #ex `openai`, `cohere` or `anyscale`
  "model": "string" #ex `gpt-4`, `llama3.2` or `gpt-4o`,
  "type": "training"
}'
```

> Make sure to update the `{{filename}}` variable in the request body with the filename of dataset.

#### Response
```json
{
	"success": true,
	"data": {
		"id": "string",
		"signed_url": "string"
	}
}
```

### Update dataset

#### cURL:
```bash
curl --request PUT \
  --url <deployed_url>/v1/datasets/:dataset_id \
  --header 'content-type: application/json' \
  --header 'x-portkey-api-key: <api_key>' \
  --data '{
  "s3_path": "s3_key" 
}'
```

This will update the dataset details with the path of S3 file i.e Key of S3.

#### Response
```json
{
	"success": true,
	"data": {}
}
```

### Create a Finetune
Create a finetune

#### cURL:
```bash
curl --request POST \
  --url <deployed_url>/v1/finetune \
  --header 'content-type: application/json' \
  --header 'x-portkey-api-key: <api_key>' \
  --data '{
  "name":"string",
  "virtual_key": "string",
  "provider": "string",
  "model": "string",
  "hyperparameters": {
    "epochs": 1
  }
}'
```

#### Response
```json
{
	"success": true,
	"data": {
		"id": "string"
	}
}
```

### Update finetune
Now that we have created a finetune job, we have to attach the dataset to the newly created finetune to be used by job.

#### cURL:
```bash
curl --request PUT \
  --url <deployed_url>/v1/finetune/:finetuneId \
  --header 'content-type: application/json' \
  --header 'x-portkey-api-key: <api_key>' \
  --data '{
      "training_dataset_id": "string"
}'
```

> `trainingDatasetId` is the id of the dataset we've created in step 1.

_This endpoint can also be used to reset the status of the finetune job i.e back to original state which is useful in case of new dataset update etc._

#### Response
```json
{
	"success": true,
	"data": {}
}
```

### Finetune Validation
Before starting a finetune job we must validate the dataset weather if there's any errors with dataset or it's fully valid & supported by the finetuning model.

#### cURL:
```bash
curl --request POST \
  --url <deployed_url>/v1/finetune/:finetuneId/validation/start \
  --header 'x-portkey-api-key: <api_key>'
```

Finetune validation is a background process which doesn't return the validation status immediately. Before proceeding to the next step we must be sure that the validation is successful i.e `pk_dataset_validation_successfull`.

To fetch the status of a finetune job use the below **cURL**:

```bash
curl --request GET \
  --url <deployed_url>/v1/finetune/:finetuneId \
  --header 'content-type: application/json' \
  --header 'x-portkey-api-key: <api_key>'
```

### Start finetune Job with Provider
Once the validation job is successful, we can continue running our finetune job with the provider.

#### cURL:
```bash
curl --request POST \
  --url <deployed_url>/v1/finetune/:finetuneId/start \
  --header 'content-type: application/json' \
  --header 'x-portkey-api-key: <api_key>' \
```

For providers like Amazon bedrock, `modelId` to start a finetune job differs for model to model in these type of situation we can pass a required modelId in the body of the request. Example curl follows

```bash
curl --request POST \
  --url <deployed_url>/v1/finetune/:finetuneId/start \
  --header 'content-type: application/json' \
  --header 'x-portkey-api-key: <api_key>' \
  --data '{
  "override_model": "modelId"
}'
```

Ex: To see the list of model-ids for AWS bedrock follow this [guide](https://docs.aws.amazon.com/bedrock/latest/userguide/model-ids.html#prov-throughput-models) 

### Cancel finetune
If we're wanted to cancel a finetune, we can do so by using the following `cURL`.

#### cURL:

```bash
curl --request POST \
  --url <deployed_url>/v1/finetune/:finetuneId/cancel \
  --header 'content-type: application/json' \
  --header 'x-portkey-api-key: <api_key>' \
```

### Fetch a finetune
We can verify the status of a finetune job either from Frontend or via Request.

#### cURL:
```bash
curl --request GET \
  --url <deployed_url>/v1/finetune/:finetuneId \
  --header 'x-portkey-api-key: <api_key>'
```
