function Set-Logger {
    Param
    (
        [Parameter(Mandatory)]
        [Alias("Folder")] 
        [string]$RootFolder,
        [Parameter(Mandatory)]
        [Alias("Content")] 
        [string]$LogContent,
        [Alias("Origin")] 
        [string]$LogOrigin = 'Log',
        [Alias("WriteToFile")] 
        [boolean]$LogToFile = $true,
        [Alias("WriteToHost")] 
        [boolean]$LogToScreen = $true
    )

    $LogFilePath = "$RootFolder\Logs\$(Get-Date -UFormat "%Y%m%d%H")_$LogOrigin.log";

    try {
        $OperationDateTime = $(Get-Date -Format o).Substring(0,24);
        $OperationLog = "$OperationDateTime : $LogContent";

        try{
            if ($LogToFile) {
                "$($OperationLog)" | Add-Content $LogFilePath -Encoding UTF8;
            }
        }
        catch {
            $OperationErrorLog = "$OperationDateTime : Error : $($Error[0].exception.GetBaseException().Message) while processing $($OperationLog) To File";
            
            if ($LogToFile) {
                "$($OperationErrorLog)" | Add-Content $LogFilePath -Encoding UTF8;
            }
    
            if ($LogToScreen) {
                Write-Host "$($OperationErrorLog)";
            }
        }
        
        try{
            if ($LogToScreen) {
                Write-Host "$($OperationLog)";
            }
        }
        catch {
            $OperationErrorLog = "$OperationDateTime : Error : $($Error[0].exception.GetBaseException().Message) while processing $($OperationLog) To Screen";
            
            if ($LogToFile) {
                "$($OperationErrorLog)" | Add-Content $LogFilePath -Encoding UTF8;
            }
    
            if ($LogToScreen) {
                Write-Host "$($OperationErrorLog)";
            }
        }
    }
    catch {
        $OperationErrorLog = "$OperationDateTime : Error : $($Error[0].exception.GetBaseException().Message) while processing $($OperationLog)";
        
        if ($LogToFile) {
            "$($OperationErrorLog)" | Add-Content $LogFilePath -Encoding UTF8;
        }

        if ($LogToScreen) {
            Write-Host "$($OperationErrorLog)";
        }
    }
}
