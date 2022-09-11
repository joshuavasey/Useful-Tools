#Set variables

#Get list of services running and return their Name and State
$serviceList = Get-Service | Select-Object Name,Status

#Text file list of services to be checking
$serviceChecks = "C:\Users\OneIT\Desktop\Service Checks.txt"

#Set email and use stored encrypted credentials to send out alert emails
$email = "datacentre@oneits.co.uk"
$password = Get-Content "C:\Users\OneIT\Documents\encryptedpwd.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential($email,$password)

#Get current date for logging
$date = Get-Date -Format "hh:mm:ss dd/MM/yy"

#Set discord webhook URI
$hookURL = "https://discord.com/api/webhooks/1011607591320813649/jC_yVWfj_TqlcyNsunget3CKTdYRh7ZPr5uLCNJwreJBMNyzT6udxJOcG9TJ0UapiKUD"

Foreach($service in $serviceList){

    #Check if the current service is in the list to check
    $search = (Get-Content $serviceChecks | Select-String -Pattern $service.name).Matches.Success

            #If service is in the list, and it is powered off do this
            if ($search -and (Get-Service -Name $service.name | Where-Object {$_.Status -eq "Stopped"})) {

                $unique = Get-Date -UFormat %s

                #Send out email using credentials and variables 
                Send-MailMessage -From 'Moorview Service Checks <datacentre@oneits.co.uk>' -To 'engineers@oneits.co.uk' -Subject "Service $($service.name) down on MV-REF-DATA" -Body "The server $($service.name) is offline on MV-REF-DATA, service will restart in 2 minutes. To stop this clear the contents of C:\Logs\$($service.name)-$unique.txt on TJ." -SmtpServer 'mail.oneits.co.uk' -Credential $credential

                #Add a line in the log file to state that the service has been powered off.
                Add-Content -Path "C:\Logs\Service Check Script.txt" -value "$date : $($service.Name) has stopped!`r`n"

                #Create Discord Webhook message using variables
                $hookContent = @{

                    "username" = "Moorview Service Status"
                    "content" = "The service $($service.name) is offline on MV-REF-DATA, service will restart in 2 minutes. `r`n`r`nTo stop this clear the contents of C:\Logs\$($service.name)-$unique.txt on MV-REF-DATA."

                }

                #Send Webhook message to Discord
                Invoke-RestMethod -Uri $hookURL -Method "post" -Body $hookContent

                #Create file with service name and it's unique identifier 
                Add-Content -Path "C:\Logs\$($service.name)-$unique.txt" -Value $($service.name)

                #Pause for 2 minutes to allow for cancellation if required
                Start-Sleep -Seconds 120
                $date = Get-Date -Format "hh:mm:ss dd/MM/yy"

                # Grab the service to start from the unique files.
                $ServiceToStart = Get-Content -Path "C:\Logs\$($service.name)-$unique.txt"

                #If the file exists and has not been deleted do this
                if($ServiceToStart){

                    #Start service and if any warnings appear put them in variable warning
                    Start-Service -Name $service.name

                    #Add log file to state service is now starting
                    Add-Content -Path "C:\Logs\Service Check Script.txt" -value "$date : Starting $($service.Name) after it had stopped!`r`n"

                    #Delete file from list of service to start
                    Remove-Item -Path "C:\Logs\$($service.name)-$unique.txt"

                    #If a warning appears send out an email and discord message
                    if($warning){

                        Send-MailMessage -From "Moorview Service Checks <datacentre@oneits.co.uk>" -To "engineers@oneits.co.uk" -Subject "Failed to start $($service.name)" -Body "The service restart script failed to start $($service.name). The failure reason is: $warning" -SmtpServer "mail.oneits.co.uk" -Credential $credential

                        $hookContent2 = @{

                            "username" = "Moorview Service Status"
                            "content" = "The service $($service.name) failed to start. `r`n`r`nThe failure reason is: $warning"

                        }

                        Invoke-RestMethod -Uri $hookURL -Method "post" -body $hookContent2

                    }

                }
            }

}