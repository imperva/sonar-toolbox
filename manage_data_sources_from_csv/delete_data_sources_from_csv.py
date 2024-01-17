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
	records = dsflib.parseCsv(CSV_FILE_PATH)
	logging.info("Processing CSV records: "+CSV_FILE_PATH+"\n")
	for record in records:
		logging.info("Deleting record with asset_id '"+record["data"]["assetData"]["asset_id"]+"'\n")
		response = dsflib.makeCall(DSF_HOST + "/dsf/api/v1/data-sources/"+record["data"]["assetData"]["asset_id"], DSF_TOKEN, "DELETE")
		responseObj = response.json()
		if response.status_code == 200 or response.status_code == 201:
			logging.info("Successfully deleted record with asset_id '"+record["data"]["assetData"]["asset_id"]+"'.\n")
		else:
			logging.warn("[WARN] Error in response, response.status_code: "+str(response.status_code)+", error:"+response+"\n")
			failedRecords.append(record)
	print("Successfully deleted "+str(len(records)-len(failedRecords))+" of "+str(len(records))+" records")
	if len(failedRecords)>0:
		print("[DEBUG] Failed to delete "+str(len(failedRecords))+" records: "+json.dumps(failedRecords,indent=4)+"\n")	

if __name__ == '__main__':
	run()
