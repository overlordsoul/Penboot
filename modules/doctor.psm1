#Global Variables

# Minimal configuration keys in config file
$CheckList = @('Configuration')
#Missing List Configuration
$MissingList = New-Object -TypeName System.Collections.ArrayList;


#Default Object to Scaffold config file 
[PSCustomObject]$DefaultConfig = @{
  Configuration = [PSCustomObject]@{
    AppPathInstallation = $("$ENV:PENBOOT_WORKPATH\APPS")
  }
}

#Check if minimal config keys
function Get-MinimalConfigs {
  param (
      [PSCustomObject]$Key
  )
}

function Start-PenbootDoctor {
  param (
    [Switch]$FeelGood
  )
  Write-Host "Checking PENBOOT configuration status`n"
  #Check config file existence
  if(Test-Path -Path "$($ENV:PENBOOT_WORKPATH)\CONFIG.JSON"){
    Write-Host "Config file where is: $($ENV:PENBOOT_WORKPATH)\CONFIG.JSON`n"
    $ConfigFile = Get-Content "$($ENV:PENBOOT_WORKPATH)\CONFIG.JSON" | ConvertFrom-Json -AsHashtable;
    foreach($KeyInFile in $ConfigFile.Keys) {
      if(($ConfigFile[$KeyInFile].Values.Count -gt 0)){
        Write-Host "> $($ConfigFile[$KeyInFile].Keys) and has value `'$($ConfigFile[$KeyInFile].Values)`' in $($ENV:PENBOOT_WORKPATH)\CONFIG.JSON`n" -BackgroundColor Green -ForegroundColor Black
      } 
      else {
        Write-host "> $($ConfigFile[$KeyInFile].Keys) is `"null`" " -BackgroundColor Red -ForegroundColor Black
        $ConfigFile.Keys
        [void]$MissingList.Add($MissingList)
      }
    }
    Write-Host "`n"
  } 
  else {
    try {
      Write-Host "[!] Criando arquivos de configuração`n"
      if((Test-Path -Path $ENV:PENBOOT_WORKPATH) -eq $false) {
        $PENBOOT_DIR = New-Item -ItemType Directory -Path $ENV:USERPROFILE -Name "PENBOOT";
        $PENBOOT_APPS = New-Item -ItemType Directory -Path $PENBOOT_DIR -Name "APPS";
        New-Item -ItemType File -Path $PENBOOT_DIR -Name 'CONFIG.JSON' -Value $($DefaultConfig | ConvertTo-Json -Depth 99);
        Write-Information "[!] Arquivos e pastas de configuração criados`n"
      }
    } catch {
      Write-Error "[X] Erro ao criar arquivos de configuração"
    }
  }
}