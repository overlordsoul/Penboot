Start-PenbootBackup 
{

    $InstalledSoftwaresObj = New-Object -TypeName System.Collections.Generic.List[Object]

    Write-Host "Verificando tamanho total da HOME do usuário em $($Env:USERPROFILE)"
    $BackupSize = ((Get-ChildItem -Path $Env:USERPROFILE -Recurse -ErrorAction SilentlyContinue) | Measure-Object -Property Length -Sum).Sum / 1GB
    Write-host "O Tamanho total da HOME é $(+ $BackupSize.ToString("#.#"))GB"

    Write-Host "Criando arquivos de referencia para instalação dos programas posteriormente..."
    $InstalledSoftwares = Get-CimInstance -Class Win32_Product | Select-Object -Property Name, Version
    $InstalledSoftwares | ForEach-Object { $InstalledSoftwaresObj.Add([System.Object]@{Name = $_.Name; Version=$_.Version})}

    [void]$(New-Item -ItemType File -Path $Env:USERPROFILE -Name 'PROGRAMAS_INSTALADOS_ANTERIOR.JSON' -Value $($InstalledSoftwaresObj | ConvertTo-Json -Depth 99));

    Out-File -FilePath

    Write-Host "Criando backups de drivers para instalação posterior"
    $DriversBackup = Export-WindowsDriver -Online -Path $Env:USERPROFILE -ErrorAction SilentlyContinue


    Write-Host "Computando o tamanho total do backup..."
    $TotalBackupSize = ((Get-ChildItem -Path $Env:USERPROFILE -Recurse -ErrorAction SilentlyContinue) | Measure-Object -Property Length -Sum).Sum / 1GB
    
}