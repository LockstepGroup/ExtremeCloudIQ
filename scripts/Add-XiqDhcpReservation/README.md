# Add-XIQDhcpReservation

1. Rename example.json to config.json in the same folder as the script.
2. Edit config.json file with correct values as follows.
    * DhcpServer: IP address or hostname of DhcpServer.
    * RemoveInvalidReservation: If true, will remove any reservatins in the specified scopes who's Client IDs do not match an entry in XiqOU.
    * XiqOUI: Array of valid AP OUIs.
    * ScopeID: Array of DHCP Scope IDs.
3. Run script, -Verbose will give details on changes made.