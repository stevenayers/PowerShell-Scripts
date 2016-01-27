$dir = "$home\Desktop"
$TenantComplete = "$dir\TenantComplete.txt"
If (!(Test-Path $TenantComplete)) {md $TenantComplete} else {}
$PartnerTenantCred = Get-Credential
if (Get-Module MSOnline -ListAvailable)
{
    Import-Module MSOnline
    $uri = "https://ps.outlook.com/powershell-liveid?DelegatedOrg="
    Connect-MsolService –Credential $PartnerTenantCred
    Get-MsolPartnerContract | Foreach {
                $TenantID = $($_.Tenantid.guid)
                $Company = $($_.Name)
                $Tenant = $($_.DefaultDomainName)
            $start = get-date
            $date = ((get-date).ToShortDateString()).Replace('/','-')
            $TenantCompleteContent = Get-content $TenantComplete
                if ($TenantCompleteContent -like "*$Tenant*") {
                Write-host "Skipping $company" -ForegroundColor green
                }
                if (!($TenantCompleteContent -like "*$Tenant*")) {
                Write-host "$company" -ForegroundColor Yellow
                $ClientEXOLSessionError = 1
                    do {
                        try {
                            Get-PSSession | Remove-PSSession
                            $PartnerTenantSession = New-PSSession -name "$company Session" –ConfigurationName Microsoft.Exchange -WarningAction SilentlyContinue `
                            -ConnectionUri $($uri+$tenant) -Credential $PartnerTenantCred -Authentication Basic -AllowRedirection -ErrorAction SilentlyContinue
                            Import-PSSession $PartnerTenantSession -AllowClobber
                        }
                        Catch {
                            $ClientEXOLSessionError++
                                if ($ClientEXOLSessionError -le "3") {
                                    Write-Host "Attempt $ClientEXOLSessionError Retrying..."
                                    sleep -Seconds 15
                                }
                                else {
                                    Write-Host "Could not connect to Exchange Online, Continuing." -ForegroundColor Red
                                    Return
                                }
                        }
                    } while ($ClientEXOLSessionError -le "3" -and $ClientEXOLSessionError -ne "1")
                Get-Mailbox | foreach {
                $License = " "
                $EXOLMBDN = ($_.DisplayName).Replace("'","")
                $EXOLMBUPN = ($_.UserPrincipalName).Replace("'","")
    
                if ($EXOLMBUPN -eq $null) {
                $License = "N/A"
                }
                if ($EXOLMBUPN -ne $null) {
                if ($EXOLMBUPN -notlike "*DiscoverySearchMailbox*") {
                Write-host "$EXOLMBUPN"
                $MSOLUser = Get-MsolUser -TenantId $tenantid -UserPrincipalName $EXOLMBUPN
                $MSOLSkuID = " "
                if ($MSOLUser.Licenses.AccountSkuID -ne $null) {
                $Licenses = $MSOLUser.Licenses.AccountSkuID
    
    		$License = "No Lit Hold"
                Switch -Wildcard ($Licenses) {
                 "*ENTERPRISEPACK*" {$License = "E3"}
                 "*MIDSIZEPACK*" {$License = "Midsize Business"}
                 "*STANDARDPACK*" {$License = "E1"}
                 }
                }
                }
                }
                $MailboxProperties =
                    @{"Company"=$Company;
                      "Name"=$EXOLMBDN;
                      "UPN"=$EXOLMBUPN;
                      "Type"=$_.RecipientType;
                      "LitigationHold"=$_.LitigationHoldEnabled;
                      "RetentionHold"=$_.RetentionHoldEnabled;
                      "RetentionPolicy"=$_.RetentionPolicy;
                      "Archive"=$_.ArchiveStatus;
                      "License"=$License
                    }
                New-Object -TypeName PSObject -Property $MailboxProperties | Export-csv $dir\LitHold.csv -append
                }
    
                Write-host "Add Tenant ID"
                $Tenant | out-file $TenantComplete -Append
                
                }
            }
}
else
{
    Write-Error "MSOnline module must be installed."
}
