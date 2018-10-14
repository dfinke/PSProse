Import-Module $PSScriptRoot\..\PSProse.psd1 -Force

Describe "Get JSON using Microsoft ProgramSynthesis Extraction" {
    BeforeEach {
        [string]$script:actual = Get-JSONData $PSScriptRoot\people.json
    }

    It "Should return a string" {
        $actual | Should Not BeNullorEmpty
    }

    It "Should start with 'Carrie, Dodson'" {
        $actual.StartsWith("Carrie, Dodson") | Should Be $true
    }
}