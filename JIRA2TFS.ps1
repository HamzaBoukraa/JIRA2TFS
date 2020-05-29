[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
$Encoding = [Console]::OutputEncoding = [Console]::InputEncoding = New-Object System.Text.UTF8Encoding;

# Clear-Host;

# Set-Location $PSScriptRoot;
Set-Location "E:\Outils_Exploit\JIRA2TFS";
$RootFolder = (Get-Item -Path ".\").FullName;
$DataFolder = Resolve-Path "$RootFolder\Data";
$LibraryFolder = Resolve-Path "$RootFolder\Lib";
$ConfigFilePath = "$RootFolder\Config\config.json";
$ConfigFileContent = $(Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json);


. $LibraryFolder\Set-Logger.ps1;
. $LibraryFolder\Jira2TFSExtensions.ps1;
. $LibraryFolder\JiraExtensions.ps1;
. $LibraryFolder\TFSExtensions.ps1;

$TFSServerUrl = $ConfigFileContent.TFS.ServerUrl;
$TFSTeamProject = $ConfigFileContent.TFS.TeamProject;

$JiraServerUrl = $ConfigFileContent.JIRA.ServerUrl;
$JiraUser = $ConfigFileContent.JIRA.User;
$JiraToken = $ConfigFileContent.JIRA.Token;
$JiraDaysOffset = $ConfigFileContent.JIRA.DaysOffset;

$TfsChangesets = Get-Changesets;
$TfsBuilds = Get-Builds;
$JiraIssues = Get-JiraIssues;
