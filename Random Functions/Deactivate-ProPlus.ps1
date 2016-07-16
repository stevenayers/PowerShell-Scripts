Function Deactivate-ProPlus {

    BEGIN {
        $___ =  "======================================"
        $dstatus = "RETRIEVING KEY"
        $unpkey = "DEACTIVATING OFFICE"
        $errortitle = "ERROR"
        $PSData = "C:\Windows\Temp\Deactivate"
            If (!(Test-Path $PSData)) {
            md $PSData | Out-Null
            }
            else {
            }
        $32 = "32-bit"
        $64 = "64-bit"
        $OS = Get-wmiobject win32_operatingsystem
        $OSbit = $OS.OSArchitecture
            if ($OSbit -eq $32) {
                $ProgramFiles = "C:\Program Files\"
            }
            if ($OSbit -eq $64) {
                $ProgramFiles = "C:\Program Files (x86)\"
            }
        $MSPath = "$ProgramFiles\Microsoft Office\"
            if (Test-Path "$MSPath\Office14\") {
                $OfficePath = "$MSPath\Office14\"
            }
            if (Test-Path "$MSPath\Office15\") {
                $OfficePath = "$MSPath\Office15\"
            }
            if (Test-Path "$MSPath\Office16\") {
                $OfficePath = "$MSPath\Office16"
            }
            if ($OfficePath -eq $null) {
                Write-Error "Microst Office\Office14/Office15/Office16 could not be found."
                $___    >> $OSPPOutputFile
                $errortitle >> $OSPPOutputFile
                $___    >> $OSPPOutputFile
                $Error[0] >> $OSPPOutputFile
                Break
            }
    }
     PROCESS {
        $OSPPOutputFile = "$PSData\OSPPOutput.txt"
        $___    >> $OSPPOutputFile
        $dstatus >> $OSPPOutputFile
        $___    >> $OSPPOutputFile
        if (!(Test-Path $OSPPOutputFIle)) {
            Invoke-Command -ScriptBlock {
                cd $OfficePath
                cscript.exe ospp.vbs /dstatus >> $OSPPOutputFile
            }
        $OSPPData = Get-Content $OSPPOutputFile
        $LastFive = ($OSPPData | Select-String -SimpleMatch "Last 5 characters of installed product key:") -split ":"
        if ($LastFive[1] -ne $null) {
            $___    >> $OSPPOutputFile
            $unpkey >> $OSPPOutputFile
            $___    >> $OSPPOutputFile
            $ProductKey = ($LastFive[1]).Trim()
                Invoke-Command -ScriptBlock {
                    cd $OfficePath
                    cscript.exe ospp.vbs /unpkey:$ProductKey >> $OSPPOutputFile
                }
        }
        if ($LastFive[1] -eq $null) {
            Write-Error "Could not find the Last 5 characters of the installed product key, please review the information above to identify if a key if installed."
            $___    >> $OSPPOutputFile
            $errortitle >> $OSPPOutputFile
            $___    >> $OSPPOutputFile
            $Error[0] >> $OSPPOutputFile
        }
        }
    }  
}
Deactivate-ProPlus
