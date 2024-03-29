﻿#Set variables

#Get list of VMs running and return their Name and Power State
$vmList = Get-VM | Select-Object Name,State

#Text file list of VMs to be checking
$vmChecks = "FILEPATH"

#Set email and use stored encrypted credentials to send out alert emails
$email = "EMAIL ADDRESS"
$password = Get-Content "GET STORED PASSWORD" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential($email,$password)

#Get current date for logging
$date = Get-Date -Format "hh:mm:ss dd/MM/yy"

#Set discord webhook URI
$hookURL = "DISCORD WEBHOOK"


#Loop for each VM found on the list of VMs created earlier
ForEach($vm in $vmList) {
    
    #Check if the current VM is in the list to check
    $search = (Get-Content $vmChecks | Select-String -Pattern $vm.name).Matches.Success
    
            #If VM is in the list, and it is powered off do this
            if ($search -and (Get-VM -Name $vm.name | Where-Object {$_.State -eq "Off"})) {
            
                echo $vm.name


                #Get the VM Name and create a unique identifier using Unix Time + somne fluff
                $vm.name.GetType()
                $vmanmenospace = $vm.Name -replace '\s',''
                echo $vmanmenospace
                $unique = Get-Date -UFormat %s

                #Send out email using credentials and variables 
                Send-MailMessage -From 'VM Checks <EMAIL ADDRESS>' -To 'EMAIL ADDRESS' -Subject "VM $vmanmenospace down on HV" -Body "The server $vmanmenospace is offline on HV, server will restart in 5 minutes. To stop this clear the contents of FILEPATH." -SmtpServer 'SMTP ADDRESS' -Credential $credential

                #Add a line in the log file to state that the VM has been powered off.
                Add-Content -Path "C:\Logs\VM Check Script.txt" -value "$date : $($vm.Name) has been powered off!`r`n"

                #Create Discord Webhook message using variables
                $hookContent = @{

                    "username" = "HV VM Status"
                    "content" = "The server $vmanmenospace is offline on VM, server will restart in 5 minutes. `r`n`r`nTo stop this clear the contents of FILE PATH."

                }

                #Send Webhook message to Discord
                Invoke-RestMethod -Uri $hookURL -Method "post" -Body $hookContent

                #Create file with VM name and it's unique identifier 
                Add-Content -Path "C:\Logs\$($vm.name)-$unique.txt" -Value $($vm.name)

                #Pause for 2 minutes to allow for cancellation if required
                Start-Sleep -Seconds 120
                $date = Get-Date -Format "hh:mm:ss dd/MM/yy"

                # Grab the VM to start from the unique files.
                $VMToStart = Get-Content -Path "C:\Logs\$($vm.name)-$unique.txt"
                echo $VMToStart

                #If the file exists and has not been deleted do this
                if($VMToStart){

                    #Start VM and if any warnings appear put them in variable warning
                    Start-VM -Name $VMToStart -WarningVariable warning

                    #Add log file to state VM is now starting
                    Add-Content -Path "FILEPATH" -value "$date : Starting $($vm.Name) after it has been powered off!`r`n"

                    #Delete file from list of VMs to start
                    Remove-Item -Path "FILEPATH"

                    #If a warning appears e.g. missing disk or VM already running send out an email and discord message
                    if($warning){

                        Send-MailMessage -From "HV VM Checks <EMAIL ADDRESS>" -To "EMAIL ADDRESS" -Subject "Failed to start $vmanmenospace" -Body "The VM restart script failed to start $vmanmenospace. The failure reason is: $warning" -SmtpServer "SMTP ADDRESS" -Credential $credential

                        $hookContent2 = @{

                            "username" = "HV VM Status"
                            "content" = "The server $vmanmenospace failed to start. `r`n`r`nThe failure reason is: $warning"

                        }

                        Invoke-RestMethod -Uri $hookURL -Method "post" -body $hookContent2

                    }

                }

    }
}
    
