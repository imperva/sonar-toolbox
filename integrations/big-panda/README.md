# Integration Playbooks

This package contains resources and instructions integrate the Data Security Fabric (DSF) with BigPanda APIs via DSF playbooks.  

A playbook is the set of rules, conditions, and business logic used to automate tasks.  In the DSF platform, playbooks can be used to ingest data, execute jobs, migrate and manipulate data, create tickets and incidents in external systems, and automate almost any task.  Playbooks can be invoked via a scheduled job, triggered from a system event, manually triggered in the GUI via a user, and/or automated from an external API call. 

## Version compatibility

```
jsonar_4.9.openapi5
```

## Installation

### Download files

   Option 1
  `wget -O sonar-toolbox.zip https://github.com/imperva/sonar-toolbox/archive/refs/heads/master.zip`  
  `unzip sonar-toolbox.zip`  
  `$ cd sonar-toolbox/integrations/`  

#### Option 2
  `git clone https://github.com/imperva/sonar-toolbox.git`  
  `cd sonar-toolbox/integrations/`  

### OpenAPI Sources in Playbooks  

DSF playbooks provide the ability to automate tasks and integrate with external systems via APIs.  The schema (combination of urls, methods, and parameters) for these APIs are described in [swagger (v3)](https://swagger.io/specification/) definition files in [JSON](https://json-schema.org/) format.  The DSF platform can ingest and "syncronize" these API swagger definitions into components that can be used in playbooks by uploading swagger files by uploading these files to the `${JSONAR_LOCALDIR}` directory on the DSF hub system, and running the `Home->Playbooks->Synchronization History->Synchronize Now` process via the GUI.   

The suggested location for the openapi files are in `${JSONAR_LOCALDIR}/openapi-sources`. 

Upload and move the files to the suggested location:

`scp /path/to/your/swagger/files/*.json youruser@<warehouse>:/tmp`  
`ssh youruser@<warehouse>`  
`sudo su`  
`export $(cat /etc/sysconfig/jsonar)`  
`cd $JSONAR_LOCALDIR`  
`mkdir openapi-sources`  
`chown -R sonarw:sonar openapi-sources`  
`mv /tmp/*.json openapi-sources/`  

Connect to mongo using the local certificate:  
`CERT_AS_PASSWD=$(awk -vORS="\\\n" "1" ${JSONAR_LOCALDIR}/ssl/client/admin/cert.pem)`  
`${JSONAR_BASEDIR}/bin/mongo --port 27117 --authenticationMechanism PLAIN --authenticationDatabase "\$external" -u"CN=admin" -p"${CERT_AS_PASSWD}"`  

Add new source to sonarw:
note: this is a list of all available openapi sources, you can pick and choose in case you don't want to add them all. Refer to `Depends on` section in [Playbooks](#playbooks) -> the playbook you intend to use.
```
var new_sources = []
new_sources.push({
    "_id": "big_panda",
    "name": "Big Panda",
    "type": "OFFLINE",
    "disabled": false,
    "openapi": "file://${JSONAR_LOCALDIR}/openapi-sources/bigpanda.openapi.json",
    "url": "https://unused-placeholder.com"
  })
use lmrm__ae
db.action_center_sources.insertMany(new_sources)
```

### Synchronize api schemas with playbook integrations

  - Navigate to Home->Playbooks->Synchronization History.  
  - Click `Synchronize Now`, expand the job and look for `big_panda` to ensure the schemas were imported successfully.

## Usage

## Adding a connection

  - Navigate to Home->Sync Spreadsheet->Import Assets.  
  - Click `+ Choose`, and select the `templates/BigPanda_template.xlsx`
  - Click `Upload`.  NOTE: If you have not done so in the spreadsheet already, you can update the url, admin email, username and password fields here.
  - Click `Validate All`. You should see a popup saying `Validation Complete`.  
  - Click `Run 'Import Assets'`.  When prompted to confirm, click `√ Import`.
  
### Sample steps to import a playbook
  - Navigate to Home->Playbooks->Playbook Drafts.  
  - Navigate to `Import Draft`, click `browse` and select your playbook file and click `Import`.  

## Importing playbooks for creating BigPanda alerts.

  - In this section, for the BigPanda Alert integration, you will need to follow the following process, as the last playbook depends on the first to to be imported and published first.
  1. Import `playbooks/bigpanda_alert.json` using the `Import a playbook` steps outlined above.
  1. Publish the `Create BigPanda Alert` playbook.
  1. Click Options->Run - Advanced to run/test the `BigPanda Alert` playbook.
  
## Create incidents from events the `sonargd-instance` collection
To create incidents from events in the `sonargd-instance` collection, follow the following steps:
  1. Navigate to Home->Playbooks->Published Playbooks.
  1. Select the `All Categories` dropdown, and select the `BigPanda Incident` category filter.
  1. On the `Create BigPanda Alert` playbook, click Options->Create SonarK Button, and enter the following:   
    - Select an Index Pattern: `sonargd-instance`  
    - Location: `ROW`  
    - Button Label: `Create BigPanda Alert`  
    - Group Label: `No`  
    - Playbook Execution: Check `Synchronous Execution`
    - Enter the following syntax into the text area:  
      ```
      {
        "start" : {
          "event" : "$$data",
          "comment" : null,
          "asset_id" : "big_panda"
        }
      }
      ```  
  1. Navigate to Home->Discover, select the sonargd-instance collection, and click `Create BigPanda Alert`.  Enter a comment and click submit.

## Contributing

Would you like to contribute to this project? [CONTRIBUTING.md] has all the details on how to do that.

[CONTRIBUTING.md]: CONTRIBUTING.md

## License

Imperva Playbooks are released under the [MIT License](http://www.opensource.org/licenses/MIT).
