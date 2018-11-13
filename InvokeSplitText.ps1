function Invoke-SplitText {
    param(
        [Parameter(Mandatory)]
        $File,
        [string[]]$Header,
        [string[]]$Constraints
    )

    # Import-Module ..\PSProse.psm1 -Force

    function new-splitsession {
        new-object microsoft.programsynthesis.split.text.splitsession $null, $null, $null
    }

    function new-datainput {
        param(
            [parameter(valuefrompipeline)]
            $s
        )

        process {
            [microsoft.programsynthesis.split.text.splitsession]::createstringregion($s)
        }
    }

    $splitsession = new-splitsession

    $textitems = Get-Content $file | new-datainput

    $textitems | ForEach-Object {$splitsession.inputs.add($_)}

    $splitsession.constraints.Clear()
    $splitsession.constraints.add((New-Object Microsoft.ProgramSynthesis.Split.Text.IncludeDelimitersInOutput $false))

    for ($idx = 0; $idx -lt $constraints.count; $idx++) {
        $constraint = New-Object Microsoft.ProgramSynthesis.Split.Text.NthExampleConstraint -ArgumentList $splitsession.inputs[0].Value, $idx, $constraints[$idx]
        $splitSession.constraints.Add($constraint)
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
            if ($Header) {
                $propertyName = $Header[$columnNumber - 1]
            }
            else {
                $propertyName = "Col$columnNumber"
            }

            $h.$propertyName = $run[($columnNumber - 1)].CellValue.Value
        }

        [pscustomobject]$h
    }
}