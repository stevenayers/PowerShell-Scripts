foreach ($Mailbox in (Get-Mailbox)) {
    
     $DisplayName = $Mailbox.DisplayName
     $Primary = $Mailbox.PrimarySMTPAddress
     $ArchiveSize = (Get-MailboxStatistics $Primary -Archive | select -ExpandProperty TotalItemSize)
     $MBSize = (Get-MailboxStatistics $Primary | select -ExpandProperty TotalItemSize)

     $Props=@{

     "Display Name"=$DisplayName
     "Primary"=$Primary
     "Archive Size"=$ArchiveSize
     "Mailbox Size"=$MBSize

     }

     $Props | Export-CSV Info.csv -Append
}