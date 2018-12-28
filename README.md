# Convert-NAVTxtObjectsToAL
[Convert-NAVTxtObjectsToAL](https://github.com/ederlealsilva/Convert-NAVTxtObjectsToAL) uses a powershell script to help you convert Microsoft Dynamics NAV Txt Objects To AL Syntax

## Getting Started
The [Convert-NAVTxtObjectsToAL](https://github.com/ederlealsilva/Convert-NAVTxtObjectsToAL) allows you with a unique execution to perform the following tasks.
* Export the objects from a database
* Split all the objects
* Convert the txt objects to AL
* Convert the reports RDLC to RDL
* Create the AL project file structure

See Usage for additional help.

---

### Prerequisites
* Powershell >= 2.0
* Microsoft Dynamics NAV >= 2018
* Txt2Al.exe

This script uses the NAV binary Txt2Al locatated at RoleTailored folder for NAV2018 or BC130
 - C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Txt2Al.exe
 - C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\130\RoleTailored Client\Txt2Al.exe

---

## Configuration
Set the full path of the `Convert-NAVTxtObjectsToAL.psm1` file.
```powershell
Import-Module 'C:\Temp\Convert-NAVTxtObjectsToAL.psm1'
```

Edit the $variables in the file `Execute.ps1`.
```powershell
$DbServer = "DatabaseServer\DatabaseInstance"
$DbName = "DatabaseName"
$Dir = "C:\Temp\ALProject"
$ObjFilters = "Name=*"
```

---

## Parameters
* Mandatory:
```powershell
-DbName         # Database Name
-DbServer       # Database Server (include instance if exist)
-FileStructure  # Numbered, NameOnly, None
-NavVersion     # NAV2018, BC130
-WorkDirectory  # File Directory (directory where the objects will be created)
```

* Others Paramenters
```powershell
-CreateAllStructure     # Create all folder structure even if not all object type were created
-ObjectsFilter          # Define an object filter ('Version List=*NAVPT*')
-UpdateReportExtension  # Update report extension (RDLC to RDL)
```

---

## Usage
Run `Execute.ps1` as admin.

```powershell
Import-Module 'C:\Temp\Convert-NAVTxtObjectsToAL.psm1'

$DbServer = "DatabaseServer\DatabaseInstance"
$DbName = "DatabaseName"
$Dir = "C:\Temp\ALProject"
$ObjFilters = "Name=*"

Convert-NavObjectsToNewSyntax -DbName $DbName -DbServer $DbServer -FileStructure NameOnly -NavVersion BC130 -WorkDirectory $Dir -CreateAllStructure -ObjectsFilter $ObjFilters -UpdateReportExtension
```

---

## Contribution

Please read [CONTRIBUTING.md](https://github.com/ederlealsilva/Convert-NAVTxtObjectsToAL) for details on our code of conduct, and the process for submitting pull requests to us.

---

## Authors

* [**Éder Leal da Silva**](https://github.com/ederlealsilva)

See also the list of [contributors](https://github.com/ederlealsilva/Convert-NAVTxtObjectsToAL/contributors) who participated in this project.

---

## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](https://github.com/ederlealsilva/Convert-NAVTxtObjectsToAL/blob/master/LICENSE)**
- Copyright 2018 © <a href="https://github.com/ederlealsilva/" target="_blank">Éder Leal da Silva</a>.
