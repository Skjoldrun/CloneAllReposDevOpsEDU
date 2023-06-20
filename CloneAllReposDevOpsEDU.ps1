
$JsonSettings = Get-Content -Path settings.json | ConvertFrom-Json
$PersonalAccessToken = $JsonSettings.PersonalAccessToken
$Organization = $JsonSettings.Organization
$Project = $JsonSettings.Project
$TargetPath = $JsonSettings.TargetBasePath + $Project

if($PersonalAccessToken -eq "YOUR_PERSONALACCESSTOKEN_HERE") {
    Write-Host "You have not set yoou personal Token to access DevOps in the settings.json!" -ForegroundColor Red
}

if($JsonSettings.IsTest){
    $TargetPath = "$($TargetPath)\Test"
    Write-Host "Testmode active! TargetPath gets set to $($TargetPath)."
}

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)"))
$headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}

$result = Invoke-RestMethod -Uri "https://dev.azure.com/$Organization/$Project/_apis/git/repositories?api-version=6.0" -Method Get -Headers $headers

$result.value.name | ForEach-Object {
    if(-not (Test-Path -Path "$TargetPath\$_" -PathType Container)) {
            Write-Host "Cloning repo $_ to $TargetPath\$_" -ForegroundColor Cyan
        git clone --recurse-submodules -j8 ("https://$Organization@dev.azure.com/$Organization/$Project/_git/" + [uri]::EscapeDataString($_)) $TargetPath/$_
    }
    else {
        Write-Host "Skipped $_. Already exists in $TargetPath\$_." -ForegroundColor Yellow
    }
     
}