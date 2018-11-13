Import-Module $PSScriptRoot\..\PSProse.psm1 -Force

$params = @{
    File        = "$PSScriptRoot\splitDataSample1.txt"
    Constraints = $(
        "pe5", 'leonard', 'robledo', 'australia'
        # "u109", 'adam', 'jay lucas', 'new zealand'
    )
}

Invoke-SplitText @params