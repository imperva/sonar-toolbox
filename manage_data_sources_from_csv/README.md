# Data Source Import from CSV

This project provides resources to bulk import and delete data_source records into the DSFHUB via the [DSF Open API](https://docs.imperva.com/bundle/v4.13-sonar-user-guide/page/84552.htm).

## Authentication - Setting up the required environment variables:
Set [environment variables](https://en.wikipedia.org/wiki/Environment_variable) to configure a token for authentication, and the specific hub endpoint, example:  

```	
export IMPV_DSF_HOST="https://1.2.3.4:8443"  
export IMPV_DSF_TOKEN="abcdef-12345-abcd-12345-abcdef"  
```

[CLICK HERE](https://docs.imperva.com/bundle/v4.13-sonar-user-guide/page/84555.htm) to see how create a token to authenticate.

## Bulk Delete Usage:
`python delete_data_source_from_csv.py "path/to/my/csv/data.csv"`

## Bulk Delete Argument Reference

- `IMPV_DSF_HOST` (String) The host of the DSF HUB system to upload data sources to, example: `"https://1.2.3.4:8443"`  
- `IMPV_DSF_TOKEN` (String) The bearer token used to authenticate to the DSF HUB API, example: `"abcdef-12345-abcd-12345-abcdef"`  
- `CSV_FILE_PATH` (String) Path to the csv file to bulk import as command line argument. Example: `"/path/to/my/csv/data_sources.csv"`
- `logging.basicConfig.level` ([Logging Level](https://docs.python.org/3/library/logging.html#levels)) Logging level of the script.  Defaults to: `logging.INFO`. (Line 20 in import_data_sources_from_csv.py)

## Bulk Import Usage:
`python import_data_source_from_csv.py "path/to/my/csv/data.csv"`

## Bulk Import Argument Reference

- `IMPV_DSF_HOST` (String) The host of the DSF HUB system to upload data sources to, example: `"https://1.2.3.4:8443"`  
- `IMPV_DSF_TOKEN` (String) The bearer token used to authenticate to the DSF HUB API, example: `"abcdef-12345-abcd-12345-abcdef"`  
- `CSV_FILE_PATH` (String) Path to the csv file to bulk import as command line argument. Example: `"/path/to/my/csv/data_sources.csv"`
- `OVERWRITE_DUPLICATE_RECORDS` (Bolean) Overwrite exisitng records in the system of the asset_id already exists, defaults to False.  (Line 25 in import_data_sources_from_csv.py)
- `logging.basicConfig.level` ([Logging Level](https://docs.python.org/3/library/logging.html#levels)) Logging level of the script.  Defaults to: `logging.INFO`. (Line 20 in import_data_sources_from_csv.py)

## Required CSV Columns:
Download the [sample_assets.csv](https://github.com/imperva/sonar-toolbox/blob/main/import_data_sources_from_csv/sample_assets.csv) example for reference:

- `asset_display_name` - (String) User-friendly name of the asset, defined by user.
- `asset_id` - (String) The unique identifier or resource name of the asset. For most assets this should be a concatenation of `Server Host Name + Server Type + Service Name + Server Port` with “:” (colon) as separator, example: `mydbhost:mysql:my-db-service-name:3306`. For AWS data stores, this value will be the arn. For Azure data stores, the recommended format is `/subscriptions/my-subscription-id/resourceGroups/my-resource-group/`.
- `auth_mechanism` - (String) Specifies the auth mechanism used by the connection.
- `jsonar_uid` - (String) The jsonarUid unique identifier of the agentless gateway. Example: `'abcdef-12345-abcd-12345-abcdef'`
- `password` - (String) The password of the user being used to authenticate.
- `reason` - (String) Defines reason for connection, default value: `"default"`
- `Server Host Name` - (String) Hostname (or IP if name is unknown)
- `Server IP` - (String) IP address of the service where this asset is located. If no IP is available populate this field with other information that would identify the system e.g. hostname or AWS ARN, etc.
- `Server Port` - (String) Port used by the source server.
- `Server Type` - (String) The type of server or data service to be created as a data source. [CLICK HERE](https://docs.imperva.com/bundle/v4.11-sonar-user-guide/page/84552.htm) for the list of available data sources.
- `Service Name` - (String) Name of the database service.
- `username` - (String) The user to use when connecting to the database.
- `version` - (Float) Denotes the version of the asset.  Example: `1.2`