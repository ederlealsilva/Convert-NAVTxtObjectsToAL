<# ============================================================
 -- Author:       Éder Leal da Silva
 -- Create Date:  17/12/2018
 -- Description:  Convert NAV C/AL objetos To AL

 **************************
 ** Change History
 **************************
 ** PR  Date	     Author     Description	
 ** --  ----------  ----------  -------------------------------
 ** 01   17/12/2018  ENS        Create script
 ** 02   28/12/2018  ENS        Update script
============================================================ #>
Import-Module 'C:\Users\eder.silva\Documents\GitHub\Convert-NAVTxtObjectsToAL\Convert-NAVTxtObjectsToAL\Convert-NAVTxtObjectsToAL.psm1'

$DbServer = "DatabaseServer\DatabaseInstance"
$DbName = "DatabaseName"
$Dir = "C:\Temp\ALProject"
$ObjFilters = "Name=*"

$DbServer = "ARQUI02-ENS\DBSRV2016"
$DbName = "DemoDatabaseBC130"
$Dir = "C:\Temp\ALProject_05"
$ObjFilters = "Name=*Company*"


<#-- FileStructure None --#>
<#--
-AL
--*.al|*.*
--#>
Convert-NavObjectsToNewSyntax -DbName $DbName -DbServer $DbServer -FileStructure None -NavVersion BC130 -WorkDirectory $Dir -ObjectsFilter $ObjFilters -UpdateReportExtension

<#-- FileStructure Numbered  --#>
<#--
-project
--app
----01_table
----02_page
--#>
Convert-NavObjectsToNewSyntax -DbName $DbName -DbServer $DbServer -FileStructure Numbered -NavVersion BC130 -WorkDirectory $Dir -ObjectsFilter $ObjFilters -UpdateReportExtension

<#-- FileStructure NameOnly  --#>
<#-- 
-project
--app
----page
----table
--#>
Convert-NavObjectsToNewSyntax -DbName $DbName -DbServer $DbServer -FileStructure NameOnly -NavVersion BC130 -WorkDirectory $Dir -ObjectsFilter $ObjFilters -UpdateReportExtension

<#-- CreateAllStructure  --#>
<#-- 
-project
--app
----codeunit
----table
----...
----...
--#>
Convert-NavObjectsToNewSyntax -DbName $DbName -DbServer $DbServer -FileStructure NameOnly -NavVersion BC130 -WorkDirectory $Dir -CreateAllStructure -ObjectsFilter $ObjFilters -UpdateReportExtension
