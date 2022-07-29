# Get list of connected printers

$printers = Get-CimInstance -Class Win32_Printer -Property Name | select Name, Default

$printer1 = "*FollowMe Sharp*"

# Set booleans as to if certain printers are connected.

foreach($printer in $printers) {

    if ($printer -like $printer1) {

        if ($printer -like "*TF-DC.teamfostering.co.uk*") {

            (New-Object -ComObject WScript.Network).SetDefaultPrinter('\\TF-DC.teamfostering.com\TF FollowMe Sharp')

        } elseif ($printer -like "*TF-DC*") {

            (New-Object -ComObject WScript.Network).SetDefaultPrinter('\\TF-DC\TF FollowMe Sharp')

        }

    } else {

        Add-Printer -ConnectionName "\\TF-DC.teamfostering.com\TF FollowMe Sharp"

        (New-Object -ComObject WScript.Network).SetDefaultPrinter('\\TF-DC.teamfostering.com\TF FollowMe Sharp')
    }

}

# Check new default printer

$defaultPrinter = Get-WmiObject -Query " SELECT * FROM Win32_Printer WHERE Default=$true" | Select Name