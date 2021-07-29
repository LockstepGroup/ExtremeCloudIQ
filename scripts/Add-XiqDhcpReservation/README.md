# Add-XIQDhcpReservation

1. Rename example.json to config.json in the same folder as the script.
2. Edit config.json file with correct values as follows.
  1. DhcpServer: IP address or hostname of DhcpServer.
  2. RemoveInvalidReservation: If true, will remove any reservatins in the specified scopes who's Client IDs do not match an entry in XiqOU.
  3. XiqOUI: Array of valid AP OUIs.
  4. ScopeID: Array of DHCP Scope IDs.
3. Run script, -Verbose will give details on changes made.