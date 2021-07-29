# #Requires -Module DhcpServer

[CmdletBinding()]
Param (
)

# check/load config file
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.json'

if (Test-Path -Path $ConfigPath) {
    $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
} else {
    Throw "config.json not found in script path: $PSScriptRoot"
}


# Sanitize OUIs
$XiqOUI = @()
foreach ($oui in $Config.XiqOUI) {
    $oui = $oui -replace '[^a-zA-Z0-9]'
    $oui = $oui.Substring(0, 2) + '-' + $oui.Substring(2, 2) + '-' + $oui.Substring(4, 2)
    if ($oui.Length -ne 8) {
        Write-Warning "invalid oui: $oui"
    } else {
        $XiqOUI += $oui
    }
}


$DhcpParams = @{}
$DhcpParams.ComputerName = $Config.DhcpServer

$ReservationCount = 0
$RemoveReservationCount = 0

foreach ($scopeId in $Config.ScopeId) {
    Write-Verbose "ScopeId: $scopeId"
    $DhcpParams.ScopeId = $scopeId


    $Leases = Get-DhcpServerv4Lease @DhcpParams
    Write-Verbose "$($Leases.Count) Leases Found"

    foreach ($lease in $Leases) {
        $DhcpParams.ClientId = $lease.ClientId

        # check for valid OUIs
        $ThisOuiValid = $false
        foreach ($oui in $XiqOUI) {
            if ($lease.ClientId -match "^$oui") {
                $ThisOuiValid = $true
            }
        }

        # remove invalid reservations
        if (-not $ThisOuiValid) {
            Write-Warning "Invalid ClientID: $($lease.ClientId)"
            if ($lease.AddressState -match 'Reservation') {
                $RemoveResCount++
                #$Remove = Remove-DhcpServerv4Reservation @DhcpParams
            }
            continue
        }

        if ($lease.AddressState -notmatch 'Reservation') {
            Write-Host "Adding Reservation: $($lease.ClientId) -> $($lease.IpAddress)"
            $ResCount++
            #$Add = Add-DhcpServerv4Reservation @DhcpParams -IpAddress $lease.IpAddress
        }
    }

    $DhcpParams.Remove('ClientId')

}

Write-Host "$ResCount reservations added"
Write-Host "$RemoveResCount reservations removed"

<#


#Get all leases in the scope

foreach ($lease in $Leases) {
    $DhcpParams.ClientId = $lease.ClientId

    # check for valid OUIs
    $ThisOuiValid = $false
    foreach ($oui in $ValidOUIs) {
        if ($lease.ClientId -match "^$oui") {
            $ThisOuiValid = $true
        }
    }

    if (-not $ThisOuiValid) {
        Write-Warning "Invalid ClientID: $($lease.ClientId)"
        if ($lease.AddressState -match 'Reservation') {
            $RemoveResCount++
            $Remove = Remove-DhcpServerv4Reservation @DhcpParams
        }
        continue
    }

    if ($lease.AddressState -notmatch 'Reservation') {
        Write-Host "Adding Reservation: $($lease.ClientId) -> $($lease.IpAddress)"
        $ResCount++
        $Add = Add-DhcpServerv4Reservation @DhcpParams -IpAddress $lease.IpAddress
    }
}

Write-Host "$ResCount reservations added"
Write-Host "$RemoveResCount reservations removed"

 #>