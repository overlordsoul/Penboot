# POWERSHELL MODULE TO DETECTS INSTALLED SOFTWARES;

function Get-InstalledSoftwares {
  $InstalledSoftwares = Get-CimInstance -Class Win32_Product
  return $InstalledSoftwares
}

