# System Storage Monitoring Script

This PowerShell script monitors system drive storage usage, calculates total space, used space, and free space, and sends an HTML-formatted email with the summary. It also highlights drives where used space exceeds 80%.

## Features
- Retrieves storage statistics for all system drives.
- Displays total system storage, used space, free space, and their respective percentages.
- Sends an email with the storage summary and highlights drives with over 80% usage.
- HTML email body includes a table for easy viewing of drive statistics.
- Supports Gmail SMTP for email delivery (requires app password for Gmail authentication).

## Requirements
- PowerShell 5.1 or higher.
- A Gmail account with an app password for authentication.
- Internet access for sending the email.

## Script Execution

1. The script will retrieve storage information for all available system drives.
2. It will calculate total storage, used space, and free space in terabytes (TB).
3. The script generates an HTML email with a summary of the storage information.
4. If any drives have over 80% used space, they will be highlighted in the email.
5. The email will be sent to the configured recipient with the current timestamp.

## Configuration
- Update the email credentials in the script:
  - `$emailFrom`: Your Gmail address (sender).
  - `$emailTo`: The recipient's email address.
  - `$smtpPassword`: The Gmail app password.
- Modify the subject line for the email if needed.

## Sample Output

The email will contain a table with the following columns:
- Total Space (TB)
- Used Space (TB)
- Free Space (TB)
- Used Space Percentage
- Free Space Percentage

Additionally, drives with over 80% usage will be listed under a separate section with the drive letter and the usage percentage.

## Example of Email Body:

