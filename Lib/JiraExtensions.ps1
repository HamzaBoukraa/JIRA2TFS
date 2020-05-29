function Get-JiraIssue {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraUrl")] 
        [string]$IssueUrl
    )
    $pair = "$($JiraUser):$($JiraToken)";
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair));
    $basicAuthValue = "Basic $encodedCreds";
    
    $Headers = @{Authorization = $basicAuthValue;};

    $JiraIssue = $(ConvertFrom-Json (Invoke-WebRequest -Uri $IssueUrl -Headers $Headers -ContentType "application/json; charset=utf-8").Content);

    foreach($RootKey in $JiraIssue.psobject.Properties.Name){
        if($RootKey.StartsWith("expand")){
            $JiraIssue.psobject.Properties.Remove($RootKey);
            $RootKeyDeleted = $true;
        }
    }
    foreach($Key in $JiraIssue.fields.psobject.Properties.Name){
        if(($Key.StartsWith("customfield")) -or (($Key -ne "description") -and (($JiraIssue.fields.$Key -eq $null) -or ($JiraIssue.fields.$Key.Length -eq 0)))) {
            $JiraIssue.fields.psobject.Properties.Remove($Key);
            $KeyDeleted = $true;
        }
        elseif ($Key -eq "description" -and (($JiraIssue.fields.$Key -eq $null) -or ($JiraIssue.fields.$Key.Length -eq 0))) {
            $JiraIssue.fields.$Key = [Text.Encoding]::UTF8.GetBytes("");
        }
        elseif ($Key -eq "description") {
            $JiraIssue.fields.$Key = [Text.Encoding]::UTF8.GetBytes($JiraIssue.fields.$Key);
        }
    }
    Set-Logger -Folder $RootFolder -Origin "JiraExtensions" -Content "$($JiraIssue.key)";

    $(ConvertTo-Json $JiraIssue -Depth 100) | Set-Content "$($RootFolder)\Data\JIRA\Issues\Issue_$($JiraIssue.key).json" -Encoding UTF8;

    return $JiraIssue;
}

function Get-JiraIssues {
    $pair = "$($JiraUser):$($JiraToken)";
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair));
    $basicAuthValue = "Basic $encodedCreds";
    
    $Headers = @{Authorization = $basicAuthValue;};

    $JiraIssuesQuery = "$($JiraServerUrl)/search?jql=project=JiraProject AND (created >= startOfDay(-$($JiraDaysOffset)d) OR updated >= startOfDay(-$($JiraDaysOffset)d)) ORDER BY created ASC";

    $JiraTotalIssues = $(ConvertFrom-Json (Invoke-WebRequest -Uri $JiraIssuesQuery -Headers $Headers -ContentType "application/json; charset=utf-8").Content).total;
    $JiraStartPosition = 0;
    $JiraIssueIndex = 0;
    $JiraIssues = @();

    while ($JiraStartPosition -le $JiraTotalIssues){
        $Body = @{
            startAt = $JiraStartPosition;
            maxResults = 50;
        }
        $JiraIssuesTemporary = $(ConvertFrom-Json (Invoke-WebRequest -Uri "$JiraIssuesQuery" -Headers $Headers -Body $Body -ContentType "application/json; charset=utf-8").Content).issues;
        foreach($JiraIssue in $JiraIssuesTemporary){
            $JiraIssue = Get-JiraIssue -JiraUrl $JiraIssue.self;
            foreach($RootKey in $JiraIssue.psobject.Properties.Name){
                if($RootKey.StartsWith("expand")){
                    $JiraIssue.psobject.Properties.Remove($RootKey);
                    $RootKeyDeleted = $true;
                }
            }
            foreach($Key in $JiraIssue.fields.psobject.Properties.Name){
                if(($Key.StartsWith("customfield")) -or (($Key -ne "description") -and (($JiraIssue.fields.$Key -eq $null) -or ($JiraIssue.fields.$Key.Length -eq 0)))) {
                    $JiraIssue.fields.psobject.Properties.Remove($Key);
                    $KeyDeleted = $true;
                }
                elseif ($Key -eq "description" -and (($JiraIssue.fields.$Key -eq $null) -or ($JiraIssue.fields.$Key.Length -eq 0))) {
                    $JiraIssue.fields.$Key = [Text.Encoding]::UTF8.GetBytes("");
                }
                elseif ($Key -eq "description") {
                    $JiraIssue.fields.$Key = [Text.Encoding]::UTF8.GetBytes($JiraIssue.fields.$Key);
                }
            }
            # Adding Or Updating WorkItems From Jira
            $WorkItem = Process-WorkItem -JiraIssue $JiraIssue;
            
            # Updating WorkItems Links (Parent/Child, Builds, Changesets, Tags) From Jira
            $WorkItem = Update-WorkItemLinks -JiraIssue $JiraIssue;
        }

        $JiraIssues += $JiraIssuesTemporary;

        $JiraStartPosition += 50;
    }

    $(ConvertTo-Json $JiraIssues -Depth 100) | Set-Content "$($RootFolder)\Data\JIRA\Issues.json" -Encoding UTF8;

    return $JiraIssues;
}
