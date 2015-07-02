function Exfil-Smtp
{ 
    [CmdletBinding()] Param(

        [Parameter(Position = 0, Mandatory = $true)]
        [String]
        $FromAddress,
        
        [Parameter(Position = 0, Mandatory = $true)]
        [String]
        $ToAddress,
        
        [Parameter(Position = 0, Mandatory = $false)]
        [String]
        $MailServer

    )

    # ------------------------------------------
    # Setup the SMTP server
    # ------------------------------------------
    if ($MailServer){

        write-host "Target SMTP server: $MailServer"  
    }else{

        # Grab SMTP server from default domain controll via ldap based on spn
        write-host "Searching for SMTP server..."
    
        $ObjDomain = [ADSI]""  
        $ObjSearcher = New-Object System.DirectoryServices.DirectorySearcher $ObjDomain
        $CurrentDomain = $ObjDomain.distinguishedName
        $ObjSearcher.PageSize = 1000
        $ObjSearcher.Filter = "(ServicePrincipalName=*SMTP*)"
        $ObjSearcher.SearchScope = "Subtree"

        # Get a count of the number of accounts that match the LDAP query
        $Records = $ObjSearcher.FindAll()
        $RecordCount = $Records.count

        # Display search results if results exist
        if ($RecordCount -gt 0)
        {
                
            # Create data table to house results
            $DataTable = New-Object System.Data.DataTable 
            $DataTable.Columns.Add("Account") | Out-Null
            $DataTable.Columns.Add("Server") | Out-Null
            $DataTable.Columns.Add("Service") | Out-Null            

            # Grab results                
            $ObjSearcher.FindAll() | ForEach-Object {

                # Add records to data table
                foreach ($item in $_.properties['ServicePrincipalName']){
                    $SpnServer =  $item.split("/")[1].split(":")[0]	
                    $SpnService =  $item.split("/")[0]                                                    
                    $DataTable.Rows.Add($($_.properties.samaccountname), $SpnServer, $SpnService) | Out-Null  
                }
    
                # Display results in list view that can feed into the pipeline
                $MailServer  = $DataTable |  select server -First 1 -ExpandProperty server
            }
        } 
    }

    # Status user
    if ($MailServer){
        write-host "Found SMTP server: $MailServer"    
    }else{
        write-host "No SMTP server found or provided."   
    }


    # ------------------------------------------
    # Send test emails
    # ------------------------------------------

    if ($MailServer){

        # Set the mail server for use
        $smtp = New-Object Net.Mail.SmtpClient("$MailServer")

        write-host "Sending test emails..."

        # Send emails containing sample cc and ssn
        $smtp.Send("$FromAddress","$ToAddress","Test Email - SSN 1","123-45-6789")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - SSN 2","123.45.6789")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - SSN 3","123456789")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Amex 1","American Express 378282246310005")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Amex 2","American Express 371449635398431")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Amex 3","American Express Corporate 378734493671000")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Austr 1","Australian BankCard 5610591081018250")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Diners 1","Diners Club 30569309025904")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Diners 2","Diners Club 38520000023237")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Disco 1","Discover 6011111111111110")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Disco 2","Discover 6011000990139420")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card JCB 1","JCB 3530111333300000")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card JCB 2","JCB 3566002020360500")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card JCB 2","JCB 3566002020360500")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Master 1","MasterCard 5555555555554440")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Master 2","MasterCard 5105105105105100")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Maestro 1","Maestro 6799990100000000019")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Visa 1","Visa 4111111111111110")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Visa 2","Visa 4012888888881880")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Visa 3","Visa 4222222222222")
        $smtp.Send("$FromAddress","$ToAddress","Test Email - Credit Card Visa Deb 1","Visa Debit 4917610000000000003")
        write-host "Done."
    }
}