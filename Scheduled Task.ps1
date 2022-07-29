# Check if task exists. Change Variable to whatever is required

$taskName = "Default Printer"
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -Like $taskName}

if($taskExist) {

    # Output logging

    echo "Task Exists" | Add-Content -Path "$env:APPDATA\PrintTask.txt"

} else {

    # Create Scheduled Task to run immediately and every 5 minutes after, can change action and frequency here

    $ac = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File \\tf-dc\LicencingTokens\TFPrint.ps1"
    $tr = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
    $tsk = Register-ScheduledTask -TaskName $taskName -Trigger $tr -Action $ac

    #Run task after creating it.

    Start-ScheduledTask -TaskName $taskName

}