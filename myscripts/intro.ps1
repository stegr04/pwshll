Get-PowerShellEditorServicesVersion
$PSVersionTable
Get-Command
Get-ExecutionPolicy
Get-ExecutionPolicy -List
Get-ExecutionPolicy -Scope CurrentUser
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
Set-ExecutionPolicy -ExecutionPolicy -Scope CurrentUser

# This was produced by using the following keystrokes in vscode on macos: command+alt+j
function Get-RemotePowershellVersions {
  [CmdletBinding()]
  param (
    
  )
  
  begin {
    
  }
  
  process {
    
  }
  
  end {
      
  }
}

# Press Command+K (then release and press) Z for zen mode.
# Command+\ to edit side by side


### HELP
get-help g*service
update-help -Force

Enter-PSSession -Hostname dc -Username administrator -SSHTransport

# export service list to file
get-service | export-csv -Path c:\service.csv

# export process represented in xml to file
get-process | Export-Clixml -Path C:\good.xml

# Compare Objects (the xml data from good.xml and live representation of data) by its name property/attribute.
Compare-Object -ReferenceObject (Import-Clixml c:\good.xml) -DifferenceObject (Get-Process) -Property name

# lists help for out cmdlets.
get-help out

get-service | ConvertTo-Csv
get-service | ConvertTo-Html
get-service | ConvertTo-Json
get-service | ConvertTo-MOFInstance
get-Service | ConvertTo-SecureString
get-service | ConvertTo-Xml

get-service | ConvertFrom-Csv
get-service | ConvertFrom-Json
get-service | ConvertFrom-Markdown
get-service | ConvertFrom-SddlString
get-service | ConvertFrom-SecureString
get-service | ConvertFrom-StringData

# The "-WhatIf" will tell you what it would have done. However, becareful. Doing a reboot or shutdown would reboot or shutdown even with -WhatIf. 
get-service | stop-service -WhatIf

# You can append -confirm to cmdlets to have it prompt you. For example:
get-service | stop-service -Confirm
# Will show you: 
## Confirm
## Are you sure you want to perform this action?
## Performing the operation "Stop-Service" on target "Active Directory Web Services (ADWS)".
## [Y] Yes [A] Yes to All [N] No [L] No to All [?] Help (default is "Yes"):

# Get something.. lol
Get-ADComputer -filter *

Import-Module ServerManager

Get-WindowsFeature

Add-WindowsFeature telnet-client, telnet-server -Restart

### Objects for the Admin
get-service b* # Gets service objects with properties and methods. 

# The key is delaying the conversation of objects to text for as long as possible. For example:
Get-Process # How do you get all that are greater than 1000 (consider how you'd do this in linux). It involves "Prayer based parsing" - lol. 
# However, you can do this in powershell using properties of the objects. For example: 
Get-Process | where Handles -gt 900
# or get the list sorted like so: 
Get-Process | where Handles -gt 900 | sort handles

# To get the list the attributes and methods for an object using Get-Members (gm)
get-service -name bits | gm

get-process -name chrome | gm

get-service | select -Property name, Status

get-childitem | select -Property name, length | sort -property length

get-childitem | select -Property name, length | sort -property length -Descending


# Using the pipeline to list newest 5 events 
get-eventlog -logname system -newest 5 | select eventid, timewritten, message | sort -property timewritten | ConvertTo-Html | out-file C:\error.htm

# They have Cim objects. Do they have Cim objects for log messages?

# Working with XML data:
$x = [xml](cat .\r_and_j.xml)

# Print the xml object!
$x

# showed that the variable x was of type XML
$x.gettype()

$x.PLAY.ACT[0]

$x.PLAY.ACT[0].SCENE[0].SPEECH

$x.PLAY.ACT[0].SCENE[0].SPEECH | select -First 1
$x.PLAY.ACT.SCENE.SPEECH | group speaker | sort count


get-history


# filter out the data that you only want to see - whatever is inside your squigly brackets will be your filter. $_ is the object coming over the pipeline
get-service | where-Object -FilterScript {$_.status -eq "Running"}


