function Get-MerakiDevices{
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
  $uri = "$($global:merakiApiURI)/networks/$($networkId)/devices"    
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