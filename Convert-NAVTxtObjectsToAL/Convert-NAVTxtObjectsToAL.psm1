<# ============================================================
 -- Author:       Éder Leal da Silva
 -- Create Date:  14/12/2018
 -- Description:  Convert NAV C/AL objetos To AL

 **************************
 ** Change History
 **************************
 ** PR  Date	     Author     Description	
 ** --  ----------  ----------  -------------------------------
 ** 01   14/12/2018  ENS        Create funciton
 ** 02   17/12/2018  ENS        Update funciton
============================================================ #>

function Convert-NavObjectsToNewSyntax () {
    param(
        [parameter(Mandatory=$true)]
        [ValidateSet("NAV2018","BC130")]
        [string]$NavVersion,

        [parameter(Mandatory=$true)]
        [string]$DbServer,

        [parameter(Mandatory=$true)]
        [string]$DbName,
        
        [parameter(Mandatory=$false)]
        [string]$ObjectsFilter,

        [parameter(Mandatory=$true)]
        [string]$WorkDirectory,

        [parameter(Mandatory=$false)]
        [bool]$UpdateReportExtension,

        [parameter(Mandatory=$false)]
        [bool]$UpdateFileStructure
    )
    $startTime = Get-Date

    $ProgressActivity = "Converting NAV Objects To New Syntax"
    $ProgTotalTasks = 8
    $ProgressDescr = "Progress:"

    $ProgCurrTasks = 1
    $ProgressDescr = "Progress: Verifying folders directories"
    Write-Progress -Activity $ProgressActivity -Status $ProgressDescr -PercentComplete ($ProgCurrTasks/$ProgTotalTasks*100)


    $TxtObjDirectory = $WorkDirectory + "\TXT"
    VerifyDirectory -DirPath $TxtObjDirectory

    $TxtObjectCALDir = $WorkDirectory + "\CAL"
    VerifyDirectory -DirPath $TxtObjectCALDir

    $TxtNewSyntaxDir = $WorkDirectory + "\AL"
    VerifyDirectory -DirPath $TxtNewSyntaxDir

    $TxtObjFullName = $TxtObjDirectory + "\" + $DbName + "_Objects.txt";
    $Txt2AlCmd = ""

    # Load CmdLet
    $ProgCurrTasks = 2
    $ProgressDescr = "Progress: Loading powershell cmdLets"
    Write-Progress -Activity $ProgressActivity -Status $ProgressDescr -PercentComplete ($ProgCurrTasks/$ProgTotalTasks*100)

    switch ($NavVersion) {
        NAV2018 {
            $Txt2AlCmd = "C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\txt2al.exe"
            LoadModules -NavVersion NAV2018
        }
        BC130 {
            $Txt2AlCmd = "C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\130\RoleTailored Client\txt2al.exe"
            LoadModules -NavVersion BC130
        }
    }    

    # Export Txt Objects
    $ProgCurrTasks = 3
    $ProgressDescr = "Progress: Exporting database objects"
    Write-Progress -Activity $ProgressActivity -Status $ProgressDescr -PercentComplete ($ProgCurrTasks/$ProgTotalTasks*100)

    ExportObjects -TxtObjectName $TxtObjFullName -DbServer $DbServer -DbName $DbName
    

    # Split Txt Objects
    $ProgCurrTasks = 4
    $ProgressDescr = "Progress: Spliting txt objects"
    Write-Progress -Activity $ProgressActivity -Status $ProgressDescr -PercentComplete ($ProgCurrTasks/$ProgTotalTasks*100)

    $scr = $TxtObjDirectory + "\*.txt"
    SplitTxtObjects -Source $scr -Destination $TxtObjectCALDir
    

    # Convert Txt To AL
    $ProgCurrTasks = 5
    $ProgressDescr = "Progress: Converting txt objects to al"
    Write-Progress -Activity $ProgressActivity -Status $ProgressDescr -PercentComplete ($ProgCurrTasks/$ProgTotalTasks*100)

    ConvertTxtObjects -Command $Txt2AlCmd -SourceDirectory $TxtObjectCALDir -TargetDirectory $TxtNewSyntaxDir -ErrorAction Continue


    #Update Reports Extension
    $ProgCurrTasks = 6
    $ProgressDescr = "Progress: Updating report extentions"
    Write-Progress -Activity $ProgressActivity -Status $ProgressDescr -PercentComplete ($ProgCurrTasks/$ProgTotalTasks*100)

    if($UpdateReportExtension) {
        UpdateReportsExtension -DirPath $TxtNewSyntaxDir
    }

    #Update File Structures
    $ProgCurrTasks = 7
    $ProgressDescr = "Progress: Updating files structures"
    Write-Progress -Activity $ProgressActivity -Status $ProgressDescr -PercentComplete ($ProgCurrTasks/$ProgTotalTasks*100)

    if($UpdateReportExtension) {
        UpdateFileStructure -DirPath $TxtNewSyntaxDir
    }


    #Complete
    $ProgCurrTasks = 8
    $ProgressDescr = "Progress: Converting process completed"
    Write-Progress -Activity $ProgressActivity -Status $ProgressDescr -PercentComplete ($ProgCurrTasks/$ProgTotalTasks*100)

    $endTime = Get-Date
    $dur = $endTime - $startTime

    Write-Host -ForegroundColor Green "Process completed!"
    Write-Host -ForegroundColor Gray "Duration:" $dur

}


