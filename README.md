# Overview
 The purpose of this script is to monitor the up status of Verkada camera in Zabbix. This is accomplished by making API calls against the Verkada Dashboard using the external scripts function in Zabbix. Because this script uses external checks exclusively, everything is checked on the Zabbix server.
 To allow for separation of the Verkada API key from Zabbix, there are two scripts, the verkada_status.sh script pulls data from the API and outputs it to a json file for the verkada.sh script that is used by Zabbix for discovery and status purposes.
## Templated Zabbix items and triggers
 The Zabbix template is configured to create low priority alerts after a few minutes if a camera or entire site becomes unreachable, then create increasingly higher priority alerts if the cameras remain offline. The discovery process creates a single host within Zabbix for each Verkada site and adds it to a group based off the name you enter in the credential csv. 
 Alerts for discovered cameras are dependent on an alert for the entire site. This is to reduce alerting to a single alarm if all the cameras at a site go offline at the same time. 
# Installation
 1.	Start by downloading the repository and moving both scripts and the verkada_creds.csv file to your Zabbix installation.
 2.	Place the verkada_discovery.sh script and verkada_creds.csv in a secure location on the Zabbix server and limit the read/write privileges on both files to super users to protect your API keys. 
 3. Add a list of Verkada Organizations that you want to monitor to the verkada_creds.csv file. 
	i.The organization can be whatever you want and don't have to be uniq, but they should represent the name of the Organization as it's found in Verkada. They will be used to place hosts/sites into groups within Zabbix and for the name of of those Zabbix hosts.
	ii. The Organization ID and API key can be found in the dashboard by navigating to Admin > Verkada API
 4.	Modify the variables at the top of the verkada_discovery.sh script
	i. Make sure the output_folder variable points to the external scripts folder on your Zabbix host.
	ii. Make sure the orgs variable points to the credential file you modified earlier. 
 5. Place the verkada.sh script in the externalscripts folder.
 6. Modify the folder variables at the top of the verkada.sh script to match your installation 
	i. Make sure the output_folder variable points to the external scripts folder on your Zabbix host.
 7.	Run the verkada_status.sh script to see if a valid json file is created at externalscripts/verkada.json
 7.	Run the verkada_status.sh script to see if a valid json file is created at externalscripts/verkada.json
 8.	Assuming the test was successful, add the following line to a superuser crontab that has privileges to read/execute both verkada_discovery.sh and verkada_creds.csv. Make sure to use the full path to both scripts, instead of the examples below. 

 ```
 * * * * * /home/user/scripts/verkada_status.sh
 ```

 9. Import the template into Zabbix
 10. Create a Host Group with the name of verkada and give permissions to your users that include subgroups. 
 11. Apply the verkada Network Discovery template to your Zabbix host, then run the discovery rule. 
 
