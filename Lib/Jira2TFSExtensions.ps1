
function Get-WorkItemType {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")] 
        [object]$Issue
    )

    if ($Issue.fields.issuetype.name -eq "Epic") {
        $WIType = "Épopée";
    }
    elseif ($Issue.fields.issuetype.name -eq "Story") {
        $WIType = "Scénario utilisateur";
    }
    elseif ($Issue.fields.issuetype.name -eq "Sub-task") {
        $WIType = "Tâche";
    }
    elseif ($Issue.fields.issuetype.name -eq "Incident") {
        $WIType = "Bogue";
    }
    else {
        $WIType = "Fonctionnalité";
    }
    
    $WorkItemType = [Text.Encoding]::UTF8.GetString([Text.Encoding]::GetEncoding(1252).GetBytes($WIType));

    Set-Logger -Folder $RootFolder -Origin "Jira2TFSExtensions" -WriteToHost $false -Content "$($Issue.key): Jira Issue Type : $($Issue.fields.issuetype.name), WorkItem Type : $($WorkItemType)";

    return $WorkItemType;
    # return $WIType;
}
function Get-WorkItemStatus {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")] 
        [object]$Issue
    )

    if ($Issue.fields.status.name -ieq 'OPEN') {
        $WIStatus = 'Nouveau';
    }
    elseif (($Issue.fields.status.name -ieq 'IN PROGRESS') -or ($Issue.fields.status.name -ieq 'CODING') -or ($Issue.fields.status.name -ieq 'PENDING') -or ($Issue.fields.status.name -ieq 'TO BE TESTED') -or ($Issue.fields.status.name -ieq 'TESTED')) {
        $WIStatus = 'Actif';
    }
    elseif (($Issue.fields.status.name -ieq 'CANCELLED') -and ($Issue.fields.issuetype.name -ieq 'Incident')) {
        $WIStatus = 'Fermé';
    }
    elseif ($Issue.fields.status.name -ieq 'CANCELLED') {
        $WIStatus = 'Supprimé';
    }
    elseif ($Issue.fields.status.name -ieq 'DONE') {
        $WIStatus = 'Fermé';
    }
    # elseif (($Issue.fields.status.name -ieq 'DONE') -and ($Issue.fields.issuetype.name -ieq 'SUB-TASK')) {
    #     $WIStatus = 'Fermé';
    # }
    # elseif ($Issue.fields.status.name -ieq 'DONE') {
    #     $WIStatus = [Text.Encoding]::UTF8.GetString($Encoding.GetBytes('Résolu'));
    # }
    else{
        $WIStatus = 'Nouveau';
    }

    $WorkItemStatus = [Text.Encoding]::UTF8.GetString([Text.Encoding]::GetEncoding(1252).GetBytes($WIStatus));

    Set-Logger -Folder $RootFolder -Origin "Jira2TFSExtensions" -WriteToHost $false -Content "$($Issue.key): Jira Issue Status : $($Issue.fields.status.name), WorkItem Status : $($WorkItemStatus)";

    return $WorkItemStatus;
    # return $WIStatus;
}
function Get-JiraIssueCreatedBy {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")]
        [object]$Issue
    )

    # return [Text.Encoding]::GetEncoding(1252).GetString([Text.Encoding]::UTF8.GetBytes($Issue.fields.creator.displayName.Replace(".", " ")));
    return $Issue.fields.creator.displayName.Replace(".", " ");
}
function Get-JiraIssueChangedDate {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")]
        [object]$Issue
    )
    
    return ([DateTime]($Issue.fields.updated)).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.ffZ");
}
function Get-JiraIssueCreatedDate {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")]
        [object]$Issue
    )
    
    return ([DateTime]($Issue.fields.created)).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.ffZ");
}
function Get-JiraIssueClosedDate {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")]
        [object]$Issue
    )
    
    $WIClosedDate = [string]::Empty;
    
    if ((($Issue.fields.status.name -ieq 'CANCELLED') -and ($Issue.fields.issuetype.name -ieq 'Incident')) -or ($Issue.fields.status.name -ieq 'DONE')) {
        $WIClosedDate = ([DateTime]($Issue.fields.statuscategorychangedate)).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.ffZ");
    }
    
    return $WIClosedDate;
}
function Get-JiraIssueDescription {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")]
        [object]$Issue
    )
    
    $WIDescription = [string]::Empty;

    if($($Issue.fields.psobject.Properties.Name.Where{$_ -eq "description"}).Count -gt 0){
        $WIDescription = [regex]::Unescape([System.Web.HttpUtility]::HtmlEncode([Text.Encoding]::UTF8.GetString($Issue.fields.description)));
    }

    return $WIDescription;
}
function Get-JiraIssueAssignedTo {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")]
        [object]$Issue
    )
    
    $WIAssignedTo = [string]::Empty;

    if($($Issue.fields.psobject.Properties.Name.Where{$_ -eq "assignee"}).Count -gt 0){
        $WIAssignedTo = $Issue.fields.assignee.displayName.Replace(".", " ");
    }

    return $WIAssignedTo;
}
function Get-JiraIssueTitle {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")]
        [object]$Issue
    )

    return $Issue.key + " : " + $Issue.fields.summary
}
