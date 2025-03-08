#Region '.\Public\Connect-Meraki.ps1' 0
<#
  .DESCRIPTION
  This cmdlet is designed to convert and store header information for meraki api
  .PARAMETER credential
  The credential to connect to the API endpoints
  .PARAMETER organizationId
  Your meraki organization ID
#>
function Connect-Meraki{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][SecureString]$credential,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$organizationId,
    [Parameter()][ValidateNotNullOrEmpty()][string]$URI = "https://api.meraki.com/api/v1/"
  )
  # This sets the global variables that are used to connect to the topdesk API
  $script:merakiHeader = @{
    "X-Cisco-Meraki-API-Key" = ConvertFrom-SecureString $credential -AsPlainTex
    "Content-Type" = "application/json"
  }  
  # This sets a variable for the orgId
  $script:merakiOrgId = $organizationId
  # This sets a variable for the orgId
  $script:merakiApiURI = $URI
}
#EndRegion '.\Public\Connect-Meraki.ps1' 26
#Region '.\Public\Get-MerakiDevices.ps1' 0
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
#EndRegion '.\Public\Get-MerakiDevices.ps1' 27
#Region '.\Public\Get-MerakiNetwork.ps1' 0
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
#EndRegion '.\Public\Get-MerakiNetwork.ps1' 30
#Region '.\Public\Get-MerakiSystemsManagerDevice.ps1' 0
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
#EndRegion '.\Public\Get-MerakiSystemsManagerDevice.ps1' 35
#Region '.\Public\Move-MerakiSystemsManagerDevice.ps1' 0
<#
  .DESCRIPTION
  This cmdlet is designed to move devices from one network to another
  .PARAMETER networkId
  The network that we want to get the devices from
  .PARAMETER newNetworkId
  The network that we want to get the devices to  
  .PARAMETER ids
  If we want to move devices based on their id
  .PARAMETER serialNumbers
  If we want to move devices based on their serial number
#>
function Move-MerakiSystemsManagerDevice{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$networkId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$newNetworkId,
    [Parameter()][ValidateNotNullOrEmpty()][System.Object]$ids,
    [Parameter()][ValidateNotNullOrEmpty()][System.Object]$serialNumbers
  )
  # Confirm we have a valid meraki header
  if(!$global:merakiHeader){
    throw "Please Call Connect-Meraki before calling this cmdlet"
  }
  # Confirm we have items to move
  if(-not $ids -and -not $serialNumbers){
    throw "You need to specify at least one id or one serial number"
  }
  # Generate URI for call
  $uri = "$($global:merakiApiURI)/networks/$($networkId)/sm/devices/move"   
  # Create Body
  $body = @{
    "newNetwork" = $newNetworkId
  }
  if($ids){
    $body.Add("ids",$ids)
  }
  if($serialNumbers){
    $body.Add("serials",$serialNumbers)
  }
  # Try to move devices
  try{
    $results = Invoke-RestMethod -Method "Post" -Uri $uri -Headers $global:merakiHeader -Body ($body | ConvertTo-Json) -StatusCodeVariable statusCode
  }
  catch{
    throw "Unable to move devices. $($_.Exception.Message)"
  }
}
#EndRegion '.\Public\Move-MerakiSystemsManagerDevice.ps1' 49
