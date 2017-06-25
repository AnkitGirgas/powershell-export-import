 Param( 

 [Parameter(Mandatory=$true)] 

 [string]$SiteUrl, 

 [Parameter(Mandatory=$false)] 

 [string]$XMLTermsFileName = "ExportedSiteColumns.xml"

, [string] $GroupToExport = "MyCustom" ) 

 Set-Location $PSScriptRoot

function LoadAndConnectToSharePoint($url) {
 
	Connect-PnPOnline -Url $SiteUrl   

	$spContext =  Get-SPOContext 

	return $spContext

}


$Context = LoadAndConnectToSharePoint  


#Get all fields from site collection

$SPOfields = Get-SPOField
$PathToExportXMLSiteColumns = $PSScriptRoot

$xmlFilePath = "$PathToExportXMLSiteColumns\$XMLTermsFileName"
 #Create Export Files 

New-Item $xmlFilePath -type file -force
 #Export Site Columns to XML file 

Add-Content $xmlFilePath "<?xml version=`"1.0`" encoding=`"utf-8`"?>" 

Add-Content $xmlFilePath "`n<Fields>"  

$SPOfields | ForEach-Object {   


if ($_.Group -eq "MyCustom" )# Enter the site columns group that needs to be exported

{       

Add-Content $xmlFilePath $_.SchemaXml   

} 

} 

Add-Content $xmlFilePath "</Fields>"