# JIRA2TFS
Powershell library to synchronize ticket from JIRA to TFS


## Configuration
Update the values in the configuration file (./Config/config.json) with the appropriate values :

### TFS :
#### ServerUrl:
* Team Foundation Server URL
#### TeamProject:
* Team Foundation Project (example: "TeamProject/TeamSolution")


### JIRA:
#### ServerUrl:
* JIRA API endpoint (example "https://my-jira-project.atlassian.net/rest/api/2")
#### User:
* JIRA user name (usually an email address)
#### Token:
* JIRA authentication token
#### DaysOffset:
* Number of days to synchronize (example : 365 means the last year, 7 means the last week, 1 means the last day)
