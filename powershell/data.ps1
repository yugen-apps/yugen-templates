param (    
    [Parameter(Mandatory)]
    [string]$AppName
)
Write-Host "AppName: ${AppName}"

$Data = Get-Content -Path "./.secrets/data.json" | ConvertFrom-JSON

$Entra = ${data}.Entra
$PartnerCenter = ${data}.PartnerCenter
$Apps = ${data}.Apps

$App = ${Apps}.${AppName}

# ${Entra} | Format-Table
# ${PartnerCenter} | Format-Table
# ${App} | Format-Table