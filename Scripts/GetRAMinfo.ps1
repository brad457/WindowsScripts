<#
.SYNOPSIS
  Gets RAM information

.DESCRIPTION
  Provides computers total RAM, current amount used, and current amount free in gigabytes (GB).

.PARAMETER <Parameter_Name>
    value <The value requested by the user to be returned.  The following values (in Value - Definition format) are handled:
                                            Value       Description
                                            "total" -   Total RAM (GB) in the system
                                            "used"  -   Amount of RAM (GB) currently in use
                                            "free"  -   Amount of RAM (GB) currently available
                                            ""      -   An output in the form of a calculation of RAM is returned. The first line of the 
                                                        output with the value names, and the second line with the actual values.  Example:
                                                        Total RAM - Used RAM  = RAM Free
                                                        31.76 - 12.25 = 19.5
                                            "blank" -   An output in the form of a calculation of RAM is returned. The first line of the 
                                                        output with the value names, and the second line with the actual values.  Example:
                                                        Total RAM - Used RAM  = RAM Free
                                                        31.76 - 12.25 = 19.5  
                                            "help"  -   A script help / information screen is shown
                                            "/h"    -   A script help / information screen is shown
                                            "/?"    -   A script help / information screen is shown
                                            "--help"-   A script help / information screen is shown
                                            "--?"   -   A script help / information screen is shown
                                            "-?"    -   A script help / information screen is shown
                                            "?"     -   A script help / information screen is shown                                                        
                                                        >

.INPUTS
  <1 - value - See Parameters>

.NOTES
  Version:        1.0
  Author:         Brad457
  Source: https://github.com/brad457/WindowsScripts
  Creation Date:  2022.04.02
  Last Updated:  2023.05.18
  
#>
$helptext = "______________
GetRAMInfo.ps1
______________

Synopsis:     Gets RAM information
Description:  Provides computers total RAM, current amount used, and current amount free in gigabytes (GB).
Version:      1.0
Author:       Brad457
Source:       https://github.com/brad457/WindowsScripts
Date Created: 2023.04.02
Last Updated: 2023.05.18

Arg Value      Description
`"total`"     -  Total RAM (GB) in the system
`"used`"      -  Amount of RAM (GB) currently in use
`"free`"      -  Amount of RAM (GB) currently available
`"allslots`"  -  Number of memory slots in system
`"usedslots`" -  Number of memory slots currently used
`"freeslots`" -  Number of memory slots currently free
`"`"          -  An output in the form of a calculation of RAM is returned. The first line of the 
               output with the value names, and the second line with the actual values.  Example:
               Total RAM - Used RAM  = RAM Free            
`"blank`"     -  An output in the form of a calculation of RAM is returned. The first line of the 
               output with the value names, and the second line with the actual values.  Example:
               Total RAM - Used RAM  = RAM Free            
`"help`"      -  A script help / information screen is shown
`"/h`"        -  A script help / information screen is shown
`"/?`"        -  A script help / information screen is shown
`"--help`"    -  A script help / information screen is shown
`"--?`"       -  A script help / information screen is shown
`"-?`"        -  A script help / information screen is shown
`"?`"         -  A script help / information screen is shown"
function ShowHelp() {
  #Show help
  Write-Output $helptext  
}

$value = ""

if ($args.Count -eq 0) { 
  # if script run without arguements 
}
else {
  # if script was run with arguements assign the first arguement to the value variable
  $value = $args[0]
}

# set hostname variable to computer name
Set-Variable -Name "hostname" -Value $env:COMPUTERNAME

