<#
  .DESCRIPTION
  This cmdlet is designed to get system managed devices in a network
  .PARAMETER networkId
  The network that we want to get the devices from
  .PARAMETER fields
  Additional fields that we want to return
#>
function Get-MerakiSystemsManagerDevice{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$networkId,
    [Parameter()][ValidateNotNullOrEmpty()][string]$fields
  )
  # Confirm we have a valid meraki header
  if(!$global:merakiHeader){
    throw "Please Call Connect-Meraki before calling this cmdlet"
  }
  # Generate URI for call
  $uri = "$($global:merakiApiURI)/networks/$($networkId)/sm/devices"    
  if($fields){
    $uri = "$($uri)?fields[]=$($fields)"
  }
  # Execute API Call
  $devices = Invoke-RestMethod -Method Get -Uri $uri -Headers $global:merakiHeader -StatusCodeVariable statusCode -FollowRelLink
  # Filter for productTypes
  $deviceList = [System.Collections.Generic.List[PSCustomObject]]@()
  foreach($device in $devices){
    foreach($item in $device){
      $deviceList.Add($item) | Out-Null
    }
  }
  return $deviceList
}