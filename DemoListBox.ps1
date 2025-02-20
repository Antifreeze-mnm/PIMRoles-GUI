# Connect to Microsoft Graph using device code authentication
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "RoleManagement.ReadWrite.Directory", "User.Read" -UseDeviceAuthentication -NoWelcome
# Get the current user's ID
$CurrentAccountId = (Get-AzContext).Account.Id
$CurrentUser = Get-MgUser -UserId $CurrentAccountId
$CurrentAccountId = $CurrentUser.Id

# Retrieve role eligibility schedules for the current user
$PimRoles = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -Filter "principalId eq '$CurrentAccountId'" -ExpandProperty "roleDefinition"

# Retrieve all built-in roles
$allBuiltInRoles = Get-MgRoleManagementDirectoryRoleDefinition -All

# Retrieve role management policy assignments and policies
$assignments = Get-MgPolicyRoleManagementPolicyAssignment -Filter "scopeId eq '/' and scopeType eq 'Directory'"
$policies = Get-MgPolicyRoleManagementPolicy -Filter "scopeId eq '/' and scopeType eq 'Directory'"

# Get all active PIM role assignments for the current user
$ActivePimRoles = Get-MgRoleManagementDirectoryRoleAssignment -Filter "principalId eq '$CurrentAccountId'" -ExpandProperty "roleDefinition"

$SortedRoles = $PimRoles | Sort-Object { $_.RoleDefinition.DisplayName }

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
        Title="Demo" Height="450" Width="600">
    <Grid>
        <Label x:Name="lblSelectRoles" Content="Select Roles" Margin="10,0,0,0" Width="135" HorizontalAlignment="Left" FontSize="20"/>
        <Border CornerRadius="4" BorderBrush="Gray" BorderThickness="1" Background="White" Margin="2,10,0,0" Width="550">
            <ListBox x:Name="RolesListBox" Height="240" Margin="10,10,50,10" ItemsSource="{Binding Path=observable, UpdateSourceTrigger=PropertyChanged}">
                <ListBox.ItemTemplate>
                    <DataTemplate>
                    	<StackPanel Orientation="Horizontal">
						    <CheckBox IsEnabled="{Binding IsSelectable}" Foreground="{Binding Foreground}" Padding="4,0,0,0" VerticalContentAlignment="Center" FontSize="14" />
						    <TextBlock Text="{Binding RoleDefinition.DisplayName}" />
					    </StackPanel>
                    </DataTemplate>
                </ListBox.ItemTemplate>
            </ListBox>
        </Border>

    </Grid>
</Window>

'@ -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window' -replace 'x:Class="\S+"',''

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $XAML)
$Form=[Windows.Markup.XamlReader]::Load($reader)
$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name) }


$RolesListBox.SelectionMode = 'Multiple'
$RolesListBox.ItemsSource = $SortedRoles

$Form.ShowDialog()