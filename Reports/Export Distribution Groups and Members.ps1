# AUTHOR: Steven Ayers

Foreach ($Group in Get-DistributionGroup)
{
    $MemberString = $null
    $MemberList = (Get-DistributionGroupMember $Group.Identity).DisplayName
    0..(($MemberList.Count) - 1) | % {
        $MemberString += $MemberList[$_]
        if ($_ -lt (($Memberlist.Count)-1))
        {
            $MemberString += ";"
        }
    }

    $props=@{
            "Group"=($Group.Name);
            "Members"=$MemberString
    }

    New-Object -TypeName PSObject -Property $props | Export-CSV $home\Desktop\Groups.csv -Append


}