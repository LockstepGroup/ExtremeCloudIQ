#Requires -Module DhcpServer
#Requires -Module CorkScrew

[CmdletBinding()]
Param (
)

$DhcpServer = 'dhcp.example.com'
$ScopeId = '172.16.0.0'

$ValidOUIs = @(
    'BCF310'
    '348584'
    'F220E5'
    'FF55D2'
    'FF5AE2'
    'FF859F'
    'FF92F7'
    'FFB353'
    'FFB89D'
    'FFCB3A'
    'FFD00C'
    'FFDD49'
    'FFF679'
    'FFF6D9'
    'FFF77F'
)

$DhcpParams = @{}
$DhcpParams.ScopeId = $ScopeId
$DhcpParams.ComputerName = $DhcpServer

#Get all leases in the scope
$Leases = Get-DhcpServerv4Lease @DhcpParams
#Loop through the leases and convert them to reservations
$ResCount = 0
$RemoveResCount = 0

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

