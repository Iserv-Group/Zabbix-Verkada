#!/bin/bash

output_folder=$(echo "/usr/lib/zabbix/externalscripts/")
orgs=$(echo "/root/scripts/verkada_creds.csv")
#Pull in Org Credentials
IFS=$'\n' org_name=(`cat $orgs | grep -v API_Key | awk -F ',' '{print $1}'`)
IFS=$'\n' org_id=(`cat $orgs | grep -v API_Key | awk -F ',' '{print $2}'`)
IFS=$'\n' api_key=(`cat $orgs | grep -v API_Key | awk -F ',' '{print $3}'`)

touch $output_folder"verkada.json.tmp"
c1=0
for i in "${org_name[@]}"; do
	curl --request GET --url https://api.verkada.com/orgs/${org_id[$c1]}/cameras --header 'Accept: application/json' --header 'x-api-key: '${api_key[$c1]} | jq --arg org_name "$i" --arg id "${org_id[$c1]}" '[.[] | .[] | select(.)] | map(. + {org_name: $org_name}) | map(. + {org_id: $id})' | sed 's/\"Live\"/1/g' | sed 's/\"Offline\"/0/g' >> $output_folder"verkada.json.tmp"
	c1=$c1+1
done
mv $output_folder"verkada.json.tmp" $output_folder"verkada.json"
