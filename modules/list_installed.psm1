# POWERSHELL MODULE TO DETECTS INSTALLED SOFTWARES;

function Get-InstalledSoftwares {
  $InstalledSoftwares = Get-CimInstance -Class CIM_ApplicationSystem
  return $InstalledSoftwares
}
