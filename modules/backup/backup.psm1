Start-PenbootBackup 
{

    $InstalledSoftwaresObj = New-Object -TypeName System.Collections.Generic.List[Object]
    $UsbDevices = New-Object -TypeName System.Collections.Generic.List[object]

    Write-Host "Verificando tamanho total da HOME do usuário em $($Env:USERPROFILE)"
    $BackupSize = ((Get-ChildItem -Path $Env:USERPROFILE -Recurse -ErrorAction SilentlyContinue) | Measure-Object -Property Length -Sum).Sum
    Write-host "O Tamanho total da HOME é $(($BackupSize / 1GB).ToString("#.#"))GB"

    Write-Host "Criando arquivos de referencia para instalação dos programas posteriormente..."
    $InstalledSoftwares = Get-CimInstance -Class Win32_Product | Select-Object -Property Name, Version
    $InstalledSoftwares | ForEach-Object { $InstalledSoftwaresObj.Add([System.Object]@{Name = $_.Name; Version=$_.Version})}

    [void]$(New-Item -ItemType File -Path $Env:USERPROFILE -Name 'PROGRAMAS_INSTALADOS_ANTERIOR.JSON' -Value $($InstalledSoftwaresObj | ConvertTo-Json -Depth 99));

    Write-Host "Criando backups de drivers para instalação posterior..."
    #Export expecific drivers to path $Env:USERPROFILE\PENBOOT_USER_DRIVERS
    Export-WindowsDriver -Online -Path $Env:USERPROFILE -ErrorAction SilentlyContinue


    Write-Host "Computando o tamanho total do backup..."
    $TotalBackupSize = ((Get-ChildItem -Path $Env:USERPROFILE -Recurse -ErrorAction SilentlyContinue) | Measure-Object -Property Length -Sum).Sum

    Write-Host "Obtendo lista de dispositivos externos para realizar backup..."
    Get-Disk | Where-Object {$_.Bustype -Eq "USB" -and $_.Size -gt $TotalBackupSize} | ForEach-Object { $UsbDevices.Add([System.Object]@{Name = $_.FriendlyName; Size = $_.Size}) }

    if($UsbDevices.Count -gt 0)
    {
        $DevicesCounter = 0;
        $SelectedDevice = 0;

        Write-Host "Listando dispositivos para backup... "
        foreach($device in $UsbDevices)
        {
            $DevicesCounter = $DevicesCounter + 1
            Write-Host "[$DevicesCounter] '$($device.Name)' tem o tamanho de $(($device.Size / 1GB).ToString("#.#"))";
        }
        
        #TODO: Add validation here 

        $SelectedDevice = Read-Host "Por Favor. Selecione o dispositivo acima que deseja realizar backup!"
        $SelectedDevice = $SelectedDevice - 1;
    } 
    else 
    {
        #TODO: Partitions will created here;

    }

    Write-Host "Detectando possíveis armazenamentos USB disponíveis para armazenar o backup"
    Get-CimInstance Win32_DiskDrive | Where-Object {$_.InterfaceType -like "USB"}
    
}