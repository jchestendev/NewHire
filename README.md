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
