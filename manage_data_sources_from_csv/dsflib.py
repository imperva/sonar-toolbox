"""
Author: Brian Anderson
Script Version: 1.1
Description: Library for dsf api calls and csv parsing
"""

import json
import requests
import base64
import logging
from time import localtime, strftime
from requests.packages import urllib3
import os
from re import sub
import csv

def parseCsv(CSV_FILE_PATH):
	records = []
	requiredFields = [
		"admin_email",
		# "asset_display_name",
		"asset_id",
		"jsonar_uid",
		"password",
		"reason",
		# "server_host_name",
		"service_name",
		"username"
	]
	authMechanisms = [
		"password",
		"kerberos"
	]

	missingFields = []
	rowIndex = {}
	f = open(CSV_FILE_PATH, 'r')
	csvfile = f.read().split("\n")
	rows = list(csv.reader(csvfile, quotechar='"', delimiter=',', quoting=csv.QUOTE_ALL, skipinitialspace=True))

	# Parse csv headers by name/index order into associative lookup to support csv data in different column order
	for i in range(len(rows[0])):
		if (rows[0][i].strip()!=""):
			rowIndex[rows[0][i].lower().replace(" ","_").replace('\ufeff', '')] = i

	# Check for minimum required fields
	for col in requiredFields:
		if (col not in rowIndex):
			missingFields.append(col.strip())

	if len(missingFields)>0:
		print("Missing required columns in csv: \n"+"\n".join(missingFields))
		exit()

	# Process each row into normalized data_source object
	for row_num in range(len(rows[1:])):
		is_ok = True
		row = rows[row_num+1]
		if checkRow(row,requiredFields,rowIndex,row_num):
			dataSourceObj = {"data": {"assetData": {"connections":[]}}}
			dataSourceObj["data"]["gatewayId"] = row[rowIndex["jsonar_uid"]].strip()
			dataSourceObj["data"]["serverType"] = row[rowIndex["server_type"]].strip()
			dataSourceObj["data"]["assetData"]["admin_email"] = row[rowIndex["admin_email"]].strip()
			dataSourceObj["data"]["assetData"]["asset_id"] = row[rowIndex["asset_id"]].strip()
			dataSourceObj["data"]["assetData"]["asset_display_name"] = row[rowIndex["asset_display_name"]].strip()
			dataSourceObj["data"]["assetData"]["Server Host Name"] = row[rowIndex["server_host_name"]].strip()
			dataSourceObj["data"]["assetData"]["Server IP"] = row[rowIndex["server_ip"]].strip()		
			dataSourceObj["data"]["assetData"]["Server Port"] = int(row[rowIndex["server_port"]].strip()) if can_int(row[rowIndex["server_port"]].strip()) else 0
			dataSourceObj["data"]["assetData"]["Service Name"] = row[rowIndex["service_name"]].strip()
			dataSourceObj["data"]["assetData"]["version"] = float(row[rowIndex["version"]].strip()) if can_float(row[rowIndex["version"]].strip()) else 0
			auth_mechanism = row[rowIndex["auth_mechanism"]].strip()
			if auth_mechanism in authMechanisms:
				match auth_mechanism:
					case "password":
						dataSourceObj["data"]["assetData"]["connections"].append({
							"connectionData": {
								"auth_mechanism": auth_mechanism.strip(),
								"username": row[rowIndex["username"]].strip(), 
								"password": row[rowIndex["password"]].strip()
							},
							"reason": row[rowIndex["reason"]].strip()
						})
					case "kerberos":
						dataSourceObj["data"]["assetData"]["connections"].append({
							"connectionData": {
								"auth_mechanism": auth_mechanism.strip(),
							},
							"reason": row[rowIndex["reason"]].strip()
						})
				records.append(dataSourceObj)
			else:
				records.append({"errors":True,"row_num":str(row_num+1)})
				# print("Invalid input on row "+str(row_num+1)+" - auth_mechanism '"+auth_mechanism+"' is not supported, ignoring row.")
				logging.info("Invalid input on row "+str(row_num+1)+" - auth_mechanism '"+auth_mechanism+"' is not supported, ignoring row.")
		else:
			records.append({"errors":True,"row_num":str(row_num+1)})
	return(records)


