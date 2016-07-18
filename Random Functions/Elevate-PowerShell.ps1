function Elevate-PowerShell {
	[CmdletBinding()]
param(
	[parameter(Mandatory=$false)][switch]$ISE
)
if ((get-host).Name -ilike "*ISE*")
{
    $CurrentISE = $true
    $PS = "PowerShell_ISE"
}
else
{
    $CurrentISE = $false
    if ($ISE)
    {
    	$PS = "PowerShell_ISE"
    }
    else
    {
    	$PS = "PowerShell"
    }
}

# ELEVATION
    $user=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $userpcl=new-object System.Security.Principal.WindowsPrincipal($user)
    $admin=[System.Security.Principal.WindowsBuiltInRole]::Administrator
        if ($userpcl.IsInRole($admin)) {
        clear-host
            if ($ISE)
            {
                if ($CurrentISE)
                {
                    Write-host "You are already using PowerShell ISE as Administrator." -ForegroundColor Gray
                }
                else
                {
                    ise
                    exit
                }
            }
            
        }
        else {
            $newProcess = new-object System.Diagnostics.ProcessStartInfo "$PS";
            $newProcess.Verb = "runas";
            [System.Diagnostics.Process]::Start($newProcess);
            exit
        }



}

New-Alias elv Elevate-PowerShell