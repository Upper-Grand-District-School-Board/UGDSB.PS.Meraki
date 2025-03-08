<#
  .DESCRIPTION
  This cmdlet is designed to convert get the meraki networks
  .PARAMETER type
  The type of network that we should filter to
#>
function Get-MerakiNetwork{
  [CmdletBinding()]
  param(
    [Parameter()][ValidateSet("wireless","systemsmanager")][string]$type
  )
  # Confirm we have a valid meraki header
  if(!$global:merakiHeader){
    throw "Please Call Connect-Meraki before calling this cmdlet"
  }
  # Generate URI for call
  $uri = "$($global:merakiApiURI)/organizations/$($global:merakiOrgId)/networks"
  # Execute API Call
  $networks = Invoke-RestMethod -Method Get -Uri $uri -Headers $global:merakiHeader -StatusCodeVariable statusCode -FollowRelLink
  # Filter for productTypes
  $networkList = [System.Collections.Generic.List[PSCustomObject]]@()  
  foreach($network in $networks){
    foreach($item in $network){
      if($type -and $type -notin $item.productTypes){continue}
      $networkList.Add($item) | Out-Null
    }
  }
  return $networkList
}