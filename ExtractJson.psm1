Get-ChildItem $PSScriptRoot\lib | ForEach-Object {Add-Type -Path $_.FullName}

function New-JSONSession {
    New-Object Microsoft.ProgramSynthesis.Extraction.Json.Session $null, $null, $null
}

function Get-JSONData {
    param(
        $jsonFile
    )

    $jsonText = Get-Content $jsonFile -Raw

    $noJoinSession = New-JSONSession
    $noJoinSession.Inputs.Add($jsonText)
    $noJoinProgram = $noJoinSession.Learn()
    $table = $noJoinProgram.Run($jsonText)

    foreach ($row in $table) {$row -join ', '}
}
