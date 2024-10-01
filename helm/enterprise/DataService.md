
## Enterprise Finetuning Docs:
Currently finetuning is fully supported API communication only vs partial support via UI.
Architecture:

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXffbhrnjyEjpmgafZtZ2qZVM55G6yCRB8FHf5BbbJAa-XTM4km6mfip2OnpZ5Ts-373avnjqMONLhaJOuQpDL-3pAPx7viYRrq1W-KJicd_OIu_0tJ1aDXAnPo_NjL6h7Jd0CuhmTqMcWKOE_FoGoYzsROg?key=GSWy0RPh6CRcV4iKuzA0zQ)

The architecture is a simple proxy service which we call from our servers to your hosted gateway which internally calls existing servers.

To start a finetune job, please follow the below steps.
Steps:
-   Create a Dataset
-   Upload File to S3 - optional if file is already in S3.
-   Update the dataset with the uploaded S3 Key.
-   Create Finetune
-   Update finetune with the id of the dataset.
-   Start dataset validation
-   Start finetune  
We can check the status of finetune via UI regardless of the finetune provider (AWS, OpenAI or Anyscale).
-   Cancel Finetune - if Needed.


> When we create a `dataset` , API will return a S3 Signed URL to upload file to S3. We can use that link to push the file to into S3 before starting the finetune.

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
