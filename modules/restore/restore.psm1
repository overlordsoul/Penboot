function Start-PenBootRestore
{
    $UsbDevices = New-Object -TypeName System.Collections.Generic.List[object];

    Write-Host "Selecione o disco em que o Backup se encontra"
    Get-Disk | Where-Object {$_.Bustype -Eq "USB" -and $_.Size -gt $PartitionBackupSizeToCreate} | ForEach-Object { $UsbDevices.Add([System.Object]@{Name = $_.FriendlyName; Size = $_.Size; DiskNumber = $_.Number}) }

    if($UsbDevices.Count -gt 0)
    {
        Write-Host "Listando dispositivos... "
        foreach($device in $UsbDevices)
        {
            Write-Host "[$($device.DiskNumber)] Disco: '$($device.Name)'";
        }

        $SelectedDiskNumber = Read-Host "Por Favor. Insira o número do disco"
        $PathOfBackup = (Get-Partition -DiskNumber $SelectedDiskNumber).AccessPaths | Where-Object { if($_ -ne $null) {$_.Contains("D:\")}  };

        Write-Host "Copiando arquivos de backup para a sua nova HOME ($Env:USERPROFILE)..."
        #Copy-Item -Path $PathOfBackup -Destination $Env:USERPROFILE -Confirm:$false -Recurse -ErrorAction SilentlyContinue

        Write-Host "Procurando por pastas e configurações do PENBOOT... "
        $PenbootJsonFiles = Get-ChildItem -Recurse -Path $Env:USERPROFILE | Where-Object { $_.Name -like "*PENBOOT*.JSON" };
        $PenbootDriversInf = Get-ChildItem -Path "$Env:USERPROFILE\PENBOOT_DRIVERS" -Recurse | Where-Object { $_.Name -like "*.INF"  } 

        foreach ($JsonFile in $PenbootJsonFiles) 
        {
            if($JsonFile.Name -eq "PENBOOT_SOFTWARES.JSON")
            {
                $Config = Get-Content $JsonFile.FullName | ConvertFrom-Json -Depth 99

                foreach($Software in $Config)
                {
                    Write-Host "[ CHOCOLATEY ] Instalando o Programa: $($Software.Name)"
                    #Invoke-Command -ScriptBlock { choco install $Software.Name };
                    Write-Host "Instalando programa usando chocolatey em background"
                }
            }
        }

        $PenbootDriversInf | ForEach-Object { Write-Host "Instalando Script de Driver: $($_)" };
        Write-Host "PenBoot terminou a configuração!"
    }

}