function Add-BuildToWorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Parameter(Mandatory)]
        [Alias("TfsBuildUri")] 
        [string]$BuildUri
    )

    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WI.id)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $UpdateWorkItemRequestBody = "[{`"op`": `"test`",`"path`": `"/rev`",`"value`": `"$($WI.rev)`"},{`"op`":`"add`",`"path`":`"/relations/-`",`"value`":{`"rel`":`"ArtifactLink`",`"url`":`"$BuildUri`",`"attributes`":{`"name`":`"Integrated in build`"}}}]";

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Build added to WorkItem $($WI.id) ($($WI.fields.'System.Title'))";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($UpdateWorkItemRequestBody)";
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Add-ChangesetToWorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Parameter(Mandatory)]
        [Alias("TfsChangesetUri")] 
        [string]$ChangesetUri
    )

    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WI.id)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $UpdateWorkItemRequestBody = "[{`"op`": `"test`",`"path`": `"/rev`",`"value`": `"$($WI.rev)`"},{`"op`":`"add`",`"path`":`"/relations/-`",`"value`":{`"rel`":`"ArtifactLink`",`"url`":`"$ChangesetUri`",`"attributes`":{`"name`":`"Fixed in Changeset`"}}}]";

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Changeset added to WorkItem $($WI.id) ($($WI.fields.'System.Title'))";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($UpdateWorkItemRequestBody)";
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Add-ChildWorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Parameter(Mandatory)]
        [Alias("WorkItemChildKey")] 
        [string]$WIChildKey
    )
    
    $ChildWorkItem = $(Get-WorkItemByTitle -WorkItemTitle $WIChildKey)[0];

    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($ChildWorkItem.id)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $UpdateWorkItemRequestBody = @();
    $UpdateWorkItemRequestBody += @{
        "op" = "test";
        "path" = "/rev";
        "value" = "$($ChildWorkItem.rev)";
    };
    $UpdateWorkItemRequestBody += @{
        "op" = "add";
        "path" = "/relations/-";
        "value" = @{
            "rel" = "System.LinkTypes.Hierarchy-Reverse";
            "url" = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workItems/$($WI.id)";
        }
    };

    $UpdateWorkItemRequestBody = [Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $UpdateWorkItemRequestBody));

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Child WorkItem $($ChildWorkItem.id) Linked to parent $($WI.id)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($UpdateWorkItemRequestBody)";
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Add-ParentWorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Parameter(Mandatory)]
        [Alias("WorkItemParentKey")] 
        [string]$WIParentKey
    )
    
    $ParentWorkItem = $(Get-WorkItemByTitle -WorkItemTitle $WIParentKey)[0];

    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($ParentWorkItem.id)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $UpdateWorkItemRequestBody = @();
    $UpdateWorkItemRequestBody += @{
        "op" = "test";
        "path" = "/rev";
        "value" = "$($ParentWorkItem.rev)";
    };
    $UpdateWorkItemRequestBody += @{
        "op" = "add";
        "path" = "/relations/-";
        "value" = @{
            "rel" = "System.LinkTypes.Hierarchy-Forward";
            "url" = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workItems/$($WI.id)";
        }
    };

    $UpdateWorkItemRequestBody = [Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $UpdateWorkItemRequestBody));

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Parent WorkItem $($ParentWorkItem.id) Linked to Child $($WI.id)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($UpdateWorkItemRequestBody)";
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Add-TagToWorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Parameter(Mandatory)]
        [Alias("TfsWorkItemTag")] 
        [string]$WorkItemTag
    )

    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WI.id)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $UpdateWorkItemRequestBody = [Text.Encoding]::UTF8.GetBytes("[{`"op`": `"test`",`"path`": `"/rev`",`"value`": `"$($WI.rev)`"},{`"op`":`"add`",`"path`":`"/fields/System.Tags`",`"value`":`"$($WorkItemTag)`"}]");

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Tag $($WorkItemTag) added to WorkItem $($WI.id) ($($WI.fields.'System.Title'))";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($UpdateWorkItemRequestBody)";
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Get-ChildWorkItems {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")] 
        [object]$Issue,
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI
    )

    $IssueChildren = @()
    $WorkItemChildren = @()
    
    if($($Issue.fields.psobject.Properties.Name.Where{$_ -eq "subtasks"}).Count -gt 0){
        foreach ($IssueSubtask in $Issue.fields.subtasks){
            $IssueChildren += "$($IssueSubtask.key) ";
        }
    }

    if (-not (($WI -eq $null) -or ($WI.Count -eq 0) -or ($WI.Length -eq 0))) {
        foreach ($relation in $WI.relations){
            if ($relation.rel -eq "System.LinkTypes.Hierarchy-Forward"){
                $RelationWorkItemId = $relation.url.Substring($relation.url.LastIndexOf('/') + 1);
                $ChildWorkItem = Get-WorkItemById -WorkItemId $RelationWorkItemId -ExpandAll $true;
                if (-not (($ChildWorkItem -eq $null) -or ($ChildWorkItem.Count -eq 0) -or ($ChildWorkItem.Length -eq 0))) {
                    $WorkItemChildren += $($ChildWorkItem.fields."System.Title").Substring(0, $($ChildWorkItem.fields."System.Title").IndexOf(":"));
                }
            }
        }
    }

    foreach ($IssueChild in $IssueChildren){
        if ($WorkItemChildren.Where{$_ -eq $IssueChild}.Count -eq 0){
            Add-ChildWorkItem -WorkItem $WI -WorkItemChildKey $IssueChild;
        }
    }
    foreach ($WorkItemChild in $WorkItemChildren){
        if ($IssueChildren.Where{$_ -eq $WorkItemChild}.Count -eq 0){
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($WorkItemChild) To Be Removed.";
        }
    }
}
function Get-ParentWorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")] 
        [object]$Issue,
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI
    )

    $IssueParents = @()
    $WorkItemParents = @()
    
    if($($Issue.fields.psobject.Properties.Name.Where{$_ -eq "parent"}).Count -gt 0){
        $IssueParents += "$($Issue.fields.parent.key) ";
    }
    if (-not (($WI -eq $null) -or ($WI.Count -eq 0) -or ($WI.Length -eq 0))) {
        foreach ($relation in $WI.relations){
            if ($relation.rel -eq "System.LinkTypes.Hierarchy-Reverse"){
                $RelationWorkItemId = $relation.url.Substring($relation.url.LastIndexOf('/') + 1);
                $ParentWorkItem = Get-WorkItemById -WorkItemId $RelationWorkItemId -ExpandAll $true;
                if (-not (($ParentWorkItem -eq $null) -or ($ParentWorkItem.Count -eq 0) -or ($ParentWorkItem.Length -eq 0))) {
                    $WorkItemParents += $($ParentWorkItem.fields."System.Title").Substring(0, $($ParentWorkItem.fields."System.Title").IndexOf(":"));
                }
            }
        }
    }
    foreach ($IssueParent in $IssueParents){
        if ($WorkItemParents.Where{$_ -eq $IssueParent}.Count -eq 0){
            Add-ParentWorkItem -WorkItem $WI -WorkItemParentKey $IssueParent;
        }
    }
    foreach ($WorkItemParent in $WorkItemParents){
        if ($IssueParents.Where{$_ -eq $WorkItemParent}.Count -eq 0){
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($WorkItemParent) To Be Removed.";
        }
    }
}
function Get-WorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItemKey")] 
        [string]$WIKey
    )

    $GetWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/wiql?api-version=5.0";

    $GetWorkItemRequestBody = "{`"query`": `"SELECT [System.AssignedTo],[System.ChangedDate],[System.CreatedBy],[System.Description],[System.Id],[System.State],[System.TeamProject],[System.Title],[System.WorkItemType] FROM workitems WHERE [System.Title] CONTAINS '$WIKey ' ORDER BY [System.Id] DESC`"}";

    try{
        $WorkItems = Invoke-RestMethod -Method Post -UseDefaultCredentials -Uri $GetWorkItemUrl -Body $GetWorkItemRequestBody -ContentType "application/json; charset=utf-8";

        if ($WorkItems.workitems.Count -gt 0){
            $WorkItem = (Invoke-RestMethod -Method Get -UseDefaultCredentials -uri $($WorkItems.workitems[0]).url);
            return $WorkItem;
        }
        else{
            return $null;
        }
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $GetWorkItemRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$WIKey : Error : $($Error[0].exception.GetBaseException().Message)";
        return $null;
    }
}
function Get-WorkItemById {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItemId")] 
        [string]$WIId,
        [Alias("ExpandAll")]
        [boolean]$expand
    )

    try{
        if ($expand -eq $true){
            $GetWorkItemByIdUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?`$expand=All&api-version=5.0";
        }
        else{
            $GetWorkItemByIdUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?api-version=5.0";
        }

        $WorkItem = Invoke-RestMethod -Method Get -UseDefaultCredentials -uri $GetWorkItemByIdUrl;
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $null;
    }
}
function Get-WorkItemByTitle {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItemTitle")] 
        [string]$WITitle
    )

    $WorkItems = @();

    $GetWorkItemByTitleUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/wiql?api-version=5.0";

    $GetWorkItemByTitleRequestBody = ConvertTo-Json @{"query" = "SELECT [System.Id],[System.Description],[System.State],[System.TeamProject],[System.Title],[System.WorkItemType] FROM workitems WHERE [System.Title] CONTAINS '$($WITitle)' ORDER BY [System.Id] DESC"};

    try{
        $WorkItemsUrls = $(Invoke-RestMethod -Method Post -UseDefaultCredentials -Uri $GetWorkItemByTitleUrl -Body $GetWorkItemByTitleRequestBody -ContentType "application/json; charset=utf-8").workitems;
        
        foreach($WorkItemUrl in $WorkItemsUrls)
        {
            $WorkItem = Get-WorkItemById -WorkItemId $WorkItemUrl.id -ExpandAll $true;
            $WorkItems += $WorkItem;
        }

        return $WorkItems;
    }
    catch{
        Set-Logger -Folder $RootFolder -WriteToHost $false -Origin "TFSExtensions" -Content $GetWorkItemByTitleRequestBody;
        Set-Logger -Folder $RootFolder -WriteToHost $false -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $null;
    }
}
function Get-WorkItemByUrl {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItemUrl")] 
        [string]$WIUrl
    )

    try{
        $WorkItem = Invoke-RestMethod -Method Get -UseDefaultCredentials -uri $WIUrl;
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $null;
    }
}
function Get-Build {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("BuildUrl")] 
        [string]$GetBuildUrl
    )

    try{
        $Build = Invoke-RestMethod -Method Get -UseDefaultCredentials -uri $GetBuildUrl;
        
        return $Build;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $null;
    }
}
function Get-Builds {
    try{
        $GetBuildsUrl = "$TFSServerUrl/$TFSTeamProject/_apis/build/builds?api-version=5.0";

        $Builds = $(Invoke-RestMethod -Method Get -UseDefaultCredentials -uri $GetBuildsUrl).value;
        
        return $Builds;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $null;
    }
}
function Get-Changesets {
    try{
        $GetChangesetsUrl = "$TFSServerUrl/$TFSTeamProject/_apis/tfvc/changesets?`$top=10000&api-version=5.0";

        $GetChangesetsResult = Invoke-RestMethod -Method Get -UseDefaultCredentials -uri $GetChangesetsUrl;

        $Changesets = $GetChangesetsResult.value;
        
        return $Changesets;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $null;
    }
}
function Get-WorkItemRelationTypes {
    try{
        $GetWorkItemRelationTypesUrl = "$TFSServerUrl/$TFSTeamProject/_apis/wit/workitemrelationtypes?api-version=5.0";

        $GetWorkItemRelationTypesResult = Invoke-RestMethod -Method Get -UseDefaultCredentials -uri $GetWorkItemRelationTypesUrl;

        $WorkItemRelationTypes = $GetWorkItemRelationTypesResult.value;
        
        return $WorkItemRelationTypes;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $null;
    }
}
function Get-WorkItems {
    $WorkItems = @();

    $QueryID = "08861f43-aa47-4997-9421-49d6034b6fe7";

    $GetWorkItemsUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/wiql/$($QueryID)?api-Version=1.0";

    $WorkItemsUrls = Get-WorkItemsUrls;

    foreach($WorkItemUrl in $WorkItemsUrls)
    {
        $WorkItem = Get-WorkItemById -WorkItemId $WorkItemUrl.id -ExpandAll $false;
        $WorkItems += $WorkItem;
    }

    $WorkItems > "$($RootFolder)\Data\TFS\WorkItemsRaw.json";
    $(ConvertTo-Json $WorkItems -Depth 100 -Verbose) > "$($RootFolder)\Data\TFS\WorkItems.json";
    
    return $WorkItems;
}
function Get-WorkItemsUrls {
    $QueryID = "08861f43-aa47-4997-9421-49d6034b6fe7";

    $GetWorkItemsUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/wiql/$($QueryID)?api-Version=1.0";

    #Get Workitem IDs from the query
    $WorkItemsUrls = (Invoke-RestMethod -Method Get -UseDefaultCredentials -uri $GetWorkItemsUrl).workItems
    $(ConvertTo-Json $WorkItemsUrls -Depth 100 -Verbose) > "$($RootFolder)\Data\TFS\WorkItemsUrls.json"
    
    return $WorkItemsUrls;
}
function Get-WorkItemTypes {
    $WorkItemTypes = @{};

    $GetWorkItemTypesUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitemtypes?api-version=5.0";

    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions");
    $WebClient = New-Object System.Net.WebClient
    $WebClient.UseDefaultCredentials = $true;
    $WebClient.Encoding = [System.Text.Encoding]::UTF8;
    $WorkItemTypesResponse = $WebClient.DownloadString($GetWorkItemTypesUrl);
    
    $jsonserial = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer;
    $jsonserial.MaxJsonLength  = 67108864
    $WorkItemTypesValue = $($jsonserial.DeserializeObject($WorkItemTypesResponse)).value;
    
    $(ConvertTo-Json $WorkItemTypesValue -Depth 100 -Verbose) > "$($RootFolder)\Data\TFS\WorkItemTypes.json";
    
    $WorkItemTypeId = 0;
    foreach($WorkItemType in $WorkItemTypesValue){
        # $WorkItemTypes.Add($WorkItemTypeId, @{"Name" = $WorkItemType.name; "URL" = $WorkItemType.url})
        $WorkItemTypes.Add($WorkItemTypeId, $WorkItemType.name)
        $WorkItemTypeStates = Get-WorkItemTypeStates -WorkItemType $WorkItemType.name;
        $WorkItemTypeId += 1;
    }
    
    return $WorkItemTypes;
}
function Get-WorkItemTypeStates {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItemType")] 
        [string]$WIType
    )

    $WorkItemTypeStates = @{};

    $ListWorkItemStatesUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitemtypes/$($WIType)/states?api-version=5.0-preview.1";

    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions");
    $WebClient = New-Object System.Net.WebClient
    $WebClient.UseDefaultCredentials = $true;
    $WebClient.Encoding = [System.Text.Encoding]::UTF8;
    $WorkItemTypeStatesResponse = $WebClient.DownloadString($ListWorkItemStatesUrl);
    
    $jsonserial = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer;
    $jsonserial.MaxJsonLength  = 67108864
    $WorkItemTypeStatesValue = $($jsonserial.DeserializeObject($WorkItemTypeStatesResponse)).value;
    
    $(ConvertTo-Json $WorkItemTypeStatesValue -Depth 100 -Verbose) > "$($RootFolder)\Data\TFS\WorkItemTypeStates\$($WIType).json";
    
    $WorkItemTypeStateId = 0;
    foreach($WorkItemTypeState in $WorkItemTypeStatesValue){
        $WorkItemTypeStates.Add($WorkItemTypeStateId, $WorkItemTypeState.name)
        $WorkItemTypeStateId += 1;
    }
    
    return $WorkItemTypeStates;
}
function Process-WorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")] 
        [object]$Issue
    )

    $WIType = Get-WorkItemType -JiraIssue $Issue;
    $WITitle = Get-JiraIssueTitle -JiraIssue $Issue;
    $WIStatus = Get-WorkItemStatus -JiraIssue $Issue;
    $WICreatedBy = Get-JiraIssueCreatedBy -JiraIssue $Issue;
    $WICreatedDate = Get-JiraIssueCreatedDate -JiraIssue $Issue;
    $WIAssignedTo = Get-JiraIssueAssignedTo -JiraIssue $Issue;
    $WIClosedDate = Get-JiraIssueClosedDate -JiraIssue $Issue;
    # $WIDescription = Get-JiraIssueDescription -JiraIssue $Issue;
    $WIChangedDate = Get-JiraIssueChangedDate -JiraIssue $Issue;

    $WorkItem = Get-WorkItemByTitle -WorkItemTitle "$($Issue.key) ";

    if ((($WorkItem -eq $null) -or ($WorkItem.Count -eq 0) -or ($WorkItem.Length -eq 0))) {
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "WorkItem not found : $($Issue.key)";
        $MinimalRequestBody = @();
        $FullRequestBody = @();

        $Headers = @{
            "Content-Type" = "application/json-patch+json; charset=utf-8";
        }

        $AddWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/`$$($WIType)?bypassRules=true&api-version=5.0";
        
        $MinimalRequestBody += @{"op" = "add"; "path" = "/fields/System.Title"; "value" = "$WITitle";}
        $MinimalRequestBody += @{"op" = "add"; "path" = "/fields/System.State"; "value" = "$WIStatus";}
        $MinimalRequestBody += @{"op" = "add"; "path" = "/fields/System.CreatedBy"; "value" = "$WICreatedBy";}
        $MinimalRequestBody += @{"op" = "add"; "path" = "/fields/System.CreatedDate"; "value" = "$($WICreatedDate)";}
        if($WIAssignedTo.Length -gt 0){
            $MinimalRequestBody += @{"op" = "add"; "path" = "/fields/System.AssignedTo"; "value" = "$WIAssignedTo";}
        }
        if($WIClosedDate.Length -gt 0){
            $MinimalRequestBody += @{"op" = "add"; "path" = "/fields/Microsoft.VSTS.Common.ClosedDate"; "value" = "$WIClosedDate";}
        }
        $FullRequestBody = $MinimalRequestBody;
        $MinimalRequestBody = [Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $MinimalRequestBody));

        # $FullRequestBody += @{"op" = "add"; "path" = "/fields/System.Description"; "value" = "$WIDescription";}

        $FullRequestBody += @{"op" = "add"; "path" = "/fields/System.ChangedDate"; "value" = "$($WIChangedDate)";}
        
        # $FullRequestBody = $Encoding.GetString([Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $FullRequestBody)));
        $FullRequestBody = [Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $FullRequestBody));
        
        try{
            # $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $AddWorkItemUrl -Body $FullRequestBody -ContentType "application/json-patch+json; charset=utf-8";
            $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $AddWorkItemUrl -Headers $Headers -Body $FullRequestBody;

            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "WorkItem Added (FullRequestBody) : $($WIType) $($WITitle) => $($WorkItem.id)";
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "WorkItem Added (FullRequestBody) : $($WIType) $($WITitle) => $($WorkItem.id)`r`nRequest Body : $([Text.Encoding]::UTF8.GetString($FullRequestBody))" -WriteToHost $false;
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "*************`r`n*************";

            return $WorkItem;
        }
        catch{
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "WorkItem Adding with FullRequestBody Failed : $($WIType) $($WITitle)`r`n---------------------------------";
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Request Body : $([Text.Encoding]::UTF8.GetString($FullRequestBody))`r`n---------------------------------" -WriteToHost $false;

            try{
                $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $AddWorkItemUrl -Headers $Headers -Body $MinimalRequestBody;

                Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "WorkItem Added (MinimalRequestBody) : $($WIType) $($WITitle) => $($WorkItem.id)";
                Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Request Body : $([Text.Encoding]::UTF8.GetString($MinimalRequestBody))" -WriteToHost $false;
                Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "*************`r`n*************";

                return $WorkItem;
            }
            catch{
                Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "WorkItem Adding with MinimalRequestBody Failed : $($WIType) $($WITitle)`r`n---------------------------------";
                Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Request Body : $([Text.Encoding]::UTF8.GetString($MinimalRequestBody))`r`n---------------------------------" -WriteToHost $false;
                Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "---------------------------------`r`n$_`r`nError : $($Error[0].exception.GetBaseException().Message)`r`n$($Error[0].exception.StackTrace)";
                Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "*************`r`n*************";
                return $null;
            }
        }
    }
    else {
        if((-not [string]::IsNullOrEmpty($WIAssignedTo)) -and (-not ($WIAssignedTo -ieq $WorkItem.fields."System.AssignedTo".displayName))) {
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($Issue.key) : Updating AssignedTo`r`nFrom : $($WorkItem.fields."System.AssignedTo".displayName)`r`nTo : $($WIAssignedTo)";
            $WorkItem = Update-WorkItemAssignedTo -WorkItem $WorkItem -WorkItemAssignedTo $WIAssignedTo;
        }
        if(-not ($WIStatus -ieq $WorkItem.fields."System.State")) {
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($Issue.key) : Updating Status`r`nFrom : $($WorkItem.fields."System.State")`r`nTo : $($WIStatus)";
            $WorkItem = Update-WorkItemStatus -WorkItem $WorkItem -WorkItemStatus $WIStatus;
        }
        if(-not ($WITitle -ieq $WorkItem.fields."System.Title")) {
            Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$($Issue.key) : Updating Title`r`nFrom : $($WorkItem.fields."System.Title")`r`nTo : $($WITitle)";
            $WorkItem = Update-WorkItemTitle -WorkItem $WorkItem -WorkItemTitle $WITitle;
        }
        # $WIDescription = [System.Web.HttpUtility]::HtmlDecode([regex]::Escape($WIDescription));
        # if (-not ([System.Web.HttpUtility]::HtmlDecode($([regex]::Escape($WorkItem.fields."System.Description"))) -ieq $WIDescription)) {
        #     Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Updating Description`r`nFrom : $([System.Web.HttpUtility]::HtmlDecode([regex]::Escape($WorkItem.fields."System.Description")))`r`nTo : $WIDescription)";
        #     $WorkItem = Update-WorkItemDescription -WorkItem $WorkItem -WorkItemDescription $WIDescription;
        # }
    }
    return $WorkItem;
}
function Update-ChildWorkItems {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")] 
        [object]$Issue,
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI
    )
    Get-ChildWorkItems -JiraIssue $Issue -WorkItem $WI;
}
function Update-ParentWorkItem {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")] 
        [object]$Issue,
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI
    )
    Get-ParentWorkItem -JiraIssue $Issue -WorkItem $WI;
}
function Update-WorkItemDuplicate {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")]
        [object]$WI,
        [Parameter(Mandatory)]
        [Alias("WorkItemOriginalId")]
        [int]$WIOriginalId,
        [Alias("WorkItemDuplicateId")]
        [int]$WIDuplicateId
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemDuplicateUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WI.id)?bypassRules=true&api-version=5.0";

    $UpdateWorkItemDuplicateRequestBody = "[{`"op`": `"test`",`"path`": `"/rev`",`"value`": `"$($WIRev)`"},{`"op`": `"add`",`"path`": `"/relations/-`",`"value`": {`"rel`": `"System.LinkTypes.Duplicate-Forward`",`"url`": `"$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workItems/$($WIDuplicateId)`",`"attributes`": {`"comment`":`"WorkItem Duplicated`"}}}]";

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemDuplicateUrl -Body $UpdateWorkItemDuplicateRequestBody -ContentType "application/json-patch+json; charset=utf-8";

        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Duplicate relationship added : $($WIOriginalId) $($WIDuplicateId)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemDuplicateRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Update-WorkItemAssignedTo {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Alias("WorkItemAssignedTo")] 
        [string]$WIAssignedTo
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $UpdateWorkItemRequestBody = @();
    $UpdateWorkItemRequestBody += @{"op" = "test"; "path" = "/rev"; "value" = "$WIRev";}
    $UpdateWorkItemRequestBody += @{"op" = "add"; "path" = "/fields/System.AssignedTo"; "value" = "$WIAssignedTo";}
    $UpdateWorkItemRequestBody = [Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $UpdateWorkItemRequestBody));

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Assigned To Updated : $($WIAssignedTo)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Update-WorkItemChangedDate {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Alias("WorkItemChangedDate")] 
        [string]$WIChangedDate
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemChangedDateUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?bypassRules=true&api-version=5.0";

    $UpdateWorkItemChangedDateRequestBody = "[{`"op`": `"test`",`"path`": `"/rev`",`"value`": `"$($WIRev)`"},{`"op`": `"add`",`"path`": `"/fields/System.ChangedDate`",`"value`": `"$($WIChangedDate)`"}]";

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemChangedDateUrl -Body $UpdateWorkItemChangedDateRequestBody -ContentType "application/json-patch+json; charset=utf-8";

        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Changed Date Updated : $($WIChangedDate)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemChangedDateRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Update-WorkItemClosedDate {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Alias("WorkItemClosedDate")] 
        [string]$WIClosedDate
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemClosedDateUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?bypassRules=true&api-version=5.0";

    $UpdateWorkItemClosedDateRequestBody = "[{`"op`": `"test`",`"path`": `"/rev`",`"value`": `"$($WIRev)`"},{`"op`": `"add`",`"path`": `"/fields/Microsoft.VSTS.Common.ClosedDate`",`"value`": `"$($WIClosedDate)`"}]";

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemClosedDateUrl -Body $UpdateWorkItemClosedDateRequestBody -ContentType "application/json-patch+json; charset=utf-8";

        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Closed Date Updated : $($WIClosedDate)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemClosedDateRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Update-WorkItemCreatedBy {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Alias("WorkItemCreatedBy")] 
        [string]$WICreatedBy
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemCreatedByUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?bypassRules=true&api-version=5.0";

    $UpdateWorkItemCreatedByRequestBody = "[{`"op`": `"test`",`"path`": `"/rev`",`"value`": `"$($WIRev)`"},{`"op`": `"add`",`"path`": `"/fields/System.CreatedBy`",`"value`": `"$($WICreatedBy)`"}]";

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemCreatedByUrl -Body $UpdateWorkItemCreatedByRequestBody -ContentType "application/json-patch+json; charset=utf-8";

        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Created By Updated : $($WICreatedBy)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemCreatedByRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Update-WorkItemCreatedDate {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Alias("WorkItemCreatedDate")] 
        [string]$WICreatedDate
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemCreatedDateUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?bypassRules=true&api-version=5.0";

    $UpdateWorkItemCreatedDateRequestBody = "[{`"op`": `"test`",`"path`": `"/rev`",`"value`": `"$($WIRev)`"},{`"op`": `"add`",`"path`": `"/fields/System.CreatedDate`",`"value`": `"$($WICreatedDate)`"}]";

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemCreatedDateUrl -Body $UpdateWorkItemCreatedDateRequestBody -ContentType "application/json-patch+json; charset=utf-8";

        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Created Date Updated : $($WICreatedDate)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemCreatedDateRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Error : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Update-WorkItemDescription {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Parameter(Mandatory)]
        [Alias("WorkItemDescription")] 
        [string]$WIDescription
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $WIDescription = [System.Web.HttpUtility]::HtmlEncode([regex]::Unescape($WIDescription));

    $UpdateWorkItemRequestBody = @();
    $UpdateWorkItemRequestBody += @{"op" = "test"; "path" = "/rev"; "value" = "$WIRev";}
    $UpdateWorkItemRequestBody += @{"op" = "add"; "path" = "/fields/System.Description"; "value" = "$WIDescription";}
    $UpdateWorkItemRequestBody = [Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $UpdateWorkItemRequestBody));

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Description Updated : $($WIDescription)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Update-WorkItemLinks {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("JiraIssue")] 
        [object]$Issue
    )

    $WorkItem = Get-WorkItemByTitle -WorkItemTitle "$($Issue.key) ";

    if (-not (($WorkItem -eq $null) -or ($WorkItem.Count -eq 0) -or ($WorkItem.Length -eq 0))) {
        $WorkItem = Update-ParentWorkItem -JiraIssue $Issue -WorkItem $WorkItem;
    }
    $WorkItem = Get-WorkItemByTitle -WorkItemTitle "$($Issue.key) ";
    if (-not (($WorkItem -eq $null) -or ($WorkItem.Count -eq 0) -or ($WorkItem.Length -eq 0))) {
        $WorkItem = Update-ChildWorkItems -JiraIssue $Issue -WorkItem $WorkItem;
    }

    $WorkItem = Get-WorkItemByTitle -WorkItemTitle "$($Issue.key) ";
    
    $ExistingChangesetsLinks = @();
    foreach ($relation in $WorkItem.relations.Where{($_.rel -eq "ArtifactLink") -and ($_.url.StartsWith("vstfs:///VersionControl/Changeset"))}){
        $ExistingChangesetsLinks += $relation.url.Substring($relation.url.LastIndexOf("/") + 1);
    }
    
    $ExistingBuildsLinks = @();
    foreach ($relation in $WorkItem.relations.Where{($_.rel -eq "ArtifactLink") -and ($_.url.StartsWith("vstfs:///Build/Build"))}){
        $ExistingBuildsLinks += $relation.url.Substring($relation.url.LastIndexOf("/") + 1);
    }

    foreach($TfsChangeset in $TfsChangesets){
        if ($($TfsChangeset.comment).StartsWith("$($Issue.key) ")){
            if ($ExistingChangesetsLinks.Where{$_ -eq $TfsChangeset.changesetId}.Count -eq 0){
                $WorkItem = Add-ChangesetToWorkItem -WorkItem $WorkItem -TfsChangesetUri "vstfs:///VersionControl/Changeset/$($TfsChangeset.changesetId)";
            }
            $TfsChangesetBuilds = $TfsBuilds.Where{$($_.sourceVersion.Replace('C','')) -eq $TfsChangeset.changesetId}
            foreach($TfsChangesetBuild in $TfsChangesetBuilds){
                if ($ExistingBuildsLinks.Where{$_ -eq $TfsChangesetBuild.id}.Count -eq 0){
                    $WorkItem = Add-BuildToWorkItem -WorkItem $WorkItem -TfsBuildUri $TfsChangesetBuild.uri;
                }
            }
        }
    }
        
    $WorkItemTags = @();
    if($($WorkItem.fields.psobject.Properties.Name.Where{$_ -eq "System.Tags"}).Count -gt 0){
        foreach ($WorkItemTag in $WorkItem.fields."System.Tags".Split(";")) {
            $WorkItemTags += $WorkItemTag.Trim();
        }
    }
    if($($Issue.fields.psobject.Properties.Name.Where{$_ -eq "labels"}).Count -gt 0){
        foreach($JiraLabel in $Issue.fields.labels){
            if ($WorkItemTags.Where{$_ -eq $JiraLabel}.Count -eq 0) {
                $JiraLabel = $WorkItem.fields."System.Tags" + "; " + $JiraLabel;
                $WorkItem = Add-TagToWorkItem -WorkItem $WorkItem -WorkItemTag $JiraLabel;
            }
        }    
    }
}
function Update-WorkItemStatus {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Alias("WorkItemStatus")] 
        [string]$WIStatus
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $UpdateWorkItemRequestBody = @();
    $UpdateWorkItemRequestBody += @{"op" = "test"; "path" = "/rev"; "value" = "$WIRev";}
    $UpdateWorkItemRequestBody += @{"op" = "add"; "path" = "/fields/System.State"; "value" = "$WIStatus";}
    $UpdateWorkItemRequestBody = [Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $UpdateWorkItemRequestBody));

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Status Updated : $($WIStatus)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
function Update-WorkItemTitle {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("WorkItem")] 
        [object]$WI,
        [Alias("WorkItemTitle")] 
        [string]$WITitle
    )
    
    $WIId = $WI.id
    $WIRev = $WI.rev
        
    $UpdateWorkItemUrl = "$($TFSServerUrl)/$($TFSTeamProject)/_apis/wit/workitems/$($WIId)?bypassRules=true&api-version=5.0";

    $Headers = @{
        "Content-Type" = "application/json-patch+json; charset=utf-8";
    }

    $UpdateWorkItemRequestBody = @();
    $UpdateWorkItemRequestBody += @{"op" = "test"; "path" = "/rev"; "value" = "$WIRev";}
    $UpdateWorkItemRequestBody += @{"op" = "add"; "path" = "/fields/System.Title"; "value" = "$WITitle";}
    $UpdateWorkItemRequestBody = [Text.Encoding]::UTF8.GetBytes($(ConvertTo-Json $UpdateWorkItemRequestBody));

    try{
        $WorkItem = Invoke-RestMethod -Method Patch -UseDefaultCredentials -Uri $UpdateWorkItemUrl -Headers $Headers -Body $UpdateWorkItemRequestBody;
    
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "Title Updated : $($WITitle)";
        
        return $WorkItem;
    }
    catch{
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content $UpdateWorkItemRequestBody;
        Set-Logger -Folder $RootFolder -Origin "TFSExtensions" -Content "$_`r`nError : $($Error[0].exception.GetBaseException().Message)";
        return $WI;
    }
}
