"""
Author: Brian Anderson
Script Version: 1.1
Description: Library for bulk deletion of dsf assets from a csv file
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
	filename="delete-data-sources-from-csv.log", 
	filemode='w', 
	format='%(name)s - %(levelname)s - %(message)s',
	level=logging.INFO
)

if len(sys.argv)<2:
	print('[ERROR] Missing argument, please specify th path to the csv file with records to delete.\nExample: python delete_data_sources_from_csv.py "path/to/my/csv/file.csv"')
	logging.warning('[ERROR] Missing argument, please specify th path to the csv file with records to delete.\nExample: python delete_data_sources_from_csv.py "path/to/my/csv/file.csv"')
	exit()
############ GLOBALS ############
# Get environment variables
CSV_FILE_PATH = sys.argv[1]
DSF_HOST = os.getenv('IMPV_DSF_HOST')
DSF_TOKEN = os.getenv('IMPV_DSF_TOKEN')
if DSF_HOST == None or DSF_TOKEN == None:
	print("ERROR - Missing environment variables. Both DSF_HOST or DSF_TOKEN environment variables need to be set")
	logging.warning("ERROR - Missing environment variables. Both DSF_HOST or DSF_TOKEN environment variables need to be set")
	exit()

def run():
	failedRecords = []
	logging.warning("====================  Starting deleting data sources from CSV by asset_id  ====================")
	logging.warning("Deleting records from CSV file: "+CSV_FILE_PATH+"\n")
	asset_ids = dsflib.parseCsvDelete(CSV_FILE_PATH)
	logging.info("Processing CSV records: "+CSV_FILE_PATH+"\n")
	for asset_id in asset_ids:
		if "errors" in asset_id:
			failedRecords.append(asset_id)
			continue
		logging.info("Deleting record with asset_id '"+asset_id+"'\n")
		response = dsflib.makeCall(DSF_HOST + "/dsf/api/v1/data-sources/"+asset_id, DSF_TOKEN, "DELETE")
		responseObj = response.json()
		if response.status_code == 200 or response.status_code == 201:
			logging.info("Successfully deleted record with asset_id '"+asset_id+"'.\n")
		else:
			logging.error("[WARN] Error in response, response.status_code: "+str(response.status_code)+", response: "+json.dumps(responseObj)+"\n")
			failedRecords.append(asset_id)
	print("Successfully deleted "+str(len(asset_ids)-len(failedRecords))+" of "+str(len(asset_ids))+" records")
	if len(failedRecords)>0:
		print("[DEBUG] Failed to delete "+str(len(failedRecords))+", please check the log file for details.\n\nRecords: "+json.dumps(failedRecords,indent=4)+"\n")

if __name__ == '__main__':
	run()