# determine what the value variable text is and if it is one of the configured values then create the proper output
switch ($value) {

  "total" {  
    # total RAM
    $RAMTotal = (Get-WmiObject -Class win32_operatingsystem -ComputerName $hostname | ft @{Name = "Total RAM (GB)"; e = { [math]::round($_.TotalVisibleMemorySize / 1MB, 2) } } -HideTableHeaders) | Out-String
    
    # Assign total RAM amount to result variable
    $result = $RAMTotal
  }
  "free" { 
    # free RAM
    $RAMFree = (Get-WmiObject -Class win32_operatingsystem -ComputerName $hostname | ft @{Name = "Free RAM (GB)"; e = { [math]::round($_.FreePhysicalMemory / 1MB, 2) } } -HideTableHeaders) 
    
    # Assign free RAM amount to result variable
    $result = $RAMFree
  }
  "used" { 
    # used RAM
    $RAMUsed = (Get-WmiObject -Class win32_operatingsystem -ComputerName $hostname | ft @{Name = "Used RAM (GB)"; e = { [math]::round(($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / 1MB, 2) } } -AutoSize -HideTableHeaders)
    
    # Assign used RAM amount to result variable
    $result = $RAMUsed
  }
  "allslots" {
    # all memory slots
    $TotalSlots = (((Get-WmiObject -Class "win32_PhysicalMemoryArray" -namespace "root\CIMV2" -ComputerName $hostname).MemoryDevices |  Measure-Object -Sum).Sum | ft -AutoSize -HideTableHeaders) 
    $result = $TotalSlots

  }
  "usedslots" {
    # used memory slots
    $UsedSlots = (($PysicalMemory) | Measure-Object).Count  
    $result = $UsedSlots
    
  }
  "freeslots" {
    # free memory slots
    $TotalSlots = ((Get-WmiObject -Class "win32_PhysicalMemoryArray" -namespace "root\CIMV2" -ComputerName $hostname).MemoryDevices | Measure-Object -Sum).Sum 
    $UsedSlots = (($PysicalMemory) | Measure-Object).Count  
    $result = $TotalSlots - $UsedSlots

  }
  "slotinfo" {
    # provides info on each memory slot and RAM if installed
    $PysicalMemory = Get-WmiObject -class "win32_physicalmemory" -namespace "root\CIMV2" -ComputerName $hostname | Format-Table Tag,BankLabel,@{n="Capacity(GB)";e={$_.Capacity/1GB}},Manufacturer,PartNumber,Speed -AutoSize
    $result = $PysicalMemory
  }
  { $_ -in "", "blank" } {
    # Show the Total RAM minus the Used RAM and the remaining RAM free.
    
    # Assign total RAM amount to RAMTotal variable
    $RAMTotal = ((Get-WmiObject -Class win32_operatingsystem -ComputerName $hostname | ft @{Name = "Total RAM (GB)"; e = { [math]::round($_.TotalVisibleMemorySize / 1MB, 2) } } -HideTableHeaders) | Out-String).Trim()
    
    # Assign free RAM amount to RAMFree variable
    $RAMFree = ((Get-WmiObject -Class win32_operatingsystem -ComputerName $hostname | ft @{Name = "Free RAM (GB)"; e = { [math]::round($_.FreePhysicalMemory / 1MB, 2) } } -HideTableHeaders) | Out-String).Trim()
    
    # Assign used RAM amount to RAMUsed variable
    $RAMUsed = ((Get-WmiObject -Class win32_operatingsystem -ComputerName $hostname | ft @{Name = "Used RAM (GB)"; e = { [math]::round(($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / 1MB, 2) } } -AutoSize -HideTableHeaders) | Out-String).Trim()
    
    # Write headers to indentify the result output
    Write-Output "Total RAM - Used RAM  = RAM Free"
    
    # Assign RAMTotal - RAMUser = RAMFree to result variable
    $result = $RAMTotal + " - " + $RAMUsed + " = " + $RAMFree
  }
  { $_ -in "/h", "help", "/?", "--help", "--?", "-?", "?" } {
    # display help text
    ShowHelp
  }
}

# Convert result variable to String
$result = $result | Out-String
# Trim extra spaces from result variable and output it
$result.Trim()
