# param(
#     [Switch]$DontCreateZip
# )

$PSVersionTable.PSVersion

# if (!$DontCreateZip) {
#     $dest = "ImportExcel-{0}-{1}.zip" -f $ModuleVersion, (Get-Date).ToString("yyyyMMddHHmmss")
#     Compress-Archive -Path . -DestinationPath .\$dest
# }

if ($null -eq (Get-Module -ListAvailable pester)) {
    Install-Module -Name Pester -Repository PSGallery -Force -Scope CurrentUser
}

$result = Invoke-Pester -Script $PSScriptRoot\__tests__ -Verbose -PassThru

if ($result.FailedCount -gt 0) {
    throw "$($result.FailedCount) tests failed."
}