# Define the $PimRoles array with example entries
[array]$PimRoles = @(
    [pscustomobject]@{
        Id = "roleEligibilityScheduleId1"
        RoleDefinition = [pscustomobject]@{
            Id = "roleDefinitionId1"
            DisplayName = "Role Display Name 1"
            Description = "Role Description 1"
        }
        PrincipalId = "userId1"
        DirectoryScopeId = "directoryScopeId1"
        StartDateTime = "2023-01-01T00:00:00Z"
        EndDateTime = "2023-12-31T23:59:59Z"
        MemberType = "Eligible"
    },
    [pscustomobject]@{
        Id = "roleEligibilityScheduleId2"
        RoleDefinition = [pscustomobject]@{
            Id = "roleDefinitionId2"
            DisplayName = "Role Display Name 2"
            Description = "Role Description 2"
        }
        PrincipalId = "userId2"
        DirectoryScopeId = "directoryScopeId2"
        StartDateTime = "2023-01-01T00:00:00Z"
        EndDateTime = "2023-12-31T23:59:59Z"
        MemberType = "Eligible"
    },
    [pscustomobject]@{
        Id = "roleEligibilityScheduleId3"
        RoleDefinition = [pscustomobject]@{
            Id = "roleDefinitionId3"
            DisplayName = "Role Display Name 3"
            Description = "Role Description 3"
        }
        PrincipalId = "userId3"
        DirectoryScopeId = "directoryScopeId3"
        StartDateTime = "2023-01-01T00:00:00Z"
        EndDateTime = "2023-12-31T23:59:59Z"
        MemberType = "Eligible"
    }
)

[xml]$XAML= $null

#region XAML
Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration

[xml]$XAML= @'

<Window x:Class="ADGui.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:ADGui"
        mc:Ignorable="d"
        Title="AD Info" Height="250" Width="400">
    <Grid>
        <ListBox x:Name="lstgroups" Margin="20,20,50,10" ItemsSource="{Binding Path=observable, UpdateSourceTrigger=PropertyChanged}">
            <ListBox.ItemTemplate>
                <DataTemplate>
                    <StackPanel Orientation="Horizontal">
                        <CheckBox IsChecked="{Binding IsSelected}"/>
                        <TextBlock Text="{Binding RoleDefinition.DisplayName}" />
                    </StackPanel>
                </DataTemplate>
           </ListBox.ItemTemplate>
        </ListBox>
    </Grid>
</Window>

'@ -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window' -replace 'x:Class="\S+"',''

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $XAML)
$Form=[Windows.Markup.XamlReader]::Load($reader)
$XAML.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

#endregion

$lstgroups.SelectionMode = 'Multiple'
$lstgroups.ItemsSource = $PimRoles

$btnreadvars.Add_Click({
    Write-Host  $lstgroups.SelectedItems
})

$Form.ShowDialog()