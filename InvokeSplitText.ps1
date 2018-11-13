function Invoke-SplitText {
    param(
        [Parameter(Mandatory)]
        $File,
        [string[]]$Header,
        [System.Collections.Specialized.OrderedDictionary]$Constraints
    )

    function new-splitsession {
        new-object Microsoft.ProgramSynthesis.Split.Text.SplitSession $null, $null, $null
    }

    function new-datainput {
        param(
            [parameter(valuefrompipeline)]
            $s
        )

        process {
            [microsoft.programsynthesis.split.text.splitsession]::CreateStringRegion($s)
        }
    }

    $splitsession = new-splitsession

    $textitems = Get-Content $file | new-datainput
    $textitems | ForEach-Object {$splitsession.inputs.add($_)}

    $splitsession.constraints.Clear()
    $splitsession.constraints.add((New-Object Microsoft.ProgramSynthesis.Split.Text.IncludeDelimitersInOutput $false))

    foreach ($key in $constraints.Keys) {
        $entry = $constraints.$key

        for ($idx = 0; $idx -lt $entry.Count; $idx++) {
            $constraint = New-Object Microsoft.ProgramSynthesis.Split.Text.NthExampleConstraint -ArgumentList $splitsession.inputs.Wholeregion[$key].Value, $idx, $entry[$idx]
            $splitSession.constraints.Add($constraint)
        }

    }

    $program = $splitsession.Learn()

    if ($null -eq $program) {
        throw "no program learned"
    }

    $progText = $program.Serialize()

    $program = [Microsoft.ProgramSynthesis.Split.Text.SplitProgramLoader]::Instance.Load($progText)

    foreach ($record in $textitems) {
        $run = $program.Run($record)
        $count = $run.Count

        $h = [ordered]@{}

        foreach ($columnNumber in 1..$count) {
            $propertyName = "Col$columnNumber"
            if ($Header) {
                if ($columnNumber -le $Header.Count) {
                    $propertyName = $Header[$columnNumber - 1]
                }
            }

            $h.$propertyName = $run[($columnNumber - 1)].CellValue.Value
        }

        [pscustomobject]$h
    }
}