Import-Module $PSScriptRoot\..\PSProse.psm1 -Force

$params = @{
    File        = "$PSScriptRoot\splitDataSample1.txt"
    Constraints = $(
        "pe5", 'leonard', 'robledo', 'australia'
    )

    Header      = 'ID', 'First', 'Last', 'Country'
}

Invoke-SplitText @params