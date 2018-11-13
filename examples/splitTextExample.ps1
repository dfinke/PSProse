param(
    [Parameter(Mandatory)]
    $file,
    [string[]]$contraints
)

Import-Module ..\PSProse.psm1 -Force

#get-childitem .\lib45 | foreach-object {add-type -path $_.fullname}

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

#$text = @"
#pe5 leonard robledo (australia)
#u109 adam jay lucas (new zealand)
#r342 carrie dodson (united states)
#"@

#$text = @"
#doug finke a b c
#john doe a b c
#jane doe a b c
#"@

#$text = @"
#7/8/18 [info] - Hello World
#7/8/18 [debug] - Goodbye World
#"@

## Apache Extended Log File Format
#$text = @"
#111.222.333.123 HOME - [01/Feb/1998:01:08:39 -0800] "GET /bannerad/ad.htm HTTP/1.0" 200 198 "http://www.referrer.com/bannerad/ba_intro.htm" "Mozilla/4.01 (Macintosh; I; PPC)"
#111.222.333.123 HOME - [01/Feb/1998:01:08:46 -0800] "GET /bannerad/ad.htm HTTP/1.0" 200 28083 "http://www.referrer.com/bannerad/ba_intro.htm" "Mozilla/4.01 (Macintosh; I; PPC)"
#111.222.333.123 AWAY - [01/Feb/1998:01:08:53 -0800] "GET /bannerad/ad7.gif HTTP/1.0" 200 9332 "http://www.referrer.com/bannerad/ba_ad.htm" "Mozilla/4.01 (Macintosh; I; PPC)"
#111.222.333.123 AWAY - [01/Feb/1998:01:09:14 -0800] "GET /bannerad/click.htm HTTP/1.0" 200 207 "http://www.referrer.com/bannerad/menu.htm" "Mozilla/4.01 (Macintosh; I; PPC)"
#"@

#$text = @'
#function Log-Item {$a=1}
#function New-Item {$b=2}
#function Set-Item {$c=3}
#'@

#$textitems = $text -split "`r`n" | new-datainput

$textitems = Get-Content $file | new-datainput

#$splitsession.inputs.add($textitems)

$textitems | ForEach-Object {$splitsession.inputs.add($_)}

$splitsession.constraints.Clear()
$splitsession.constraints.add((New-Object Microsoft.ProgramSynthesis.Split.Text.IncludeDelimitersInOutput $false))

#New-Object Microsoft.ProgramSynthesis.Split.Text.NthExampleConstraint -ArgumentList $splitsession.inputs[0].Value,0,"PE5"

#$null = New-Object Microsoft.ProgramSynthesis.Split.Text.NthExampleConstraint -ArgumentList $splitsession.inputs[0].Value, 0, "pe5"

#$splitSession.constraints.Add((New-Object Microsoft.ProgramSynthesis.Split.Text.NthExampleConstraint -ArgumentList $splitsession.inputs[0].Value, 0, "pe5"));

#for ($idx = 0; $i -lt $contraints.count; $idx++) {

# New-Object Microsoft.ProgramSynthesis.Split.Text.NthExampleConstraint -ArgumentList $splitsession.inputs[0].Value, 0, "pe5"

#$constraint = New-Object Microsoft.ProgramSynthesis.Split.Text.NthExampleConstraint -ArgumentList $splitsession.inputs[0].Value, $idx, $contraints[$idx]
#$splitSession.constraints.Add($contraint)
#}

# splitSession.Constraints.Add(new NthExampleConstraint(inputs[0].Value, 0, "PE5"));
# splitSession.Constraints.Add(new NthExampleConstraint(inputs[0].Value, 1, "Leonard"));
# splitSession.Constraints.Add(new NthExampleConstraint(inputs[0].Value, 2, "Robledo"));
# splitSession.Constraints.Add(new NthExampleConstraint(inputs[0].Value, 3, "Australia"));
# splitSession.Constraints.Add(new NthExampleConstraint(inputs[1].Value, 0, "U109"));
# splitSession.Constraints.Add(new NthExampleConstraint(inputs[1].Value, 1, "Adam"));
# splitSession.Constraints.Add(new NthExampleConstraint(inputs[1].Value, 2, "Jay Lucas"));
# splitSession.Constraints.Add(new NthExampleConstraint(inputs[1].Value, 3, "New Zealand"));

$program = $splitsession.Learn()

if ($null -eq $program) {
    throw "no program learned"
}

$progText = $program.Serialize()

$program = [Microsoft.ProgramSynthesis.Split.Text.SplitProgramLoader]::Instance.Load($progText)

$textitems | ForEach-Object {

    $run = $program.Run($_)
    $count = $run.Count
    $h = [ordered]@{}
    1..$count | ForEach-Object {
        $h."Col$_" = $run[($_ - 1)].CellValue.Value
    }
    [pscustomobject]$h
}