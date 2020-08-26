
[PSCustomObject]$DefaultConfig = @{
  configuration = [PSCustomObject]@{
    AppPathInstalation = $()
  }
}

$MissingList = New-Object -TypeName System.Collections.ArrayList;

# $CheckList = @('AppPathInstalation')

function Get-PenBootDoctor {
  param (
    [Switch]$FeelGood
  )
  Write-Host "Checking PENBOOT configuration status`n"
  #Check config file existence
  if(Test-Path -Path "$($ENV:PENBOOT_WORKPATH)config.json"){
    Write-Host "Config file where is: $($ENV:PENBOOT_WORKPATH)config.json "
    $ConfigFile = Get-Content "$($ENV:PENBOOT_WORKPATH)config.json" | ConvertFrom-Json -AsHashtable;
    foreach($KeysInFile in $ConfigFile.Keys) {
      if($ConfigFile[$KeysInFile].Values.Count -gt 0){
        Write-Host "> $($ConfigFile[$KeysInFile].Keys) has in $($ENV:PENBOOT_WORKPATH)config.json" -BackgroundColor Green -ForegroundColor Black
      } else {
        $MissingList.Add($MissingList)
      }
    }
    Write-Host "`n"
  } else {
    New-Item -ItemType File -Path $ENV:PENBOOT_WORKPATH -Name 'config.json' -Value $($DefaultConfig | ConvertTo-Json -Depth 99)
  }
}