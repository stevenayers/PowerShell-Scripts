$Credential = Get-Credential
$i = "234"
$ResourceGroupName = "dsclinuxgroup$i"
$AccountName = "Autodsc$i"
$DomainNamePrefix = "dscbase$i"
$ResourceLocation = 'West Europe'
$VirtualMachineScaleSetName = "bl$i"
$InstanceCount = 2

New-AzureRmResourcegroup -Name $ResourceGroupName -Location 'West Europe' -Verbose

New-AzureRMAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AccountName -Location 'West Europe' -Plan Free -Verbose

$RegistrationInfo = Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $ResourceGroupName -AutomationAccountName $AccountName
$jid = ([system.guid]::newguid().guid).ToString()
$RegKey = $RegistrationInfo.PrimaryKey | ConvertTo-SecureString -AsPlainText -Force

#############
$Params=@{

    "registrationKey"=$RegistrationInfo.PrimaryKey;
    "registrationUrl"=$RegistrationInfo.Endpoint;
    "automationAccountName"=$AccountName;
    "jobid"=$jid;
    "adminUsername"=$credential.UserName;
    "adminPassword"=$credential.Password;
    "domainNamePrefix"=$DomainNamePrefix;
    "resourceLocation"=$ResourceLocation;
    "vmssName"=$VirtualMachineScaleSetName;
    "instanceCount"=$InstanceCount;
    "timestamp"=((get-date).getdatetimeformats()[80]);

}

New-AzureRmResourceGroupDeployment  -Name TestDeployment1 `
                                    -ResourceGroupName $ResourceGroupName `
                                    -TemplateFile "$PSScriptRoot\azuredeploy.json" `
                                    -TemplateParameterObject $Params `
                                    -Verbose