def parseCsvDelete(CSV_FILE_PATH):
	records = []
	rowIndex = {}
	f = open(CSV_FILE_PATH, 'r')
	csvfile = f.read().split("\n")
	rows = list(csv.reader(csvfile, quotechar='"', delimiter=',', quoting=csv.QUOTE_ALL, skipinitialspace=True))

	# Parse csv headers by name/index order into associative lookup to support csv data in different column order
	for i in range(len(rows[0])):
		if (rows[0][i].strip()!=""):
			rowIndex[rows[0][i].lower().replace(" ","_").replace('\ufeff', '')] = i
	# Process each row into normalized data_source object
	for row_num in range(len(rows[1:])):
		row = rows[row_num+1]
		if len(row)>0:
			if 0 <= int(rowIndex["asset_id"]) < len(row): 
				if row[rowIndex["asset_id"]]!= "":
					records.append(row[rowIndex["asset_id"]].strip())
				else:
					records.append({"errors":True,"row_num":str(row_num+1)})
		else:
			records.append({"errors":True,"row_num":str(row_num+1)})
	return(records)	

def checkRow(row,requiredFields,rowIndex,row_num):
	row_ok = True
	missingFields = []
	for field in requiredFields:
		if not 0 <= int(rowIndex[field]) < len(row): 
			row_ok = False
			missingFields.append(field)
		else:
			if (field=="username" or field=="password"):
				if row[rowIndex[field]].strip() == "" and row[rowIndex["auth_mechanism"]].strip() == "password":
					row_ok = False
					missingFields.append(field)
			elif row[rowIndex[field]].strip() == "":
				row_ok = False
				missingFields.append(field)
	if len(missingFields)>0:
		# print("Missing required field(s) '"+",".join(missingFields)+"' in row "+str(row_num+1)+", ignoring row.")
		logging.info("Missing required field(s) '"+",".join(missingFields)+"' in row "+str(row_num+1)+", ignoring row.")
	return row_ok

def makeCall(url, dsf_token, method="GET", data=None):
	urllib3.disable_warnings()
	headers = {
		'Accept': 'application/json',
		'Content-Type': 'application/json',
		'Authorization': 'Bearer ' + dsf_token
	}
	if data == None:
		content = None
	else:
		content = data.encode("utf-8")
	try:
		# DSF API Request | curl -ik -X GET -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer 99e118b5-046d-4fda-9fc0-c601cf7af2d4" https://3.129.85.36:8443//dsf/api/v2/data-sources
		if method == 'POST':
			logging.info("API REQUEST (" + method + " " + url + ") " + str(content)+"\n")
			response = requests.post(url, content, headers=headers, verify=False)
		elif method == 'GET':
			logging.info("API REQUEST (" + method + " " + url + ") \n")
			response = requests.get(url, headers=headers, verify=False)
		elif method == 'DELETE':
			logging.info("API REQUEST (" + method + " " + url + ") \n")
			response = requests.delete(url, headers=headers, verify=False)
		elif method == 'PUT':
			logging.info("API REQUEST (" + method + " " + url + ") " + str(content)+"\n")
			response = requests.put(url, content, headers=headers, verify=False)
		if response.status_code == 404:
			logging.debug("API ERROR (" + method + " " + url + ") status code: "+str(response.status_code)+"\n")
		elif response.status_code != 200:
			logging.debug("API ERROR (" + method + " " + url + ") "+str(response.status_code)+" | response: "+json.dumps(response.json())+"\n")
		else:
			logging.info("API RESPONSE (" + method + " " + url + ") status code: "+str(response.status_code)+"\n")
		return response
	except Exception as e:
		logging.warning("ERROR - "+str(e)+"\n")

def readFile(filename):
	with open(filename, 'r') as content_file:
		return(json.loads(content_file.read()))
		
def writeFile(filename,data):
	open(filename, 'w+').close()
	csv_file=open(filename,"w+")
	csv_file.write(data)
	csv_file.close()

def fmtStr(str):
	return(str.lower().replace(" ","_"))

def sortObject(sourceObj):
	objSortedKeys = {}
	objSortedKeys = list(sourceObj.keys())
	objSortedKeys.sort()
	sourceObj = {i: sourceObj[i] for i in objSortedKeys}
	return(sourceObj)

def can_int(value):
    try:
        int_value = int(value)
        return True
    except ValueError:
        return False
	
def can_float(value):
    try:
        float_value = float(value)
        return True
    except ValueError:
        return False