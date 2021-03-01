#!/bin/bash
#set -x
output_folder=$(echo "/usr/lib/zabbix/externalscripts/")

#json variables for the json_convert function. Do not change.
json_head="{\"data\":["
json_tail="]}"
json=$json_head
#jq script function to convert variables to json output for Zabbix discovery
json_convert () {
	json+=$(jq -Rn '
	( input  | split("|") ) as $keys |
	( inputs | split("|") ) as $vals |
	[[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries
	' <<<"$s")
	json+=","
}

#Zabbix discovery of sites
#Returns a list of sites with orginization names
if [ "$1" == "site.discovery" ]; then
	IFS=$'\n' orgs=(`cat $output_folder"verkada.json" | jq '.[] | .org_name' | uniq | sed 's/\"//g'`)
	#Find list of sites
	for i in "${orgs[@]}"; do
		IFS=$'\n' sites=(`cat $output_folder"verkada.json" | jq --arg var "$i" '(.[] | select(.org_name == $var )).site' | sort | uniq | sed 's/\"//g'`)
		for b in "${sites[@]}"; do
			#Convert site details to format for jq script
			s1=$(echo '{#SITE_NAME}|{#ORG}')
			s2=$(echo $b"|"$i)
			s="${s1}"$'\n'"${s2}"
			#jq script that creates valid json output
			json_convert
			c=$c+1
		done
	done
	json=$(echo ${json::-1})
	json+=$json_tail
	echo $json
fi

#Discovers all cameras at a given site
#Takes Org Name and site name as an arguments
if [ "$1" == "camera.discovery" ]; then
	IFS=$'\n' id=(`cat $output_folder"verkada.json" | jq --arg org_name "$2" --arg site "$3" '.[] | select(.org_name == $org_name ) | select(.site == $site).camera_id' | sed 's/\"//g'`)
	IFS=$'\n' name=(`cat $output_folder"verkada.json" | jq --arg org_name "$2" --arg site "$3" '.[] | select(.org_name == $org_name ) | select(.site == $site).name' | sed 's/\"//g'`)
	c=0
	for b in "${id[@]}"; do
		#Convert site details to format for jq script
		s1=$(echo '{#CAMERA_ID}|{#CAMERA_NAME}')
		s2=$(echo $b"|"${name[$c]})
		s="${s1}"$'\n'"${s2}"
		#jq script that creates valid json output
		json_convert
		c=$c+1
	done
	json=$(echo ${json::-1})
	json+=$json_tail
	echo $json
fi


#Check status of all cameras at a site. Returns up if any of the cameras are up. 
#Used to reduce alerts in Zabbix if a whole site goes down
#Takes Org name and site name as arguments
if [ "$1" == "site.status" ]; then
	cat $output_folder"verkada.json"  | jq --arg org_name "$2" --arg site "$3" '.[] | select(.org_name == $org_name ) | select(.site == $site).status' | sort -r | head -1
fi

if [ "$1" == "camera.status" ]; then
	cat $output_folder"verkada.json" | jq --arg id "$2" '.[] | select(.camera_id == $id).status'
fi

if [ "$1" == "site.data" ]; then
	cat $output_folder"verkada.json"  | jq --arg org_name "$2" --arg site "$3" '.[] | select(.org_name == $org_name ) | select(.site == $site)' | jq -s
fi

