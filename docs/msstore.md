# Resources

https://learn.microsoft.com/en-us/windows/apps/publish/msstore-dev-cli/commands
https://github.com/microsoft/msstore-cli
https://learn.microsoft.com/en-us/windows/apps/publish/msstore-dev-cli/github-actions
https://github.com/microsoft/store-submission
https://learn.microsoft.com/en-us/windows/uwp/monetize/update-an-app-submission

# Prerequisites:

winget install Microsoft.DotNet.DesktopRuntime.9
winget install "Microsoft Store Developer CLI"

# Commands

## Info

Print existing configuration.

```powershell
msstore info --verbose
```

## Reconfigure

```powershell
msstore reconfigure `
--tenantId "${tenant_id}" `
--sellerId "${seller_id}" `
--clientId "${store_app_client_id}" `
--clientSecret "${store_app_client_secret}" `
--verbose
```

## Apps

| Name | Command                               | Description                                 |
| ---- | ------------------------------------- | ------------------------------------------- |
| List | msstore apps list --verbose           | Lists all the applications in your account. |
| Get  | msstore apps get $productId --verbose | Gets the details of a specific application. |

## Submission

| Name             | Command                                                 | Description                                                  | Options              |
| ---------------- | ------------------------------------------------------- | ------------------------------------------------------------ | -------------------- |
| status           | msstore submission status $productId                    | Gets the status of a submission.                             |                      |
| get              | msstore submission get $productId                       | Gets the metadata and package info of a specific submission. |                      |
| getListingAssets | msstore submission getListingAssets $productId          | Gets the listing assets of a specific submission.            |                      |
| updateMetadata   | msstore submission updateMetadata $productId {metadata} | Updates the metadata of a specific submission.               | --skipInitialPolling |
| update           | msstore submission update $productId {package}          | Updates the package of a specific submission.                | --skipInitialPolling |
| poll             | msstore submission poll $productId                      | Polls the status of a submission.                            |                      |
| publish          | msstore submission publish $productId                   | Publishes a specific submission.                             |                      |
| delete           | msstore submission delete $productId                    | Deletes a specific submission.                               | --no-confirm         |

### Update Metadata

1. Retrieve the current submission package JSON

   ```powershell
   msstore submission get $productId | Out-File -Encoding utf8 ./.data/package.json
   ```

2. Edit package.json to reflect your changes

3. Pass the updated JSON to submission update
   ```powershell
    $updatedPackage = Get-Content -Raw ./.data/package.json
    msstore submission update $productId $updatedPackage
   ```

### Update

1. Get the current in-progress submission:

   ```powershell
   msstore submission get $productId | Out-File -Encoding utf8 ./.data/package.json
   ```

2. Update the package URL and remove the old Package Id:

   ```powershell
   $myJson.Packages[0].PackageUrl = $UpdateUrl
   $myJson.PSObject.Properties.Remove("PackageId")
   ```

3. Submit the update:

   ```powershell
   msstore submission update $productId $myJson
   ```

   ```powershell
   msstore submission get $productId | Out-File -Encoding utf8 ./.data/package.json

   $package = Get-Content -Path "./.data/package.json" | ConvertFrom-JSON
   # update filename
   # delete id
   # delete version
   $packageJson = $package | ConvertTo-Json -Depth 10
   $packageJson | Out-File -Encoding utf8 ./.data/package.json

   $packageJson = Get-Content -Raw ./.data/package.json
   msstore submission update $productId $packageJson
   ```

## Flights

| Name                        | Command                                                                     | Description                                                                                            | Options              |
| --------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | -------------------- |
| list                        | msstore flights list $productId                                             | Retrieves all the Flights for the specified Application.                                               |                      |
| get                         | msstore flights get $productId $flightId                                    | Retrieves a flight for the specified Application and flight.                                           |                      |
| delete                      | msstore flights delete $productId $flightId                                 | Deletes a flight for the specified Application and flight.                                             |                      |
| create                      | msstore flights create $productId $friendlyName --group-ids $group-ids      | Creates a flight for the specified Application and flight.                                             |                      |
| submission                  | -                                                                           | Execute flight submissions related tasks.                                                              |                      |
| submission get              | msstore flights submission get $productId $flightId                         | Retrieves the existing package flight submission, either the existing draft or the last published one. |                      |
| submission delete           | msstore flights submission delete $productId $flightId                      | Deletes the pending package flight submission from the store.                                          |                      |
| submission update           | msstore flights submission update $productId $flightId {product}            | Updates the existing flight draft with the provided JSON.                                              | --skipInitialPolling |
| submission publish          | msstore flights submission publish $productId $flightId                     | Starts the flight submission process for the existing Draft.                                           |                      |
| submission poll             | msstore flights submission poll $productId $flightId                        | Polls until the existing flight submission is PUBLISHED or FAILED.                                     |                      |
| submission status           | msstore flights submission status $productId $flightId                      | Retrieves the current status of the store flight submission.                                           |                      |
| submission rollout          | -                                                                           | Execute flight rollout related operations.                                                             |                      |
| submission rollout get      | msstore flights submission rollout get $productId $flightId                 | Retrieves the flight rollout status of a submission.                                                   | --submissionId       |
| submission rollout update   | msstore flights submission rollout update $productId $flightId <percentage> | Update the flight rollout percentage of a submission.                                                  | --submissionId       |
| submission rollout halt     | msstore flights submission rollout halt $productId $flightId                | Halts the flight rollout of a submission.                                                              | --submissionId       |
| submission rollout finalize | msstore flights submission rollout finalize $productId $flightId            | Finalizes the flight rollout of a submission.                                                          | --submissionId       |

### Update

1. Get the current progress submission:

   ```powershell
   msstore flights submission get $productId $flightId | Out-File -Encoding utf8 ./.data/flight.json
   ```

2. In the response data, locate the packageRollout resource, set the isPackageRollout field to true,
   and set the packageRolloutPercentage field to the percentage of your app's customers who should get the updated packages.

   ```powershell
   $flight = Get-Content -Path "./.data/flight.json" | ConvertFrom-JSON
   $flight.PackageDeliveryOptions.PackageRollout.IsPackageRollout = $True
   $flight.PackageDeliveryOptions.PackageRollout.PackageRolloutPercentage = 5
   $flightJson = $flight | ConvertTo-Json -Depth 10
   $flightJson | Out-File -Encoding utf8 ./.data/flight.json
   ```

3. Submit the update:
   ```powershell
   msstore flights submission update $productId $flightId $flightJson
   ```

## Publish

| Name    | Command                                 | Description                                        |
| ------- | --------------------------------------- | -------------------------------------------------- |
| Publish | msstore publish "C:\path\to\winui3_app" | Publishes your Application to the Microsoft Store. |

### Options

| Option                           | Description                                                                                                       |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| -i, --inputFile                  | The path to the '.msix' or '.msixupload' file to be used for the publishing command. If not provided, the cli     | will try to find the best candidate based on the 'pathOrUrl' argument. |
| -id, --appId                     | Specifies the Application Id. Only needed if the project has not been initialized before with the 'init' command. |
| -nc, --noCommit                  | Disables committing the submission, keeping it in draft state.                                                    |
| -f, --flightId                   | Specifies the Flight Id where the package will be published.                                                      |
| -prp, --packageRolloutPercentage | Specifies the rollout percentage of the package. The value must be between 0 and 100.                             |                                                                        |
