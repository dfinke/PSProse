function Invoke-SplitText {
    param(
        [Parameter(Mandatory)]
        $File,
        [string[]]$Header,
        $Constraints,
        [Switch]$IncludeDelimitersInOutput
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
    # $splitsession.constraints.add((New-Object Microsoft.ProgramSynthesis.Split.Text.IncludeDelimitersInOutput $false))
    $splitsession.constraints.add((New-Object Microsoft.ProgramSynthesis.Split.Text.IncludeDelimitersInOutput $IncludeDelimitersInOutput))

    function Add-ProseConstraint {
        param(
            $index,
            $itemIndex,
            $value
        )

        $constraint = New-Object Microsoft.ProgramSynthesis.Split.Text.NthExampleConstraint -ArgumentList $splitsession.inputs.Wholeregion[$index].Value, $itemIndex, $value

        $splitSession.constraints.Add($constraint)
    }

    # Normalize constraints
    if ($Constraints -and $Constraints[0] -isnot [array]) {
        for ($idx = 0; $idx -lt $Constraints.Count; $idx++) {
            Add-ProseConstraint 0 $idx $Constraints[$idx]
        }
    }
    else {
        for ($idx = 0; $idx -lt $Constraints.Count; $idx++) {
            $currentConstraint = $Constraints[$idx]
            for ($itemIdx = 0; $itemIdx -lt $currentConstraint.Count; $itemIdx++) {
                Add-ProseConstraint  $idx $itemIdx $currentConstraint[$itemIdx]
            }
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