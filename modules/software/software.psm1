function Get-SoftwareInstalled {
  $InstalledSoftwares = Get-CimInstance -Class Win32_Product
}

function Get-SoftwareChecksum {}

function Get-SoftwareFromRepostory {}

function Install-SoftwareFromRepository {}