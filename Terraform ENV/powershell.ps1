# PowerShell script for downloading and installing the latest Terraform (Windows, x86_64)
Function Write-Success ($msg) { Write-Host "✔️  $msg" -ForegroundColor Green }
Function Write-ErrorMsg ($msg) { Write-Host "❌ $msg" -ForegroundColor Red }
Function Write-Info ($msg) { Write-Host "ℹ️  $msg" -ForegroundColor Cyan }

Try {
    # 1. Detect latest Terraform version using the releases API
    $latestReleaseUrl = "https://api.releases.hashicorp.com/v1/releases/terraform/latest"
    $resp = Invoke-RestMethod -Uri $latestReleaseUrl -ErrorAction Stop
    $latestVersion = $resp.version
    Write-Success "Detected latest Terraform version: $latestVersion"

    # 2. Build the zip filename & download URL
    $zipFileName = "terraform_${latestVersion}_windows_amd64.zip"
    $downloadUrl = "https://releases.hashicorp.com/terraform/$latestVersion/$zipFileName"
    Write-Info "Download URL: $downloadUrl"

    # 3. Download to a temp location
    $tempZipPath = "$env:TEMP\$zipFileName"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZipPath -ErrorAction Stop
    Write-Success "Downloaded Terraform archive to: $tempZipPath"

    # 4. Unzip contents to %USERPROFILE%
    $destination = $env:USERPROFILE
    Expand-Archive -Path $tempZipPath -DestinationPath $destination -Force -ErrorAction Stop
    Write-Success "Extracted Terraform binary to: $destination"

    # 5. Optionally, clean up zip file
    Remove-Item $tempZipPath -ErrorAction Continue
    Write-Success "Removed temporary archive file."

    # 6. Ensure %USERPROFILE% is in User PATH
    $oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $newEntry = $env:USERPROFILE.TrimEnd('\')  # Remove trailing backslash for comparison

    # Split the PATH into an array for easier comparison
    $pathEntries = $oldPath -split ';' | ForEach-Object { $_.TrimEnd('\') }

    # Check if the new entry is already in the PATH (case-insensitive)
    if ($pathEntries -notcontains $newEntry) {
        $newPath = $oldPath + ";" + $newEntry
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Success "Added $newEntry to your User PATH."
    } else {
        Write-Info "$newEntry is already in your User PATH."
    }

    Write-Host "`n"
    Write-Success "Terraform $latestVersion is ready! Restart your terminal to use it."
}
Catch {
    Write-ErrorMsg "An error occurred: $($_.Exception.Message)"
}
