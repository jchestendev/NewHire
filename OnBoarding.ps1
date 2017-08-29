# NewHire
Script for OnBoarding
<#
.NOTES
=============================================================
###########################################
#                                         #
#             Chesten Jones               #
#                Jan2017                  #
#                                         #
###########################################

.DESCRIPTION
==============================================================
This script is for the purpose of on-boarding users
 
The script does the following;

1. Creates User Remote Mailbox on Server
2. Updates the specified user account
3. Creates Home Directory
4. Adds User to the correct Groups

#Will take a while for the mailbox to populate in O365 admin (this is due to the 30min dirsync process between AD and O365)
#After running script, please remember to check 0365 Admin to add mailbox features

#The data in this script is pulled from a CSV(Comma Delimited) file

#>
$Users = Import-Csv -Path "C:/Users\UserAdmin\Desktop\NewHire.csv"  
$c = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://Server.Domain/powershell -Credential $c -Authentication Kerberos -AllowRedirection
Import-PSSession $Session

foreach ($User in $Users) {

	$Department = $User.DepartmentName
	$Displayname = $User.Firstname + " " + $User.Surname   
	$Password = $User.Password
	$SecurePass = $Password | ConvertTo-SecureString -AsPlainText -Force
	$UserLastname = $User.Surname             
	$UserFirstname = $User.Firstname 
    $SAM = $UserFirstname.substring(0,1).tolower()+$UserFirstname.substring(1).tolower()+"."+$UserLastname.substring(0,1).tolower()+$UserLastname.substring(1).tolower()
    $Email = $SAM + "@companyname.com"
    $Office = $User.Location
    $Title = $User.TitleDescription
	$Company = "Company"
	$Manager = $User.ManagerID
	$OfficePhone = $User.Telephone
	$Website = "Website"
	$HomeDirectory = "Home Drive Path"


	
	#Test Username
$ErrorCheck = get-aduser $SAM
if($ErrorCheck -ne $null){
	Write-Host "The USERNAME is already in use! Script has been halted, please restart and try again" -foregroundcolor "Red"
	write-host $ErrorCheck
	exit
}


$ErrorCheck = $null #We have to null it because if we reassign to $ErrorCheck and Powershell returns an error $ErrorCheck keeps it's value

#Test Email
$ErrorEmail = "*" + $SAM + "*"
$ErrorCheck = get-remotemailbox -filter "emailaddresses -eq '$SAM'"
if($ErrorCheck -ne $null){
	Write-Host "The email is already in use! Script has been halted, please restart and try again" -foregroundcolor "Red"
	write-host $ErrorCheck
	exit
}
$ErrorCheck = $null


#Creating a string to pass to the OU parameter
if ($Office -eq "Location")
{
	$SGLoc = "SecurityGroup"
}
elseif($Office -eq "Location2")
{
	$SGLoc = "SecurityGroup"
}
else
{
	$null
}


$OU = "domain/" + $Office + "/DEPARTMENTS/" + $Department

write-host ****************" Username Available, Creating $Displayname Mailbox"**************** -foregroundcolor "DarkYellow"
write-host " "

#Remote mailbox creation
new-remotemailbox -name $Displayname -onpremisesorganizationalunit $OU -userprincipalname $Email -firstname $UserFirstname -lastname $UserLastname -Initials "" -password $SecurePass -resetpasswordonnextlogon $false

#Preparing String for emails
$SIP = $SAM + "@company.com"
$SMTP = $SAM + "@company.com"

#Adding SIP and SMTP emails
set-remotemailbox $SAM -emailaddresspolicyenabled $false
set-remotemailbox $SAM -emailaddresspolicyenabled $true



	sleep -Seconds 10


import-module ActiveDirectory

        write-host ****************"Updating $Displayname Details"**************** -foregroundcolor "Green"
        write-host " "

		New-Item -ItemType Directory -path $HomeDirectory

	
		$userupdate = Get-ADUser $SAM -Properties Department, Title, Office, Manager, OfficePhone, Homepage, Company
		$userupdate.Department = $Department
		$userupdate.Title = $User.TitleDescription
		$userupdate.Office = $User.Location
		$userupdate.Manager = $User.ManagerID
		$userupdate.OfficePhone = $User.Telephone
		$userupdate.Homepage = "Website"
		$userupdate.Company = "Company"



		Set-ADUser $SAM -Department $userupdate.Department -Title $userupdate.Title -Office $userupdate.Office -Manager $userupdate.Manager -OfficePhone $userupdate.OfficePhone -Homepage $userupdate.HomePage -Company $userupdate.Company
		
		#Add AD Groups
		Add-ADGroupMember -Identity SG-ALL -Members $SAM
		write-host ****************"Adding SG-ALL to AD Group"**************** -foregroundcolor "DarkYellow"
			sleep -Seconds 3


$newhire = Get-ADUser $SAM | select -ExpandProperty DistinguishedName	
$newhire | Set-ADUser -HomeDrive "H" -HomeDirectory $HomeDirectory
		    
write-host "Updating is Complete For $Displayname" -foregroundcolor "Green"

}

Remove-PSSession $Session
