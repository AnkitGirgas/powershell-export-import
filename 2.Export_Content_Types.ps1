
 write-host $PSScriptRoot
 
 function GetSiteContentTypes {
     Param(
     [Parameter(Mandatory=$true)]
     [string]$SiteUrl,
     [Parameter(Mandatory=$false)]
     [string]$XMLCTFileName = "ExportedContentTypes.xml",
     [string]$GroupToExport = "<Your Content type group>"
     )
 
     Set-Location $PSScriptRoot

     function LoadAndConnectToSharePoint($url)
     {

     
      Connect-PnPOnline -Url $SiteUrl   
      $spContext =  Get-SPOContext
      return $spContext
    }

    $Context = LoadAndConnectToSharePoint  $SiteUrl

    $SPOContentTypes = Get-PnPContentType

    $PathToExportXMLSiteContentTypes = $PSScriptRoot
    $xmlFilePath = "$PathToExportXMLSiteContentTypes\$XMLCTFileName"

     #Create Export Files
     New-Item $xmlFilePath -type file -force

     #Export Site Columns to XML file
     Add-Content $xmlFilePath "<?xml version=`"1.0`" encoding=`"utf-8`"?>"
     Add-Content $xmlFilePath "`n<ContentTypes>"
 
     
     $SPOContentTypes | ForEach-Object {
        #Type the content types group name below in if statement
        if ($_.Name -eq $GroupToExport) {
            Add-Content $xmlFilePath $_.SchemaXml
        }
      }
     Add-Content $xmlFilePath "</ContentTypes>"
}

GetSiteContentTypes -SiteUrl "https://<your-tenant>.sharepoint.com" #enter site collection url here to export content types from