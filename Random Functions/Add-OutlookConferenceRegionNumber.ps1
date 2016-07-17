function Add-OutlookConferenceRegionNumber {

[CmdletBinding()]
param (
    [parameter(Mandatory=$true)][string]$DomainName,
    [parameter(Mandatory=$true)][string]$SIPAddress,
    [parameter(Mandatory=$true)]
    [ValidateSet(
        "United_Kingdom",
        "Switzerland",
        "Sweden",
        "Hong_Kong",
        "Ireland",
        "Belgium",
        "Australia",
        "Canada",
        "Japan",
        "France",
        "Isreal",
        "Denmark",
        "Czech_Republic",
        "United_States",
        "United_Kingdom_Local",
        "Germany",
        "Italy",
        "Brazil",
        "Mexico",
        "Singapore",
        "Spain",
        "Netherlands",
        "Portugal",
        "South_Africa"
    )][string]$Country
)
    $FormatEnumerationLimit =-1
    $PSData = "$env:APPDATA\PSLogs"
    If (!(Test-Path $PSData))
    {
        md $PSData | Out-Null 
    }
    $LogPath = "$PSdata\ConfigConf-$(($env:USERNAME).replace('.',''))-$(((get-date).ToShortDateString()).Replace('/','-'))-$(((get-date).ToShortTimeString()).Replace(':','-')).log"
    "$((Get-Date).ToShortTimeString()): Config Started." >> $LogPath

    if ($DomainName.Contains('@'))
    {
        $Region = "$(($Country.Replace("_"," ")).Replace("Local","(Local)"))"
        "$((Get-Date).ToShortTimeString()): Region - $Region" >> $LogPath
        $UPN = $env:USERNAME + $DomainName
        "$((Get-Date).ToShortTimeString()): Username - $UPN" >> $LogPath
        $KeyPath = "HKCU:\SOFTWARE\Microsoft\Office\15.0\Lync\ConfAddin\$UPN"
        "$((Get-Date).ToShortTimeString()): Key Path - $KeyPath" >> $LogPath
        if (Test-Path $KeyPath)
        {
            $key1= @{
                "Name"='InbandInfo';
                "Value"='<Inband><ACPs/><MaxMeetingSize>250</MaxMeetingSize><AudioEnabled>true</AudioEnabled><EnableEnterpriseCustomizedHelp>false</EnableEnterpriseCustomizedHelp><CustomizedHelpUrl></CustomizedHelpUrl><EnableAddinActionForLyncResources>false</EnableAddinActionForLyncResources></Inband>';
                "Path"=$KeyPath
            }
            $key1 >> $LogPath
            $key2= @{
                "Name"='Capabilities';
                "Value"='<Capabilities><CAAEnabled>true</CAAEnabled><AnonymousAllowed>true</AnonymousAllowed><AudioPresentationModeAllowed>true</AudioPresentationModeAllowed><VideoPresentationModeAllowed>true</VideoPresentationModeAllowed><PublicMeetingLimit>1</PublicMeetingLimit><PublicMeetingDefault>true</PublicMeetingDefault><AutoPromoteAllowed>Everyone</AutoPromoteAllowed><DefaultAutoPromote>Company</DefaultAutoPromote><BypassLobbyEnabled>true</BypassLobbyEnabled><ForgetPinUrl>https://dialin.unifiedcaas.net/dialin</ForgetPinUrl><LocalPhoneUrl>https://dialin.unifiedcaas.net/dialin</LocalPhoneUrl><DefaultAnnouncementEnabled>true</DefaultAnnouncementEnabled><ACPMCUEnabled>false</ACPMCUEnabled><Regions><Region Name="United Kingdom"><AccessNumber Number="0871 402 0577" LanguageID="2057"/></Region><Region Name="Switzerland"><AccessNumber Number="+41 315 281 053" LanguageID="2057"/></Region><Region Name="Sweden"><AccessNumber Number="+46 101 388 697" LanguageID="2057"/></Region><Region Name="Hong Kong"><AccessNumber Number="+852 5808 8881" LanguageID="2057"/></Region><Region Name="Ireland"><AccessNumber Number="+353 76 680 5886" LanguageID="2057"/></Region><Region Name="Belgium"><AccessNumber Number="+32 28 081 135" LanguageID="2057"/><AccessNumber Number="+32 78 48 11 88" LanguageID="2057"/></Region><Region Name="Australia"><AccessNumber Number="+61 380 015 020" LanguageID="3081"/></Region><Region Name="Canada"><AccessNumber Number="+1 (647) 557-5494" LanguageID="1033"/></Region><Region Name="Japan"><AccessNumber Number="+81 3-4588-8039" LanguageID="2057"/></Region><Region Name="France"><AccessNumber Number="+33 644 600 614" LanguageID="2057"/></Region><Region Name="Isreal"><AccessNumber Number="+972 2-372-1487" LanguageID="2057"/></Region><Region Name="Denmark"><AccessNumber Number="+45 89 88 24 89" LanguageID="2057"/></Region><Region Name="Czech Republic"><AccessNumber Number="+420 228 883 305" LanguageID="2057"/></Region><Region Name="United States"><AccessNumber Number="+1 425 698 2359" LanguageID="1033"/><AccessNumber Number="+1 (646) 392-8252" LanguageID="1033"/><AccessNumber Number="+1 (408) 389-2989" LanguageID="1033"/></Region><Region Name="United Kingdom (Local)"><AccessNumber Number="+44 20 7871 2876" LanguageID="2057"/></Region><Region Name="Germany"><AccessNumber Number="+49 322 2109 5837" LanguageID="2057"/></Region><Region Name="Italy"><AccessNumber Number="+39 0694 801 837" LanguageID="2057"/></Region><Region Name="Brazil"><AccessNumber Number="+55 11 3500 5955" LanguageID="2057"/></Region><Region Name="Mexico"><AccessNumber Number="+52 5511 689 879" LanguageID="2057"/></Region><Region Name="Singapore"><AccessNumber Number="+65 31 589 170" LanguageID="2057"/></Region><Region Name="Spain"><AccessNumber Number="+34 911 982 867" LanguageID="2057"/></Region><Region Name="Netherlands"><AccessNumber Number="+31 858 889 844" LanguageID="2057"/></Region><Region Name="Portugal"><AccessNumber Number="+351 308 80 40 80" LanguageID="2057"/></Region><Region Name="South Africa"><AccessNumber Number="+27 875 509 9989" LanguageID="2057"/></Region></Regions><custom-invite><help-url/><logo-url/><legal-url/><footer-text/></custom-invite></Capabilities>';
                "Path"=$KeyPath
            }
            $key2 >> $LogPath
            $key3= @{
                "Name"='PublicMeeting';
                "Value"='<Settings Version="14.0"><Public>false</Public><ConferenceID>WFVPZPDP</ConferenceID><HttpJoinLink>https://meet.unifiedcaas.net/atcgggm32wz/steven.ayers/WFVPZPDP</HttpJoinLink><ConfJoinLink>conf:sip:$SIPAddress;gruu;opaque=app:conf:focus:id:WFVPZPDP?conversation-id=9kw1xWVS74nP</ConfJoinLink><Subject/><ExpiryDate>00:00:00</ExpiryDate><AutoPromote OrganizerOnly="false" Value="Company"/><BodyLanguage>1033</BodyLanguage><Participants><Attendees/><Presenters/></Participants><Permissions><AdmissionType>ucOpenAuthenticated</AdmissionType></Permissions><MeetingOwner Smtp="" Sip=""/><IMDisabled>false</IMDisabled><AudioMuteEnabled>false</AudioMuteEnabled><VideoMuteEnabled>false</VideoMuteEnabled><Audio Type="caa" AudioModalityEnabled="true"><CAA><pstnId>623494</pstnId><region name="United Kingdom"/><BypassLobby>true</BypassLobby><AnnouncementEnabled>false</AnnouncementEnabled></CAA></Audio></Settings>';
                "Path"=$KeyPath
            }
            $key3 >> $LogPath
            $key4= @{
                "Name"='UserSetting';
                "Value"=(('<UserSettings Version="14.0"><IsPublicMeeting>true</IsPublicMeeting><IsEnglish>true</IsEnglish><CAA><SelectedCAARegion>[LOCATION]</SelectedCAARegion><DefaultCAARegion>United Kingdom</DefaultCAARegion></CAA></UserSettings>').Replace('[LOCATION]',$Region));
                "Path"=$KeyPath
            }
            $key4 >> $LogPath

            New-ItemProperty @key1 -Force
            $key1? = $?
            New-ItemProperty @key2 -Force
            $key2? = $?
            New-ItemProperty @key3 -Force
            $key3? = $?
            New-ItemProperty @key4 -Force
            $key4? = $?

            if ($key1? -and $key2? -and $key3? -and $key4?)
            {
                "$((Get-Date).ToShortTimeString()): All keys applied" >> $LogPath
            }
            else
            {
                "$((Get-Date).ToShortTimeString()): One or more keys could not be applied, please check registry." >> $LogPath
            } 
        }
        else
        {
            "$((Get-Date).ToShortTimeString()): Path doesn't exist - either the user hasn't used Skype for Business or `$(`$env:USERNAME + `"$DomainName`") is not their Primary SMTP Address, in which case, please change the script or amend the parameter input." >> $LogPath
        }

    }
    else
    {
        "$((Get-Date).ToShortTimeString()): DomainName must include '@' sign. ie: @contoso.com" >> $LogPath
    }
    


}


