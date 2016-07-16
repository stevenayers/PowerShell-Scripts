function Get-AzureRmVMIP {
    $vms = Get-AzureRMVM
    $ReturnObject = @()
    $vmcount = 0
    foreach ($vm in $vms)
    {
        Write-Progress -PercentComplete (($vmcount / $vms.Count) * 100) -Activity "Gathering Public IP Addresses..." -Status "$($vm.Name)..."

        $IPConfig = (Get-AzureRmNetworkInterface | ? { $_.Id -eq $vm.NetworkInterfaceIDs}).IpConfigurations


        $ReturnObject +=  New-Object -TypeName PSObject -Property @{
            Name=$vm.Name;
            PublicIPAddress=(Get-AzureRmPublicIpAddress | ? { $_.Id -eq $IPConfig.PublicIPAddress.Id}).IpAddress;
            PrivateIPAddress=$IPConfig.PrivateIPAddress
            } | Write-Output

        $vmcount++
    }

    return $ReturnObject
}