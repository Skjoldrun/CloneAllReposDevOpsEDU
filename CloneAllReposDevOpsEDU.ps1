$jsonSettings = Get-Content -Path settings.json | ConvertFrom-Json
$organization = $jsonSettings.Organization
$project = $jsonSettings.Project
$patFilePath = $jsonSettings.PatFilePath
$targetPath = $jsonSettings.TargetBasePath + $project
$personalAccessToken = "YOUR_TOKEN_IN_PAT_FILE"

if($PersonalAccessToken -eq "YOUR_TOKEN_IN_PAT_FILE") {
    Write-Host "You have not set you personal Token to access DevOps in the settings.json!" -ForegroundColor Red
}

if($jsonSettings.IsTest){
    $targetPath = "$($targetPath)\Test"
    Write-Host "Testmode active! TargetPath gets set to $($targetPath)."
}

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)"))
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

$result = Invoke-RestMethod -Uri "https://dev.azure.com/$0rganization/$project/_apis/git/repositories?api-version=6.0" -Method Get -Headers $headers

$result.value.name | ForEach-Object {
    if(-not (Test-Path -Path "$targetPath\$_" -PathType Container)) {
            Write-Host "Cloning repo $_ to $targetPath\$_" -ForegroundColor Cyan
        git clone --recurse-submodules -j8 ("https://$organization@dev.azure.com/$organization/$project/_git/" + [uri]::EscapeDataString($_)) $targetPath/$_
    }
    else {
        Write-Host "Skipped $_. Already exists in $targetPath\$_." -ForegroundColor Yellow
    }
     
}
