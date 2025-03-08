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