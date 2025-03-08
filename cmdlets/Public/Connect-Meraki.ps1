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