# Get drive information
$Diskmgmt = Get-Volume | Select DriveLetter, SizeRemaining, Size

# Initialize totals
$TotalSize = 0
$TotalUsed = 0
$TotalFree = 0

# Loop through drives to calculate totals
foreach ($dsk in $Diskmgmt) {
    if ($dsk.DriveLetter) {
        $TotalSize += $dsk.Size
        $TotalFree += $dsk.SizeRemaining
    }
}

# Calculate system-level totals
$TotalUsed = $TotalSize - $TotalFree
$UsedPercentage = [math]::round(($TotalUsed / $TotalSize) * 100, 2)
$FreePercentage = [math]::round(($TotalFree / $TotalSize) * 100, 2)
$TotalSizeTB = [math]::round($TotalSize / 1TB, 2)
$TotalUsedTB = [math]::round($TotalUsed / 1TB, 2)
$TotalFreeTB = [math]::round($TotalFree / 1TB, 2)

# Generate HTML for the email body
$TableRows = @"
<tr>
    <td>$TotalSizeTB</td>
    <td>$TotalUsedTB</td>
    <td>$TotalFreeTB</td>
    <td>$UsedPercentage%</td>
    <td>$FreePercentage%</td>
</tr>
"@

# Generate the second section (only disks with used space greater than 80%)
$DiskRows = ""
foreach ($dsk in $Diskmgmt) {
    if ($dsk.DriveLetter) {
        $UsedSpacePercentage = [math]::round((($dsk.Size - $dsk.SizeRemaining) / $dsk.Size) * 100, 2)
        
        # Only include drives with used space greater than 80%
        if ($UsedSpacePercentage -gt 80) {
            $DiskRows += "<b>$($dsk.DriveLetter): $UsedSpacePercentage%</b><br>"
        }
    }
}

# Get current date and time
$DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$EmailDateTime = Get-Date -Format "yyyy-MM-dd HH:mm"

# Construct email HTML body
$emailBody = @"
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; }
        h3 { color: #333; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h4>Total System Space Stats:</h4>
    <table>
        <thead>
            <tr>
                <th>Total Space (TB)</th>
                <th>Used Space (TB)</th>
                <th>Free Space (TB)</th>
                <th>Used Space %</th>
                <th>Free Space %</th>
            </tr>
        </thead>
        <tbody>
            $TableRows
        </tbody>
    </table>
    <h4>Drives Used Space in Percentage (Greater than 80%):</h4>
    <p>$DiskRows</p>
</body>
</html>
"@

# Email configuration (Replace placeholders with actual values)
$emailFrom = "<your-email>@gmail.com"   # Replace with your email
$emailTo = "<recipient-email>@domain.com"     # Replace with recipient's email
$subject = "Production Machine Storage Stats ($EmailDateTime)"
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$smtpUser = "<your-email>@gmail.com"    # Replace with your email
$smtpPassword = "<your-app-password>"      # Replace with your app password

# Secure the password
$securePassword = ConvertTo-SecureString $smtpPassword -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($smtpUser, $securePassword)

# Sending email using .NET SmtpClient
try {
    $smtp = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.EnableSsl = $True
    $smtp.Credentials = $credentials

    $mailMessage = New-Object System.Net.Mail.MailMessage
    $mailMessage.From = $emailFrom
    $mailMessage.To.Add($emailTo)
    $mailMessage.Subject = $subject
    $mailMessage.IsBodyHtml = $true
    $mailMessage.Body = $emailBody

    $smtp.Send($mailMessage)
    Write-Host "Email sent successfully to $emailTo"
} catch {
    Write-Host "Failed to send email: $_"
}

# Display data on the console for verification
Write-Host "`n--- Total System Space (System Storage) ---"
Write-Host "Total Space (TB): $TotalSizeTB"
Write-Host "Used Space (TB): $TotalUsedTB"
Write-Host "Free Space (TB): $TotalFreeTB"
Write-Host "Used Space %: $UsedPercentage%"
Write-Host "Free Space %: $FreePercentage%"

Write-Host "`n--- Drives Used Space in Percentage (Greater than 80%) ---"
$Diskmgmt | Where-Object { $_.DriveLetter } | ForEach-Object {
    $UsedSpacePercentage = [math]::round(($_.Size - $_.SizeRemaining) / $_.Size * 100, 2)
    if ($UsedSpacePercentage -gt 80) {
        Write-Host "$($_.DriveLetter): $UsedSpacePercentage%" -ForegroundColor Red
    }
}
