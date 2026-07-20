<# 
.\powershell\msstore.ps1
.\powershell\msstore.ps1 "info"
.\powershell\msstore.ps1 "init"
.\powershell\msstore.ps1 "publishflight" -AppName "YugenMotoGP"
.\powershell\msstore.ps1 "publishdraft" -AppName "YugenMotoGP"
.\powershell\msstore.ps1 "publishrollout" -AppName "YugenMotoGP"
.\powershell\msstore.ps1 "getsubmission" -AppName "YugenMotoGP"
.\powershell\msstore.ps1 "updatesubmission" -AppName "YugenMotoGP"
.\powershell\msstore.ps1 "updatemetadata" -AppName "YugenMotoGP"
.\powershell\msstore.ps1 "build" -AppName "YugenMotoGP"
#>

param (
    [string]$Arg,
    [string]$AppName
)

Write-Host "Arg: ${Arg}"

. .\powershell\data.ps1 -AppName "${AppName}"

${Entra} | Format-Table
${PartnerCenter} | Format-Table
${App} | Format-Table

$tenantId = ${Entra}.TenantId
$storeAppClientId = ${Entra}.StoreAppClientId
$storeAppClientSecret = ${Entra}.StoreAppClientSecret
$sellerId = ${PartnerCenter}.SellerId

Write-Host "tenantId: ${tenantId}"
Write-Host "storeAppClientId: ${storeAppClientId}"
Write-Host "storeAppClientSecret: ${storeAppClientSecret}"
Write-Host "sellerId: ${sellerId}"

$projectName = ${App}.ProjectName
$solutionDir = ${App}.SolutionDir
$solutionFile = ${App}.SolutionFile
$solutionPath = "${solutionDir}\${solutionFile}"
$projectDir = "${solutionDir}\${projectName}"
$artifactDir = "${projectDir}\AppPackages"
$productId = ${App}.ProductId
$flightId = ${App}.FlightId

Write-Host "projectName: ${projectName}"
Write-Host "solutionDir: ${solutionDir}"
Write-Host "solutionFile: ${solutionFile}"
Write-Host "solutionPath: ${solutionPath}"
Write-Host "projectDir: ${projectDir}"
Write-Host "artifactDir: ${artifactDir}"
Write-Host "productId: ${productId}"
Write-Host "flightId: ${flightId}"

$dataDir = "./.secrets"
$metadataFile = "metadata.json"
$metadataPath = "${dataDir}/${metadataFile}"
$packageFile = "package.json"
$packagePath = "${dataDir}/${packageFile}"

Write-Host "dataDir: ${dataDir}"
Write-Host "metadataFile: ${metadataFile}"
Write-Host "metadataPath: ${metadataPath}"
Write-Host "packageFile: ${packageFile}"
Write-Host "packagePath: ${packagePath}"

switch ($Arg) {     
    {
        ("info" -eq $_)
    } {
        Write-Host "START $_..."

        msstore info --verbose

        Write-Host "...$_ END"
    }
    {
        ("init" -eq $_)
    } {
        Write-Host "START $_..."

        msstore reconfigure `
            --tenantId "${tenantId}" `
            --sellerId "${sellerId}" `
            --clientId "${storeAppClientId}" `
            --clientSecret "${storeAppClientSecret}" `
            --verbose

        Write-Host "...$_ END"
    }
    {
        ("publishflight" -eq $_)
    } {
        Write-Host "START $_..."

        $msixupload = Get-ChildItem -Path ${artifactDir} -Filter *.msixupload | Select-Object -First 1
        Write-Host "msixupload: ${msixupload}"

        msstore publish "${msixupload}" `
        --appId "${productId}" `
        --flightId "${flightId}" `
        --verbose

        Write-Host "...$_ END"
    }
    {
        ("publishdraft" -eq $_)
    } {
        Write-Host "START $_..."

        $msixupload = Get-ChildItem -Path ${artifactDir} -Filter *.msixupload | Select-Object -First 1
        Write-Host "msixupload: ${msixupload}"

        msstore publish "${msixupload}" `
            --appId "${productId}" `
            --noCommit `
            --verbose

        Write-Host "...$_ END"
    }
    {
        ("publishrollout" -eq $_)
    } {
        Write-Host "START $_..."

        $msixupload = Get-ChildItem -Path ${artifactDir} -Filter *.msixupload | Select-Object -First 1
        Write-Host "msixupload: ${msixupload}"

        msstore publish "${msixupload}" `
            --appId "${productId}" `
            --packageRolloutPercentage 0 `
            --verbose

        Write-Host "...$_ END"
    }
    {
        ("getsubmission" -eq $_)
    } {
        Write-Host "START $_..."

        msstore submission get ${productId} --verbose | Out-File -Encoding utf8 ${packagePath}

        Write-Host "...$_ END"
    } 
    {
        ("updatesubmission" -eq $_)
    } {
        Write-Host "START $_..."

        $packageJson = Get-Content -Raw ${packagePath}

        $package = $packageJson | ConvertFrom-Json -Depth 10
        
        $package.'Listings'.'en-us'.'BaseListing'.'ReleaseNotes' = "Bug fixes and improvements"
        Write-Host $package.'Listings'.'en-us'.'BaseListing'.'ReleaseNotes'

        $packageJson = $package | ConvertTo-Json -Depth 10
        Write-Host $packageJson

        $packageJson | Out-File -Encoding utf8 ${packagePath}

        msstore submission update ${productId} ${packageJson} --verbose

        Write-Host "...$_ END"
    } 
    {
        ("updatemetadata" -eq $_)
    } {
        Write-Host "START $_..."

        $metadata = @{
            'Listings' = @{
                'en-us' = @{
                    'BaseListing' = @{
                        'ReleaseNotes' = 'My ReleaseNotes'
                    }
                }
            }

        }

        $metadataJson = $metadata | ConvertTo-Json -Depth 10
        Write-Host $metadataJson
        $metadataJson | Out-File -Encoding utf8 ${metadataPath}

        msstore submission updateMetadata ${productId} ${metadataJson} --verbose

        Write-Host "...$_ END"
    } 
    {
        ("build" -eq $_)
    } {
        Write-Host "START $_..."

        $projectVersion = "1.0.2.0"
        $projectConfiguration = "Release"
        $projectPlatform = "x64"
        $projectAppxBundle = "Always"
        $projectAppxBundlePlatforms = "x64|ARM64"
        $projectAppxPackageBuildMode = "StoreUpload"

        Write-Host "Updating Version..."
        [xml]$manifest = get-content "${projectDir}\Package.appxmanifest"
        $manifest.Package.Identity.Version = "${projectVersion}"
        $manifest.save("${projectDir}/Package.appxmanifest")
        Write-Host "...Version Updated"

        Write-Host "Building Package..."
        dotnet publish "${solutionPath}" `
            /p:AppxBundle="${projectAppxBundle}" `
            /p:AppxBundlePlatforms="${projectAppxBundlePlatforms}" `
            /p:AppxPackageDir="${artifactDir}" `
            /p:AppxPackageSigningEnabled="false" `
            /p:BuildAppxUploadPackageForUap="true" `
            /p:Configuration="${projectConfiguration}" `
            /p:GenerateAppxPackageOnBuild="true" `
            /p:Platform="${projectPlatform}" `
            /p:PublishAppxPackage="true" `
            /p:UapAppxPackageBuildMode="${projectAppxPackageBuildMode}"
        Write-Host "...Package Build"

        Write-Host "...$_ END"
    }
    default {
        Write-Host "START $_..."

        Write-Host "Hello World"

        Write-Host "...$_ END"
    }
}