<#-- Load Dynamics NAV/BC ComdLets --#>
function LoadModules () {
    param(
        [parameter(Mandatory=$true)]
        [ValidateSet("NAV2018","BC130")]
        [string]$NavVersion
    )
    switch ($NavVersion) {
        NAV2018 {
            # Import the module for the Export-NAVApplicationObject cmdLet
            Import-Module 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Ide.psm1' -Force -WarningAction SilentlyContinue | Out-Null

            # Import the module for the Split-NAVApplicationObjectFile cmdLet
            Import-Module 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1' -Force -WarningAction SilentlyContinue | Out-Null
            
            Write-Host -ForegroundColor Yellow ">> NAV 2018 Modules Loaded"
        }

        BC130 {
            # Import the module for the Export-NAVApplicationObject cmdLet
            Import-Module 'C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\130\RoleTailored Client\Microsoft.Dynamics.Nav.Ide.psm1' -Force -WarningAction SilentlyContinue | Out-Null

            # Import the module for the Split-NAVApplicationObjectFile cmdLet
            Import-Module 'C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\130\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1' -Force -WarningAction SilentlyContinue | Out-Null
            
            Write-Host -ForegroundColor Yellow ">> BC 130 Modules Loaded"
        }

    }
}



<#-- Export objects from the database --#>
function ExportObjects () {
    param(
        [parameter(Mandatory=$true)]
        [string]$TxtObjectName,

        [parameter(Mandatory=$true)]
        [string]$DbServer,

        [parameter(Mandatory=$true)]
        [string]$DbName,

        [parameter(Mandatory=$false)]
        [string]$ObjectsFilter
    )

    if(!$ObjectsFilter){
        Export-NAVApplicationObject -DatabaseServer $DbServer -DatabaseName $DbName -Path $TxtObjectName -ExportToNewSyntax -ExportTxtSkipUnlicensed -Verbose
    } else {
        Export-NAVApplicationObject -DatabaseServer $DbServer -DatabaseName $DbName -Filter $ObjectsFilter -Path $TxtObjectName -ExportToNewSyntax -ExportTxtSkipUnlicensed -Verbose
    }

    Write-Host -ForegroundColor Yellow ">> Exported objects:" $TxtObjectName
}


<#-- Split the txt file into separate txt for each object --#>
function SplitTxtObjects () {
    param(
        [parameter(Mandatory=$true)]
        [string]$Source,

        [parameter(Mandatory=$true)]
        [string]$Destination
    )

    Split-NAVApplicationObjectFile -Source $Source -Destination $Destination -Verbose

    Write-Host -ForegroundColor Yellow ">> Splited objects:" $Destination
}

<#-- Convert txt objects to al --#>
function ConvertTxtObjects () {
    param(
        [parameter(Mandatory=$true)]
        [string]$Command,

        [parameter(Mandatory=$true)]
        [string]$SourceDirectory,

        [parameter(Mandatory=$true)]
        [string]$TargetDirectory
    )

    $Cmd = $Command
    & $Cmd --source $SourceDirectory --target $TargetDirectory

    Write-Host -ForegroundColor Yellow ">> objects converted to al:" $TargetDirectory
}

<#-- Verify folder directory and create if does not exists --#>
function VerifyDirectory() {
    param(
        [parameter(Mandatory=$true)]
        [string]$DirPath
    )

    if(!(Test-Path -Path $DirPath )){
        New-Item -ItemType directory -Path $DirPath
        Write-Host -ForegroundColor Yellow ">> New folder created:" $DirPath
    }
}

<#-- Update rdlc file extension to rdl --#>
function UpdateReportsExtension() {
    param(
        [parameter(Mandatory=$true)]
        [string]$DirPath
    )

    $i = 0
    Get-ChildItem -Path $DirPath -Recurse | where {$_.extension -eq ".rdlc"} | % {
        $rdlfile = $_.BaseName + ".rdl"
        Rename-Item -LiteralPath $_.Fullname $rdlfile
        $i ++;
    }

    Write-Host -ForegroundColor Yellow ">> Report extension changed:" $i
}

