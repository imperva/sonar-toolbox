"""
Author: Brian Anderson
Script Version: 1.1
Description: Library for bulk importing of dsf assets from a csv file
"""

#!/usr/bin/env python
#/imperva/apps/jsonar/apps/4.x.x/bin/python3
import os
import dsflib
import sys
import json
import csv
from subprocess import PIPE,Popen
import logging
import requests
from time import localtime, strftime
import urllib
from requests.packages import urllib3
import urllib.parse
import logging

############ ENV Settings ############
logging.basicConfig(
	filename="import-data-sources-from-csv.log", 
	filemode='w', 
	format='%(name)s - %(levelname)s - %(message)s',
	level=logging.INFO
)

if len(sys.argv)<2:
	print('[ERROR] Missing argument, please specify th path to the csv file to import.\nExample: python import_data_sources_from_csv.py "path/to/my/csv/file.csv"')
	logging.warning('[ERROR] Missing argument, please specify th path to the csv file to import.\nExample: python import_data_sources_from_csv.py "path/to/my/csv/file.csv"')
	exit()
############ GLOBALS ############
# Get environment variables
OVERWRITE_DUPLICATE_RECORDS = False
CSV_FILE_PATH = sys.argv[1]
DSF_HOST = os.getenv('IMPV_DSF_HOST')
DSF_TOKEN = os.getenv('IMPV_DSF_TOKEN')
if DSF_HOST == None or DSF_TOKEN == None:
	print("ERROR - Missing environment variables. Both DSF_HOST or DSF_TOKEN environment variables need to be set")
	logging.warning("ERROR - Missing environment variables. Both DSF_HOST or DSF_TOKEN environment variables need to be set")
	exit()

def run():
	failedRecords = []
	logging.warning("====================  Starting import data sources from CSV  ====================")
	logging.warning("Importing CSV file: "+CSV_FILE_PATH+"\n")
	records = dsflib.parseCsv(CSV_FILE_PATH)
	logging.info("Processing CSV records: "+CSV_FILE_PATH+"\n")
	for record in records:
		if "errors" in record:
			failedRecords.append(record)
			continue
		# response = dsflib.makeCall(DSF_HOST + "/dsf/api/v1/data-sources", DSF_TOKEN, "GET")
		logging.info("Creating record with asset_id '"+record["data"]["assetData"]["asset_id"]+"'\n")
		response = dsflib.makeCall(DSF_HOST + "/dsf/api/v1/data-sources", DSF_TOKEN, "POST", json.dumps(record))
		responseObj = response.json()
		if response.status_code == 200 or response.status_code == 201:
			logging.info("Successfully created record with asset_id '"+record["data"]["assetData"]["asset_id"]+"'.\n")
		else:
			if "errors" in responseObj:
				if "already exists" in responseObj["errors"][0]["detail"] and OVERWRITE_DUPLICATE_RECORDS:
					response = dsflib.makeCall(DSF_HOST + "/dsf/api/v1/data-sources/"+urllib.parse.quote(record["data"]["assetData"]["asset_id"]), DSF_TOKEN, "POST", json.dumps(record))
				else:
					record["errors"] = responseObj["errors"]
					failedRecords.append(record)
					logging.error("[ERROR] Failed to create record with asset_id '"+record["data"]["assetData"]["asset_id"]+"', response.status_code: "+str(response.status_code)+", error:"+json.dumps(responseObj)+"\n")
			else:
				logging.error("[DEBUG] Malformed response, response.status_code: "+str(response.status_code)+", error:"+response+"\n")
	print("Successfully imported "+str(len(records)-len(failedRecords))+" of "+str(len(records))+" records")
	if len(failedRecords)>0:
		print("[DEBUG] Failed to import "+str(len(failedRecords))+", please check the log file for details.\n")	

if __name__ == '__main__':
	run()
