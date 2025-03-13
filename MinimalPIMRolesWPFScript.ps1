Add-Type -AssemblyName PresentationFramework, PresentationUI, System.Xaml

# --- EMBEDDED XAML --- (Modified - NO Checked/Unchecked attributes)
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Minimal Test Form (Embedded XAML)" Height="200" Width="300">
    <Grid>
        <CheckBox Content="Test CheckBox" Name="CheckBox" />
    </Grid>
</Window>
"@
# --- END EMBEDDED XAML ---

# Load XAML (No Change) ...
Write-Host "Xaml Variable Type: $($xaml.GetType())"
Write-Host "Xaml Variable Content:"
Write-Host $xaml

# Load XAML using XamlReader::Parse (No Change) ...
try {
    Write-Host "Attempting to load XAML using XamlReader::Parse..."
    $Window = [Windows.Markup.XamlReader]::Parse($xaml)
    Write-Host "XAML loaded successfully via Parse."
} catch {
    Write-Error "Error loading XAML using Parse: $($_.Exception.Message)"
    return
}

$WPFGui = @{}
$WPFGui.Window = $Window

# Get CheckBox and ATTACH EVENT HANDLERS PROGRAMMATICALLY (using Add_Checked/Add_Unchecked)
$TestCheckBox = $WPFGui.Window.FindName("CheckBox")

$TestCheckBox.Add_Checked({
    Write-Host "CheckBox Checked! (via Add_Checked)"
})
$TestCheckBox.Add_Unchecked({
    Write-Host "CheckBox Unchecked! (via Add_Unchecked)"
})


# Set content and show form (No Change) ...
Write-Host "Showing form..."
$WPFGui.Window.ShowDialog() | Out-Null
Write-Host "Form closed."