<#-- Update file structures --#>
function UpdateFileStructure() {
    param(
        [parameter(Mandatory=$true)]
        [string]$DirPath
    )
    $projDir = $DirPath+"\project"
    VerifyDirectory -DirPath $projDir
    $appDir = $projDir+"\app"
    VerifyDirectory -DirPath $appDir
    VerifyDirectory -DirPath $projDir"\images"
    VerifyDirectory -DirPath $projDir"\logo"
    VerifyDirectory -DirPath $projDir"\permissions"
    VerifyDirectory -DirPath $projDir"\rules"
    VerifyDirectory -DirPath $projDir"\tests"
    VerifyDirectory -DirPath $projDir"\translations"
    VerifyDirectory -DirPath $projDir"\webservices"

    $tableDir = $appDir+"\01_table"
    VerifyDirectory -DirPath $tableDir
    #$tblCustDir = $appDir+"\01_tableCust"
    #VerifyDirectory -DirPath $tblCustDir
    $tblExtDir = $appDir+"\01_tableCust"
    VerifyDirectory -DirPath $tblExtDir
    $pageDir = $appDir+"\02_page"
    VerifyDirectory -DirPath $pageDir
    #$pgCustDir = $appDir+"\02_pageCust"
    #VerifyDirectory -DirPath $pgCustDir
    $pgExtDir = $appDir+"\02_pageExt"
    VerifyDirectory -DirPath $pgExtDir
    #$profileDir = $appDir+"\02_profile"
    #VerifyDirectory -DirPath $profileDir
    $reportDir = $appDir+"\03_report"
    VerifyDirectory -DirPath $reportDir
    #$repCustDir = $appDir+"\03_reportCust"
    #VerifyDirectory -DirPath $repCustDir
    $repExtDir = $appDir+"\03_reportExt"
    VerifyDirectory -DirPath $repExtDir
    $codeunitDir = $appDir+"\04_codeunit"
    VerifyDirectory -DirPath $codeunitDir
    $queryDir = $appDir+"\05_query"
    VerifyDirectory -DirPath $queryDir
    $xmlportDir = $appDir+"\06_xmlport"
    VerifyDirectory -DirPath $xmlportDir
    $enumDir = $appDir+"\07_enum"
    VerifyDirectory -DirPath $enumDir
    $enumExtDir = $appDir+"\07_enumExt"
    VerifyDirectory -DirPath $enumExtDir
    $ctrladdinDir = $appDir+"\08_controladdin"
    VerifyDirectory -DirPath $ctrladdinDir
    $dotnetDir = $appDir+"\99_dotnet"
    VerifyDirectory -DirPath $dotnetDir


    $i = 0
    Get-ChildItem -Path $DirPath -Recurse | where {$_.extension -eq ".al"} | % {
        # Codeunits
        if ($_.Name.StartsWith("COD")) {
            $i ++;
            Move-Item -Path $_.FullName -Destination $codeunitDir -Force
        }

        # DotNet
        if ($_.Name.StartsWith("dot")) {
            $i ++;
            Move-Item -Path $_.FullName -Destination $dotnetDir -Force
        }

        # Pages
        if ($_.Name.StartsWith("PAG")) {
            $i ++;
            Move-Item -Path $_.FullName -Destination $pageDir -Force
        }

        # Queries
        if ($_.Name.StartsWith("QUE")) {
            $i ++;
            Move-Item -Path $_.FullName -Destination $queryDir -Force
        }

        # Reports
        if ($_.Name.StartsWith("REP")) {
            $i ++;
            Move-Item -Path $_.FullName -Destination $reportDir -Force
        }

        # Tables
        if ($_.Name.StartsWith("TAB")) {
            $i ++;
            Move-Item -Path $_.FullName -Destination $tableDir -Force
        }

        # XMLports
        if ($_.Name.StartsWith("XML")) {
            $i ++;
            Move-Item -Path $_.FullName -Destination $xmlportDir -Force
        }
    }

    Get-ChildItem -Path $DirPath -Recurse | where {$_.extension -eq ".rdl" -or $_.extension -eq ".docx"} | % {
        $i ++;
        Move-Item -Path $_.FullName -Destination $reportDir -Force
    }

    Get-ChildItem -Path $DirPath -Recurse | where {$_.extension -eq ".xlf"} | % {
        $i ++;
        Move-Item -Path $_.FullName -Destination $projDir"\translations" -Force
    }

    Write-Host -ForegroundColor Yellow ">> Moved files:" $i
}