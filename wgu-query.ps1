<#
.SYNOPSIS
WGU Cert Lookup Query thingy
.DESCRIPTION
I dunno
.EXAMPLE
PS> .\wgu-query.ps1 -target example.com
Will perform a cert.sh lookup on example.com
.LINK
fill this in later dummy
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]$target
)
$ErrorActionPreference = "SilentlyContinue"
$baseURL = "https://crt.sh/?q="
$middleURL = $target
$endURL = "&output=json"
$fullURL = $baseURL + $middleURL + $endURL
$query = Invoke-WebRequest -URI $fullURL -UseBasicParsing
$results = $query.content | ConvertFrom-Json -Verbose 
$targets = @()
foreach ($result in $results) { 
    $curCommonName = $result.common_name
    $curNameValue = $result.name_value.split("`n`r")
  #  Write-Verbose "curCommonName = $curcommonName"
  #  Write-Verbose "curNameValue = $curNameValue"
    if ($curCommonName -notmatch "(.*[*].*$)|(.*[@].*)") {
        $targets += $curCommonName
        Write-Verbose "Adding curCommonName $curCommonName to target list"
    }
    foreach ($nameValue in $curNameValue) {
        if ($NameValue -notmatch "(.*[*].*$)|(.*[@].*)") {
            $targets += $NameValue
            Write-Verbose "Adding NameValue $NameValue to target list"
        }
    }
}
$domains = $targets | Select-Object -Unique
$validDomains = @()
foreach ($domain in $domains) {
    try {
        Write-Verbose "Attempting to Query $domain"
        $domainLookup = Invoke-WebRequest -Uri $domain -UseBasicParsing -Method Head
            if ($domainLookup.StatusCode -eq 200) {
                Write-Verbose "Attempt Successful"
                $validDomains += $domain
            }
            else {
                Write-Verbose "Host resolved successfully but returned statuscode $domainlookup.statuscode"
            }
    }
    catch {
        Write-Verbose "Query Failed for $domain :("
        #Yum!
    }
}
Write-Output "Successfully validated the following domains"
Write-Output "--------------------------------------------"
$validDomains | Format-Table