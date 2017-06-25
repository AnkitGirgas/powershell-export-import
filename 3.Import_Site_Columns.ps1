 Param(
 [Parameter(Mandatory=$true)]
 [string]$SiteUrl,
 [Parameter(Mandatory=$false)]
 #Enter the name of xml file that has exported columns
 [string]$XMLTermsFileName = "ExportedSiteColumns.xml"
 )

 Set-Location $PSScriptRoot

 function LoadAndConnectToSharePoint($url)
 {
 #Make sure you have these dlls. The path can differ.
  Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
  Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
  
  ##Using PnP library
  Connect-SPOnline -Url $SiteUrl #-CurrentCredentials
  $spContext =  Get-SPOContext
  return $spContext
}

$Context = LoadAndConnectToSharePoint  $SiteUrl


$xmlFilePath = (get-location).ToString() + "\$XMLTermsFileName"

 #Get XML file exported
[xml]$fieldsXML = Get-Content($xmlFilePath)

   $fieldsXML.Fields.Field | ForEach-Object {
   $fieldtx = Get-SPOField  -Identity $_.ID -ErrorAction SilentlyContinue
   if($fieldtx -eq $null)
    {
     $fieldName = $_.Name   
  ##remove Version attribute from XML as throwing message "The object has been updated by another user since it was last fetched"
     $_.RemoveAttribute("Version")
      if($_.Type -eq 'TaxonomyFieldTypeMulti' -or $_.Type -eq 'TaxonomyFieldType')
      {
         $fldID = $_.ID
         $fldGrp = $_.Group
         $fdlDispName = $_.DisplayName
         $fldIntName = $_.Name
         $fldIsReq = $_.Required
         $termSetIdEle= $_.Customization.ArrayOfProperty.Property|?{$_.Name -eq "TermSetId"}         
         $termId= $termSetIdEle.Value.InnerText; 

         $termStoreIdEle= $_.Customization.ArrayOfProperty.Property|?{$_.Name -eq "SspId"}
         
         $ChildNodes = $_.ChildNodes;
         foreach($childNode in $ChildNodes) {$childNode.ParentNode.RemoveChild($childNode)}
      }

      if($_.Type -ne 'TaxonomyFieldTypeMulti' -and $_.Type -ne 'TaxonomyFieldType')
      {
         Add-SPOFieldFromXml -FieldXml $_.OuterXml
      }
      else{
        if( $fldIsReq)
        {
          Add-PnPTaxonomyField -Required -Id $fldID -Group $fldGrp -DisplayName $fdlDispName -InternalName  $fldIntName -TaxonomyItemId $termId
         }
         else{
            Add-PnPTaxonomyField -Id $fldID -Group $fldGrp -DisplayName $fdlDispName -InternalName  $fldIntName -TaxonomyItemId $termId
         }
      }

     
        
    }
  }