get-help *comparison*

#New way to write the above filter. Example of and conditional/comparison. 
get-service | where {PSItem.status -eq "Running" -and $_.name -like "b*"}


# The way that they go about doing where... They added three lines and far more powerful than SQL:
# 1. where basically takes each object that comes through the pipeline and assigns it to a variable.
# 2. Evaluate the code within the squigly brackets. 
# 3. If the code returns true then they pass the object on. If it doesn't then it throws it away. 

gps | where {$_.handles -ge 1000}

# NOTE: It doesn't have to evaluate the object - you could do gps *ss | where {$false} for it to return nothing or "gps *ss | where {$true}" for it to return everything. 


#They have a simplified version of where (with squigly brackets you can do anything, with this way not so much). You can do Where property value
gps | where handles -ge 1000



# How the pipeline really works - The 4 step solution
# 1. ByValue
# 2. ByPropertyName
# 3. What if my property doesn't match - Customize it!
# 4. The Parenthetical - when all else fails. 

# example: get-service | stop service       # This will stop all services. 
# Check the -full help to see if a parameter "Accept pipeline input". If true then check the "type of object the parameter accepts. So, for example:
## The stop-service -Name parameter accepts pipeline input (ByValue and ByPropertyName). The -Name parameter expects a String[] object. 
## The -InputObject also Accept's pipeline input. It accepts it ByValue. The type of object the -InputObject expects is a ServiceController[] object. 
## So when the get-service cmdlet runs it sends a ServiceController object through the pipeline -> to the stop-service cmdlet, the -InputObject is the parameter
## picking up (catching) the ServiceController to know what service it should stop. This is an example of passing something ByValue


# An example of ByPropertyValue that works is get-process calc | dir
## This works through the Path ByPropertyValue. The get-process has a property path that looks like the following: 
# [administrator@dc]: PS C:\Users\Administrator\Documents> gps | gm
## Path                       ScriptProperty System.Object Path {get=$this.Mainmodule.FileName;}

# [administrator@dc]: PS C:\Users\Administrator\Documents> get-help dir -full
## -Path <string[]>
## Required?                    false
## Position?                    0
## Accept pipeline input?       true (ByValue, ByPropertyName)
## Parameter set name           Items
## Aliases                      None
## Dynamic?                     false


# However, sometimes things don't match up - so take the time to learn about hashtables. It uses some special syntax that is in the help for SELECT. 
get-adcomputer -filter * | select -property name, @{name='ComputerName';expression={$_.name}}
# or: 
get-adcomputer -filter * | select -property name, @{n='ComputerName';e={$_.name}}
# or; 
get-adcomputer -filter * | select -property name, @{l='ComputerName';e={$_.name}}


get-adcomputer -filter * | select @{name='ComputerName';expression={$_.name}}

get-adcomputer -filter * | select @{name='ComputerName';expression={$_.name}} | Get-Service -name bits



## Using get-wmiobject presents a different problem. It doesn't accept byvalue or bypropertyname as input object. So you can't use pipeline. 
# so to get this working you need to use parenthesis (which gets that done first.)
get-wmiobject -class 
# if you run the next command with | gm you'll see that the objects are strings.
get-adcomputer -filter * | select -expandproperty name 

get-wmiobject -class win32_bios -ComputerName (get-adcomputer -filter * | select -expandproperty name) 
# or; shorthand introduced in powershell 3
get-wmiobject -class win32_bios -ComputerName (get-adcomputer -filter *).name

get-help get-ciminstance


# GET DON JONES'S GET POWERSHELL IN A MONTH OF LUNCHES - CHAPTER 9.

# Now we're looking at script parameters.
# whenever you see the curly braces it represents a script block {}

# The way that Jeff Snover propsed this works was (But this doesn't work): 
## If you give a script block to a property/parameter that doesn't accept a script parameter it takes the value of the current object, assigns it to $_, and runs the script and takes the value and puts it in there. 
# Get-ADComputer -filter * | get-wmiobject -class win32_bios -ComputerName {$_.Name.ToUpper}


