<# ============================================================
 -- Author:       Éder Leal da Silva
 -- Create Date:  17/12/2018
 -- Description:  Convert NAV C/AL objetos To AL

 **************************
 ** Change History
 **************************
 ** PR  Date	     Author     Description	
 ** --  ----------  ----------  -------------------------------
 ** 01   17/12/2018  ENS        Create funciton
============================================================ #>
Import-Module 'Convert-NAVTxtObjectsToAL.psm1'

$DbServer = "DatabaseServer\DatabaseInstance"
$DbName = "DatabaseName"
$Dir = "C:\Temp\ALProject"
$ObjFilters = "Name=*"

Convert-NavObjectsToNewSyntax -DbName $DbServer -DbServer $DbName -NavVersion BC130 -WorkDirectory $Dir -ObjectsFilter $ObjFilters -UpdateFileStructure $true -UpdateReportExtension $true
