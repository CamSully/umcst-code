# A script to locate events meeting specific criteria and print them. Originally written by Ashley McGlone.
# Currently, the script searches for login events for a certain user.
# To-do: Only get necessary properties (Time, machine name [computer they're logging into, username, workstation IP, workstation hostname)
# To-do: Add code to write output to a file.

$Events = Get-WinEvent -path 'C:\Windows\System32\winevt\Logs\Security.evtx' -FilterXPath "*[System[EventID=4624] and EventData[Data[@Name='TargetUserName'] = 'USERNAME']]"

ForEach ($Event in $Events) {
    # Convert the event to XML
    $eventXML = [xml]$Event.ToXml()
    # Iterate through each one of the XML message properties
    For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {
        # Append these as object properties
        Add-Member -InputObject $Event -MemberType NoteProperty -Force `
            -Name  $eventXML.Event.EventData.Data[$i].name `
            -Value $eventXML.Event.EventData.Data[$i].'#text'
    }
}
$Events | Select-Object *