param(
    [Parameter(Mandatory)]
    $targetFile
)

Import-Module $PSSCriptRoot\PSProse.psm1 -Force

Add-Type -AssemblyName presentationframework

$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        WindowStartupLocation="CenterScreen"
        Title="Split Text Buddy" Height="650" Width="850">

    <Grid>

        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>

        <Grid.RowDefinitions>
            <RowDefinition Height="42"/>
            <RowDefinition/>
            <RowDefinition/>
            <RowDefinition/>
        </Grid.RowDefinitions>

        <StackPanel Orientation="Horizontal" Grid.Column="0" Grid.Row="0" Margin="3">
            <Button x:Name="btnSelectFile" Content=" Select File " Margin="3" Width="Auto" HorizontalAlignment="Left"/>
        </StackPanel>

        <GroupBox Header=" File Contents " Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" Margin="3">
            <TextBox x:Name="tbFileContents" Margin="3"
                IsReadOnly="True"
                FontFamily="Consolas"
                FontSize="14"
                VerticalScrollBarVisibility="Visible"
                HorizontalScrollBarVisibility="Visible"/>
        </GroupBox>

        <GroupBox Header=" Examples " Grid.Row="2" Grid.Column="0" Margin="3">
            <TextBox x:Name="tbExamples" Margin="3"
                FontFamily="Consolas"
                FontSize="14"
                AcceptsReturn="True"
                VerticalScrollBarVisibility="Visible"
                HorizontalScrollBarVisibility="Visible"/>
        </GroupBox>

        <GroupBox Header=" Headers " Grid.Row="2" Grid.Column="1" Margin="3">
            <TextBox x:Name="tbHeaders" Margin="3"
                FontFamily="Consolas"
                FontSize="14"
                AcceptsReturn="True"
                VerticalScrollBarVisibility="Visible"
                HorizontalScrollBarVisibility="Visible"/>
        </GroupBox>

        <GroupBox Header=" Parsed Results " Grid.Row="3" Grid.Column="0" Grid.ColumnSpan="2" Margin="3">
            <TextBox x:Name="tbParsedResults" Margin="3"
                IsReadOnly="True"
                FontFamily="Consolas"
                FontSize="14"
                VerticalScrollBarVisibility="Visible"
                HorizontalScrollBarVisibility="Visible"/>
        </GroupBox>

    </Grid>
</Window>
'@

function DoParse {

    $examples = @()
    $headers = @()

    foreach ($record in $tbExamples.Text -split "`r`n") {
        $examples += $record
    }

    foreach ($record in $tbHeaders.Text -split "`r`n") {
        $headers += $record
    }

    $constraints = [Ordered]@{
        0 = $examples
    }

    try {
        $tbParsedResults.Text = Invoke-SplitText -File $targetFile -Constraints $constraints -Header $headers  | Out-String
    }
    catch {

    }
}

$Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$XAML)))

$Window.Title = "Split Text Buddy - [$targetFile]"

$tbFileContents = $Window.FindName("tbFileContents")
$tbExamples = $Window.FindName("tbExamples")
$tbHeaders = $Window.FindName("tbHeaders")
$tbParsedResults = $Window.FindName("tbParsedResults")

$tbFileContents.Add_TextChanged( { DoParse })
$tbExamples.Add_TextChanged( { DoParse })
$tbHeaders.Add_TextChanged( { DoParse })

$tbFileContents.Text = Get-Content -raw $targetFile

$null = $tbExamples.Focus()
[void]$Window.ShowDialog()