# AUTHOR: Steven Ayers
# CHANGE VALUES TO SUITE YOUR COMPANY
$PartnerCompanyName = "Contoso"
$PartnerCompanyDomain = "contoso.com"

# DETECT TIME & USER
$username = ((Get-Culture).TextInfo).ToTitleCase(($env:USERNAME).replace('.',' '))
# CREATE APPDATA FOLDER
$PSData = "$env:APPDATA\$PartnerCompanyName"
If (!(Test-Path $PSData))
{
    md $PSData | Out-Null 
}
# IMPORT OFFICE 365 FUNCTIONS
try
{
    Import-Module MSOnline
    try
	{
        # CONNECT-MSOLTENANT
        function Connect-MsolTenant
		{
            <#
            .SYNOPSIS
            This will connect you directly to Office 365.


            .DESCRIPTION
            Once you run Connect-Msoltenant, you will be asked to enter the global administrator credentials of the tenant you would like to connect to. You can also run the command by typing 'connect', which is an alias of the command.
            
            There are two other commands, Backup-MsolUser & Backup-Mailbox which should be used before ANY changes are made to a user's details or configuration via PowerShell.

			ALIAS: connect
            #>
            $Hour = (Get-Date).Hour
            If ($Hour -lt 12)
			{
                $greeting = "Good Morning $username"
            }
            ElseIf ($Hour -gt 16)
			{
                $greeting = "Good Evening $username"
            }
            Else
			{
                $greeting = "Good Afternoon $username"
            }
            $ConnectMessage = "$greeting. Please enter global admin credentials for the tenant you wish to connect to."
            do
			{
                $stillblank = $false
                $Global:PartnerCompanyCred = Get-Credential -Message "$ConnectMessage"
                if ($Global:PartnerCompanyCred -eq $null)
				{
                    $ConnectMessage = "You did not enter any credentials, please try again."
                    $attempt++
                }
                if ($attempt -eq 2)
				{
                    $stillblank = $true
                }
            } while (($Global:PartnerCompanyCred -eq $null) -and ($stillblank -eq $false))
            if ($stillblank -eq $true)
			{
                Write-Error "Credentials are null."
            }
            if ($stillblank -eq $false)
			{
                try
				{
					$PartnerCompanySession = New-PSSession –ConfigurationName Microsoft.Exchange -WarningAction SilentlyContinue `
					-ConnectionUri https://ps.outlook.com/powershell -Credential $Global:PartnerCompanyCred -Authentication Basic -AllowRedirection -ErrorAction SilentlyContinue
					Import-PSSession $PartnerCompanySession -AllowClobber | Out-Null
					Connect-MsolService –Credential $Global:PartnerCompanyCred | out-null
					$CompanyName = (Get-MsolCompanyInformation).DisplayName
					if ($CompanyName -ne $null)
					{
					    Write-host " "
					    Write-host "Connected to $CompanyName."
					    Write-host " "
					}
                }
                catch
				{
					Write-Error "Authentication Failed, please check your credentials. You can also try clearing PSSession by running Get-PSSession | Remove PSSession."
                }
            }
        }
        New-Alias connect Connect-MsolTenant
		$Loaded = "Connect-MsolTenant, "

		# GET-MSOLPARTNERTENANT
		function Get-MsolPartnerTenant
		{
			<#
            .SYNOPSIS
            This will retrieve all customer tenants, allow you to connect to them and view the data within them.



            .DESCRIPTION
            Once you run Get-MsolPartnerTenant, you will be asked to enter your own credentials. You will then be shown a list of customer tenants, or ask to specify a keyword so this can be filtered, then exported out to CSV or TXT format.

			You can send the tenant to the pipline, use this for gathering tenant information, or you can specfiy the '-ConnectToExchangeOnline' switch, and connect to the tenant's Exchange.

            There are two other commands, Backup-MsolUser & Backup-Mailbox which should be used before ANY changes are made to a user's details or configuration via PowerShell.
			
			ALIAS: gpt

			.PARAMETER Search
			Specify phrase to query against tenant names. You don't need to specify this.


			.PARAMETER ExportToCsv
			Export the results to CSV file.



			.PARAMETER ExportToTxt
			Export the results to TXT file.



			.PARAMETER ConnectToExchangeOnline
			Connect to Exchange Online for the specified tenant, only one at a time.



			.EXAMPLE
			Get a list of users from FakeCompany Limited:

			Get-MsolPartnerTenant fakec | Get-MsolUser -all
			Get-MsolPartnerTenant "FakeCompany Limited" | Get-MsolUser -all
			Get-MsolPartnerTenant -Search fakecompany.co.uk | Get-MsolUser -all
			gpt fakec | Get-MsolUser -all

			Reset a password for a user at FakeCompany Limited:
			Get-MsolPartnerTenant Fakecompany | Set-MsolUserPassword -UserPrincipalName Joe.Blogs@fakecompany.co.uk -NewPassword "C5uhatEr" -ForceChangePassword $false

			View licensing for every tenant:
			Get-MsolPartnerTenant | Get-MsolAccountSku



			.EXAMPLE
			Exports list to PartnerCompany AppData Folder.

			To TXT File:
			Get-MsolPartnerTenant -ExportToTxt
			Get-MsolPartnerTenant -Search Fa -ExportToTxt

			To CSV File:
			Get-MsolPartnerTenant -ExportToCsv
			Get-MsolPartnerTenant Fa -ExportToCsv


			.EXAMPLE
			Connects to customer's Exchange Online.

			Get-MsolPartnerTenant FakeCompany -ConnectToExchangeOnline
			Get-MsolPartnerTenant Fakecompany.co.uk -ConnectToExchangeOnline

            #>
			[CmdletBinding()]
			param
			(
				[parameter(Mandatory=$false,ValueFromPipeline=$true)][object[]]$InputObject,
				[parameter(Mandatory=$false, Position=0)][string]$Search,
				[parameter(Mandatory=$false)][switch]$ExportToCsv,
				[parameter(Mandatory=$false)][switch]$ExportToTxt,
				[parameter(Mandatory=$false)][switch]$ConnectToExchangeOnline

			)
			$ErrorActionPreference = "SilentlyContinue"
			$MSOLService = (Get-MsolPartnerInformation).PartnerCompanyName -like "*$PartnerCompanyName*"
			if (!$MSOLService)
			{
				$Hour = (Get-Date).Hour
				If ($Hour -lt 12)
				{
				    $greeting = "Good Morning $username"
				}
				ElseIf ($Hour -gt 16)
				{
				    $greeting = "Good Evening $username"
				}
				Else
				{
				    $greeting = "Good Afternoon $username"
				}
				$ConnectMessage = "$greeting. Please enter your $PartnerCompanyName credentials."
				do
				{
				    $stillblank = $false
					if ($Global:PartnerCompanyCred -eq $null)
					{
						$Global:PartnerCompanyCred = Get-Credential -Message "$ConnectMessage"
						if ($Global:PartnerCompanyCred -eq $null)
						{
						    $ConnectMessage = "You did not enter any credentials, please try again."
						    $attempt++

						}
						if ($attempt -eq 2)
						{
						    $stillblank = $true
						}
					}
					else
					{
						if ($Global:PartnerCompanyCred.Username -ilike "*@$PartnerCompanyDomain*")
						{

						}
						else
						{
							$ConnectMessage = "The credentials you had cached were not valid, please enter your $PartnerCompanyName credentials."
							$Global:PartnerCompanyCred = $null
						}
					}


				} while (($Global:PartnerCompanyCred -eq $null) -and ($stillblank -eq $false))
				if ($stillblank -eq $true)
				{
					$ErrorActionPreference = "Continue"
				    Write-Error "Credentials are null."
					Break
				}
				if ($stillblank -eq $false)
				{

					$ErrorActionPreference = "SilentlyContinue"
					Connect-MsolService -Credential $Global:PartnerCompanyCred
					$Login = $?
					if (!$Login)
					{
						$ErrorActionPreference = "Continue"
						Write-Error "Authentication Failed, please check your credentials."
						$Global:PartnerCompanyCred = $null
						Break
					}
					else
					{
						$CompanyName = (Get-MsolCompanyInformation).DisplayName
						if ($CompanyName -ne $null)
						{
						    Write-host " "
						    Write-host "Connected to $CompanyName."
						}
					}

				}
			}
			else
			{
			}
			if ($Login)
			{
				if (!$Search)
				{
					$Search = Write-Host "Specify keyword to filter results."
					$Search = Read-Host "Search"
				}
			}
			$MSOLTenants = Get-MsolPartnerContract | select *
			if ($Search -ne $null)
			{
				$MSOLTenants = $MSOLTenants | ? { $_ -like "*$Search*"}
			}
			else
			{
			}
			if ($ExportToCSV)
			{
				$MSOLTenants | Export-Csv $PSData\MSOLTenants.csv
				ii $PSData\MSOLTenants.csv
			}
			if ($ExportToTXT)
			{
				$MSOLTenants | Out-File $PSData\MSOLTenants.txt
				ii $PSData\MSOLTenants.txt
			}
			if ($InputObject -ne $null)
			{
				Write-Output $MSOLTenants $InputObject
			}
			else
			{
				Write-Output $MSOLTenants 
			}
			
			if ($MSOLTenants -eq $null)
			{
				Write-Error "No tenant matching your search was found."
			}
			if ($ConnectToExchangeOnline)
			{
				if ($MSOLTenants -eq $null)
				{
					$ErrorActionPreference = "Continue"
					Write-Error "Your search must return a tenant in order to connect to Exchange Online"
				}
				elseif ($MSOLTenants.TenantId.Count -eq 1)
				{
					try
					{
						Write-Host "Connecting..."  -ForegroundColor Yellow  
						Get-PSSession | Remove-PSSession
						$MSOLTenantName = $MSOLTenants.Name
						$MSOLTenantDefaultDomain = $MSOLTenants.DefaultDomainName
						$uri = "https://ps.outlook.com/powershell-liveid?DelegatedOrg="
						$ErrorActionPreference = "Continue"
						$PartnerCompanySession = New-PSSession -name "$MSOLTenantName Session" –ConfigurationName Microsoft.Exchange -WarningAction SilentlyContinue `
						-ConnectionUri $($uri+$MSOLTenantDefaultDomain) -Credential $Global:PartnerCompanyCred -Authentication Basic -AllowRedirection -ErrorAction SilentlyContinue
						$WarningPreference = "SilentlyContinue"
						Import-PSSession $PartnerCompanySession -AllowClobber | Out-Null
						Write-Host " "
						Write-Host "Connected to $MSOLTenantName's Exchange Online."
						Write-host " "
						$WarningPreference = "Continue"
					}
					catch
					{
						Write-Error "Authentication Failed, please check your credentials. You can also try clearing PSSession by running Get-PSSession | Remove PSSession."
					}
				}
				else
				{
					$ErrorActionPreference = "Continue"
					Write-Error "Your search returned too many results, please refine your query to Connect to Exchange Online."
				}
			}
			$ErrorActionPreference = "Continue"
		}
		New-Alias gpt Get-MsolPartnerTenant
		$Loaded += "Get-MsolPartnerTenant, "

		# CONNECT-MSOLPARTNEREXCHANGE
		function Connect-MsolPartnerExchange
		{
			<#
            .SYNOPSIS
            This will connect you to a customer's Exchange Online, using your own credentials.


            .DESCRIPTION
            Once you run Connect-MsolPartnerExchange followed by the tenant (or keyword), you will be asked to enter your own credentials. 


            There are two other commands, Backup-MsolUser & Backup-Mailbox which should be used before ANY changes are made to a user's details or configuration via PowerShell.
			
			ALIAS: cpe

			.PARAMETER Search
			Specify phrase to query against tenant names. Please make sure this is specific enough to only pick one tenant.



			.EXAMPLE
			Connect to FakeCompany Limited's Exchange Online:

			Connect-MsolPartnerExchange fakec 
			Connect-MsolPartnerExchange "FakeCompany Limited"
			Connect-MsolPartnerExchange -Search fakecompany.co.uk
			cpe fakec


            #>
			[CmdletBinding()]

			param
			(
				[parameter(Mandatory=$false,ValueFromPipeline=$true)][object[]]$InputObject,
				[parameter(Mandatory=$false, Position=0)][string]$Search
			)
			if ($InputObject)
			{
				if ($InputObject.TenantId)
				{
					$Search = $InputObject.TenantId
				}
				elseif ($InputObject.GetType().Name.Contains("String"))
				{
					$Search = $InputObject
				}
			}

			if ($Search)
			{
				Get-MsolPartnerTenant $Search -ConnectToExchangeOnline
			}
			else
			{
				Write-Error "Search is empty, please specify a keyword or provide pipeline input."
			}
		}
		New-Alias cpe Connect-MsolPartnerExchange
		$Loaded += "Connect-MsolPartnerExchange, "

        # BACKUP-MSOLUSER
        function Backup-MsolUser
		{
            <#
            .SYNOPSIS
            This cmdlet will backup all configurations of an Office 365 User Account, but NOT a mailbox.



            .DESCRIPTION
            The configurations and details of an Office 365 User Account are backed up to AppData.



            .EXAMPLE
            Backup-MsolUser -UserPrincipalname user@domain.com
            #>
            [CmdletBinding()]
            param
			(
				[parameter(Mandatory=$false,ValueFromPipeline=$true)][object[]]$InputObject,
				[parameter(Mandatory=$false, position=0)][string]$UserPrincipalName
            )
            #$ErrorActionPreference = "SilentlyContinue"
			if ($InputObject -ne $null)
			{
				$UserPrincipalName = $InputObject.UserPrincipalName

			}

			if ($UserPrincipalName -ne $null)
			{
				$MsolUser = Get-MsolUser -UserPrincipalName $UserPrincipalName | select *
			}
			else
			{
				$ErrorActionPreference = "Continue"
				Write-Error "The UserPrincipalName parameter cannot be null."
				Break
			}
			
            
            if ($MsolUser -ne $null)
			{
                $Filename = ($UserPrincipalName.Replace('@','-')).Replace('.','-')
                $Date = ((get-date).ToShortDateString()).Replace('/','-')
                $Time = ((get-date).ToShortTimeString()).Replace(':','-')
                $DateTime = $date+"-"+$time
                $MsolUser | Export-Clixml "$PSData\$DateTime-MsolUser-$Filename.xml"
                $MsolUser | Export-CSV "$PSData\$DateTime-MsolUser-$Filename.csv"
            }
            else
			{
                $ErrorActionPreference = "Continue"
                Write-Error "Could not retrieve the user `'$UserPrincipalName`', Please check you have used the correct UserPrincipalName and you that are connected to a tenant."
            }
			$ErrorActionPreference = "Continue"
        }
		$Loaded += "Backup-MsolUser, "

		# BACKUP-MAILBOX
        function Backup-Mailbox
		{
            <#
            .SYNOPSIS
            This will backup an Exchange Online Mailbox



            .DESCRIPTION
            The configurations and details of an Exchange Online Mailbox are backed up to AppData.



            .EXAMPLE
            Backup-Mailbox -Identity "Bob Smith"



            .EXAMPLE
            Backup-Mailbox -Identity BobS
            #>
            [CmdletBinding()]
            param
			(
				[parameter(Mandatory=$false,ValueFromPipeline=$true)][object[]]$InputObject,
				[parameter(Mandatory=$true, position=0)][string]$Identity
            )
            $ErrorActionPreference = "SilentlyContinue"
			if ($InputObject -ne $null)
			{
				$Identity = $InputObject.Identity
			}

			if ($Identity -ne $null)
			{
				$Mailbox = Get-Mailbox -Identity $Identity | select * -ErrorAction SilentlyContinue
			}
			else
			{
				$ErrorActionPreference = "Continue"
				Write-Error "The Identity parameter cannot be null."
				Break
			}
			
            if ($Mailbox -ne $null)
			{
                $Filename = $Mailbox.Alias
                $Date = ((get-date).ToShortDateString()).Replace('/','-')
                $Time = ((get-date).ToShortTimeString()).Replace(':','-')
                $DateTime = $date+"-"+$time
                $Mailbox | Export-Clixml "$PSData\$DateTime-Mailbox-$Filename.xml"
                $Mailbox | Export-CSV "$PSData\$DateTime-Mailbox-$Filename.csv"
            }
            if ($Mailbox -eq $null)
			{
                $ErrorActionPreference = "Continue"
                Write-Error "Could not retrieve the user `'$Identity`', Please check you have used the correct Identity and you that are connected to a tenant."
            }
			$ErrorActionPreference = "Continue"
        }
		$Loaded += "Backup-Mailbox"

		# Information Text
		Write-Host "Loaded: $Loaded" -ForegroundColor Gray
		Write-host "To connect directly to Office 365, please use the Connect-MsolTenant cmdlet. For delegated administration, use the Get-MsolPartnerTenant cmdlet. Use Get-Help (using the '-Full' switch) on the cmdlets for more information." -ForegroundColor Yellow
        Write-host " "
	}
    Catch
	{

    }
}
Catch
{
    Write-host "Office 365 Module could not be loaded, please check if Windows Azure Active Directory Module for Windows PowerShell is installed." -foregroundcolor Yellow
    Write-host " "
}

Start-Transcript "$PSdata\$(($env:USERNAME).replace('.',''))-$(((get-date).ToShortDateString()).Replace('/','-'))-$(((get-date).ToShortTimeString()).Replace(':','-'))-PSTranscript.log" -IncludeInvocationHeader | Out-Null