function Get-HasElevatedUser {
    $Security = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent());
    return $Security.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
}

function Start-PenbootBackup 
{
    
    if(Get-HasElevatedUser) {
        $InstalledSoftwaresObj = New-Object -TypeName System.Collections.Generic.List[Object]
        $UsbDevices = New-Object -TypeName System.Collections.Generic.List[object]

        Write-Host "Verificando tamanho total da HOME do usuário em $($Env:USERPROFILE)"
        $BackupSize = ((Get-ChildItem -Path $Env:USERPROFILE -Recurse -ErrorAction SilentlyContinue) | Measure-Object -Property Length -Sum).Sum
        Write-host "O Tamanho total da HOME é $(($BackupSize / 1GB).ToString("#.#"))GB"

        Write-Host "Criando arquivos de referencia para instalação dos programas posteriormente..."
        $InstalledSoftwares = Get-CimInstance -Class Win32_Product | Select-Object -Property Name, Version
        $InstalledSoftwares | ForEach-Object { $InstalledSoftwaresObj.Add([System.Object]@{Name = $_.Name; Version=$_.Version})}

        [void]$(New-Item -ItemType File -Path $Env:USERPROFILE -Name 'PROGRAMAS_INSTALADOS_ANTERIOR.JSON' -Value $($InstalledSoftwaresObj | ConvertTo-Json -Depth 99) -Confirm:$false);

        Write-Host "Criando backups de drivers para instalação posterior..."
        #Export expecific drivers to path $Env:USERPROFILE\PENBOOT_USER_DRIVERS
        [void]$(New-Item -ItemType Directory -Name "PENBOOT_DRIVERS" -Path $Env:USERPROFILE -Confirm:$false)
        [void]$(Export-WindowsDriver -Online -Destination "$Env:USERPROFILE\PENBOOT_DRIVERS" -ErrorAction SilentlyContinue -LogLevel 1)

        Write-Host "Computando o tamanho total do backup..."
        $TotalBackupSize = ((Get-ChildItem -Path $Env:USERPROFILE -Recurse -ErrorAction SilentlyContinue) | Measure-Object -Property Length -Sum).Sum
        $PartitionBackupSizeToCreate = ($TotalBackupSize + ($TotalBackupSize * 0.10))

        Write-Host "Obtendo lista de dispositivos externos para realizar backup..."
        Get-Disk | Where-Object {$_.Bustype -Eq "USB" -and $_.Size -gt $PartitionBackupSizeToCreate} | ForEach-Object { $UsbDevices.Add([System.Object]@{Name = $_.FriendlyName; Size = $_.Size; DiskNumber = $_.Number}) }

        if($UsbDevices.Count -gt 0)
        {

            Write-Host "Listando dispositivos para backup... "
            foreach($device in $UsbDevices)
            {
                $DevicesCounter = $DevicesCounter + 1
                Write-Host "[$($device.DiskNumber)] '$($device.Name)' tem o tamanho de $(($device.Size / 1GB).ToString("#.#"))GB";
            }
            
            #TODO: Add validation here 
            $SelectedDiskNumber = Read-Host "Por Favor. Selecione o dispositivo acima que deseja realizar backup!"
        
            Write-Host -BackgroundColor Red -ForegroundColor Black ("Cuidado! Todos os dados do dispositivo serão apagados e será realizado backup neste disco!").ToUpper()
            Write-Host -BackgroundColor Black -ForegroundColor White ""

            $ConfirmDiskErase = Read-Host "Pressione [s] para sim ou [n] para não continuar"

            if($ConfirmDiskErase.ToLower().Contains("s"))
            {
            Clear-Disk -Number $SelectedDiskNumber -RemoveData -Confirm:$false
            Initialize-Disk -Number $SelectedDiskNumber -Confirm:$false
            New-Partition -DiskNumber $SelectedDiskNumber -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -Confirm:$false 
            
            $PathToBackup = (Get-Partition -DiskNumber $SelectedDiskNumber).AccessPaths | Where-Object { $_?.Contains(":\")} 

            Write-Host "Copiando arquivos de backup para o destino..."
            Copy-Item -Path "C:\Users\$Env:USERNAME" -Destination $PathToBackup -Confirm:$false -Recurse -ErrorAction SilentlyContinue
            }
            
        } 
    } else {
        return "Para rodar o backup é necessário estar em modo administrador!"; 
    }
 
}