Import-Module $PSScriptRoot\..\PSProse.psd1 -Force

Describe "Test Invoke-SplitText" {
    BeforeEach {
        $file = "$PSScriptRoot\splitDataSample1.txt"
    }

    It "Should return three records with four columns" {
        $actual = Invoke-SplitText -file $file

        $actual.Count | Should Be 3
        $actual[0].psobject.properties.name.count | Should Be 4
    }

    It "Should have numbered column names" {
        $actual = Invoke-SplitText -file $file

        $propertyNames = $actual[0].psobject.properties.name
        $propertyNames[0] | Should Be "Col1"
        $propertyNames[1] | Should Be "Col2"
        $propertyNames[2] | Should Be "Col3"
        $propertyNames[3] | Should Be "Col4"
    }

    It "Propertynames should be the headers passed in" {

        $actual = Invoke-SplitText -file $file -Header 'ID', 'First', 'Last', 'Country'

        $propertyNames = $actual[0].psobject.properties.name

        $propertyNames[0] | Should Be "ID"
        $propertyNames[1] | Should Be "First"
        $propertyNames[2] | Should Be "Last"
        $propertyNames[3] | Should Be "Country"
    }

    It "Single constraint should yield different results" {
        $param = @{
            file        = $file
            Header      = 'ID', 'First', 'Last', 'Country'
            Constraints = [ordered]@{
                0 = 'pe5', 'leonard', 'robledo', 'australia'
            }
        }

        $actual = Invoke-SplitText @param

        $actual.Count | Should Be 3

        $actual[0].ID    | Should Be "pe5"
        $actual[0].First | Should Be "leonard"
        $actual[0].Last | Should Be "robledo"
        $actual[0].Country | Should Be "australia"
    }

    It "Multiple constraints should yield different results" {
        $param = @{
            file        = $file
            Header      = 'ID', 'First', 'Last', 'Country'
            Constraints = [ordered]@{
                0 = echo pe5 leonard robledo australia
                1 = echo u109 adam 'jay lucas' 'new zealand'
            }
        }

        $actual = Invoke-SplitText @param

        $actual.Count | Should Be 3

        $actual[0].ID    | Should Be "pe5"
        $actual[0].First | Should Be "leonard"
        $actual[0].Last | Should Be "robledo"
        $actual[0].Country | Should Be "australia"

        $actual[1].ID    | Should Be "u109"
        $actual[1].First | Should Be "adam"
        $actual[1].Last | Should Be "jay lucas"
        $actual[1].Country | Should Be "new zealand"
    }
}