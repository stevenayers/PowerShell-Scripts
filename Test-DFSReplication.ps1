function Test-DFSReplication {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$PrimaryLocation,

        [parameter(Mandatory=$true)]
        [string]$SecondaryLocation,

        [parameter(Mandatory=$true)]
        [int]$CheckAfterInMinutes,

        [parameter(Mandatory=$true)]
        [ValidateSet(
            "Hour",
            "3_Hours",
            "6_Hours",
            "12_Hours",
            "Day",
            "2_Days",
            "3_Days",
            "Week",
            "2_Weeks"
        )][string]$RepeatEvery

        
    )

    # ELEVATION
    $user=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $userpcl=new-object System.Security.Principal.WindowsPrincipal($user)
    $admin=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    if (!($userpcl.IsInRole($admin))) {
        Write-Error "This command requires administrative priveleges."
    }
    else {
        $TestPrimary = Test-Path $PrimaryLocation
        $TestSecondary = Test-Path $SecondaryLocation


        if ($TestPrimary -and $TestSecondary)
        {
            switch ($RepeatEvery) {
                "Hour" { $TimeSpan = [TimeSpan]::FromHours(1) }
                "3_Hours" { $TimeSpan = [TimeSpan]::FromHours(3) }
                "6_Hours" { $TimeSpan = [TimeSpan]::FromHours(6) }
                "12_Hours" { $TimeSpan = [TimeSpan]::FromHours(12) }
                "Day" { $TimeSpan = [TimeSpan]::FromDays(1) }
                "2_Days" { $TimeSpan = [TimeSpan]::FromDays(2) }
                "3_Days" { $TimeSpan = [TimeSpan]::FromDays(3) }
                "Week" { $TimeSpan = [TimeSpan]::FromDays(7) }
                "2_Weeks" { $TimeSpan = [TimeSpan]::FromDays(14) }
            }
            if(!(Test-Path $PrimaryLocation\DFSTestRP))
            {
                New-Item $PrimaryLocation\DFSTestRP -ItemType Directory | % {$_.Attributes = "Hidden"}
            }

            New-EventLog -LogName Application -Source “DFS Replication Test” -ErrorAction SilentlyContinue
            Get-ScheduledJob DFSTest | Unregister-ScheduledJob
            $Trigger = New-JobTrigger -RepeatIndefinitely $true -RepetitionInterval $TimeSpan -At (Get-Date)
            $ScriptBlock = {
                param(
                    $CheckAfterInMinutes,$PrimaryLocation,$SecondaryLocation
                )
                $timestamp = "$(("$((Get-Date).ToShortDateString())-$((Get-Date).ToShortTimeString())").Replace('/','-').Replace(':','-'))"
                " " > "$PrimaryLocation\DFSTestRP\Test-DFS-$timestamp.txt"
                Sleep -Seconds ($CheckAfterInMinutes * 60)
                $Replicated = Test-Path $SecondaryLocation\DFSTestRP\Test-DFS-$timestamp.txt
                Remove-Item "$PrimaryLocation\DFSTestRP\Test-DFS-$timestamp.txt" -Force
                if ($Replicated)
                {
                    Write-EventLog -LogName Application -EntryType Information -Message "Success: Replication of test file succeeded.`nPrimary Location: $PrimaryLocation`nSecondary Location: $SecondaryLocation`nInterval: $CheckAfterInMinutes minutes" -EventId 10012 -Source “DFS Replication Test”
                    Remove-Item "$SecondaryLocation\DFSTestRP\Test-DFS-$timestamp.txt" -Force
                }
                else
                {
                    Write-EventLog -LogName Application -EntryType Error -Message "Failed: Replication of test file failed.`nPrimary Location: $PrimaryLocation`nSecondary Location: $SecondaryLocation`nInterval: $CheckAfterInMinutes minutes" -EventId 10012 -Source “DFS Replication Test”
                }
            }

            Register-ScheduledJob -Name DFSTest -Trigger $Trigger -ScriptBlock $ScriptBlock -RunNow -ArgumentList ($CheckAfterInMinutes,$PrimaryLocation,$SecondaryLocation)
        }
        elseif ($TestPrimary)
        {
            Write-Error "SecondaryLocation path could not be found."
        }
        elseif ($TestSecondary)
        {
            Write-Error "PrimaryLocation path could not be found."
        }
        else
        {
            Write-Error "PrimaryLocation & SecondaryLocation path could not be found."
        }
    }


}


