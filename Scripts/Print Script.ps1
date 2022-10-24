# Get list of connected printers

$printers = Get-CimInstance -Class Win32_Printer -Property Name | select Name, Default

$printer1 = "*PRINTER NAME*"

# Set booleans as to if certain printers are connected.

foreach($printer in $printers) {

    if ($printer -like $printer1) {

        if ($printer -like "*PRINT SERVER FQDN*") {

            (New-Object -ComObject WScript.Network).SetDefaultPrinter('FQDN\PRINTER')

        } elseif ($printer -like "*PRINT SERVER*") {

            (New-Object -ComObject WScript.Network).SetDefaultPrinter('PRINT SERVER\PRINTER')

        }

    } else {

        Add-Printer -ConnectionName "FQDN\PRINTER"

        (New-Object -ComObject WScript.Network).SetDefaultPrinter('FQDN\PRINTER')
    }

}

# Check new default printer

$defaultPrinter = Get-WmiObject -Query " SELECT * FROM Win32_Printer WHERE Default=$true" | Select Name
