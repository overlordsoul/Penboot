#Global Variables

# Minimal configuration keys in config file
$CheckList = @('Configuration', "AppPathInstallation")

#Missing List Configuration
$MissingList = New-Object -TypeName System.Collections.ArrayList;


#Default Object to Scaffold config file 
[PSCustomObject]$DefaultConfig = @{
  Configuration = [PSCustomObject]@{
    AppPathInstallation = $("$ENV:PENBOOT_WORKPATH\APPS")
  }
}

#Create a new config file
function Build-PenbootConfiguration {
  param (
    [String]$Path,
    [PSCustomObject]$DefaultConfiguration
  )
  Write-Host "[!] Criando arquivos de configuração`n" -ForegroundColor Black -BackgroundColor Yellow
  #TODO: Criar backup do arquivo!
  Write-host "Foi detectado que há um arquivo de configuração em $($ENV:PENBOOT_WORKPATH)\CONFIG.JSON...Sobreescrevendo porém mantendo backup!"
  if((Test-Path -Path $ENV:PENBOOT_WORKPATH) -eq $false) {
    $PENBOOT_DIR = $(New-Item -ItemType Directory -Path $ENV:USERPROFILE -Name "PENBOOT");
    $PENBOOT_APPS = $(New-Item -ItemType Directory -Path $PENBOOT_DIR -Name "APPS");
    [void]$(New-Item -ItemType File -Path $PENBOOT_DIR -Name 'CONFIG.JSON' -Value $($DefaultConfig | ConvertTo-Json -Depth 99));
    
    Write-Host "[!] Novo diretório de trabalho para o PenBoot Criado: $PENBOOT_DIR" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "[!] Nova pasta de instalação de apps criada em: $PENBOOT_APPS" -ForegroundColor Black -BackgroundColor Yellow
    Write-Information "[!] Arquivos e pastas de configuração criados`n"
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
    [Switch]$FeelingGood
  )
  Write-Host "Checking PENBOOT configuration status`n"
  #Check config file existence
  if(Test-Path -Path "$($ENV:PENBOOT_WORKPATH)\CONFIG.JSON"){
    Write-Host "Config file where is: $($ENV:PENBOOT_WORKPATH)\CONFIG.JSON`n"
    $ConfigFile = Get-Content "$($ENV:PENBOOT_WORKPATH)\CONFIG.JSON" | ConvertFrom-Json -AsHashtable;
    foreach($key in ($ConfigFile.Keys)) {
      if($CheckList.Contains($key)) {
        #Se o conteúdo for objeto
        if(($ConfigFile[$key].Values.Count -gt 0)){
          Write-Host "> $key exists and has value $($ConfigFile[$key].Keys) = `'$($ConfigFile[$key].Values)`' in $($ENV:PENBOOT_WORKPATH)\CONFIG.JSON`n" -BackgroundColor Green -ForegroundColor Black
        }
        #Se não for objeto
        else {
          #TODO: Melhorar essa seção
          Write-Host "$key => $($ConfigFile[$key])"
        }
      }
      else {
        Write-host "> $($ConfigFile[$key].Keys) is `"null`" " -BackgroundColor Red -ForegroundColor Black
        $ConfigFile.Keys  
        [void]$MissingList.Add($MissingList)
      }
    }
  } 
  else {
    try {
      if((Test-Path -Path $ENV:PENBOOT_WORKPATH) -eq $false) {
        $PENBOOT_DIR = New-Item -ItemType Directory -Path $ENV:USERPROFILE -Name "PENBOOT";
        $PENBOOT_APPS = New-Item -ItemType Directory -Path $PENBOOT_DIR -Name "APPS";
        [void]$(New-Item -ItemType File -Path $PENBOOT_DIR -Name 'CONFIG.JSON' -Value $($DefaultConfig | ConvertTo-Json -Depth 99));
        
        Write-Host "[!] Novo diretório de trabalho para o PenBoot criado em: $PENBOOT_DIR" -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "[!] Nova pasta de instalação de apps criada em: $PENBOOT_APPS" -ForegroundColor Black -BackgroundColor Yellow
  
        Write-Information "[!] Arquivos e pastas de configuração criados`n"
      }
    } catch {
      Write-Error "[X] Erro ao criar arquivos de configuração"
    }
  }

  if($MissingList.Count -gt 0){
    Write-Host '
      $$\   $$\  $$$$$$\  $$$$$$$$\       $$$$$$$$\ $$$$$$$$\ $$$$$$$$\ $$\       $$$$$$\ $$\   $$\  $$$$$$\        $$\      $$\ $$$$$$$$\ $$$$$$$$\ $$\       $$\ 
      $$$\  $$ |$$  __$$\ \__$$  __|      $$  _____|$$  _____|$$  _____|$$ |      \_$$  _|$$$\  $$ |$$  __$$\       $$ | $\  $$ |$$  _____|$$  _____|$$ |      $$ |
      $$$$\ $$ |$$ /  $$ |   $$ |         $$ |      $$ |      $$ |      $$ |        $$ |  $$$$\ $$ |$$ /  \__|      $$ |$$$\ $$ |$$ |      $$ |      $$ |      $$ |
      $$ $$\$$ |$$ |  $$ |   $$ |         $$$$$\    $$$$$\    $$$$$\    $$ |        $$ |  $$ $$\$$ |$$ |$$$$\       $$ $$ $$\$$ |$$$$$\    $$$$$\    $$ |      $$ |
      $$ \$$$$ |$$ |  $$ |   $$ |         $$  __|   $$  __|   $$  __|   $$ |        $$ |  $$ \$$$$ |$$ |\_$$ |      $$$$  _$$$$ |$$  __|   $$  __|   $$ |      \__|
      $$ |\$$$ |$$ |  $$ |   $$ |         $$ |      $$ |      $$ |      $$ |        $$ |  $$ |\$$$ |$$ |  $$ |      $$$  / \$$$ |$$ |      $$ |      $$ |          
      $$ | \$$ | $$$$$$  |   $$ |         $$ |      $$$$$$$$\ $$$$$$$$\ $$$$$$$$\ $$$$$$\ $$ | \$$ |\$$$$$$  |      $$  /   \$$ |$$$$$$$$\ $$$$$$$$\ $$$$$$$$\ $$\ 
      \__|  \__| \______/    \__|         \__|      \________|\________|\________|\______|\__|  \__| \______/       \__/     \__|\________|\________|\________|\__|'
    
  }
}