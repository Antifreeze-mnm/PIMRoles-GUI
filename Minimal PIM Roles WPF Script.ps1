Function Show-PIMRoleForm {
    <#
    .SYNOPSIS
        Displays a WPF form listing PIM Roles for the current user.
    .DESCRIPTION
        This function retrieves PIM role eligibility schedules for the current user from Microsoft Graph
        and displays them in a WPF DataGrid.  This is a simplified function for testing purposes,
        directly loading XAML within the function and bypassing external XAML loading functions.
    #>
    param()

    # --- XAML Definition (Minimal) ---
    $xamlForm = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PIM Roles" Height="450" Width="800">
    <Grid>
        <DataGrid x:Name="RolesDataGrid" AutoGenerateColumns="False" IsReadOnly="True" >
            <DataGrid.Columns>
                <DataGridTextColumn Header="Role Name" Binding="{Binding Role}" Width="*" />
            </DataGrid.Columns>
       </DataGrid>
    </Grid>
</Window>
"@

    try {
        # --- Explicitly Load WPF Assemblies ---
        Write-Host "Show-PIMRoleForm: Attempting to load WPF Assemblies..."
        [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework") | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName("System.Xaml") | Out-Null
        Write-Host "Show-PIMRoleForm: WPF Assembly loading attempted."

        Write-Host "Show-PIMRoleForm: Starting XAML Load"
        [xml]$xmlWPF = $xamlForm
        $WPFForm = ([Windows.Markup.XamlReader]::Load((new-object -TypeName System.Xml.XmlNodeReader -ArgumentList $xmlWPF)))
        Write-Host "Show-PIMRoleForm: XamlReader::Load Completed"

        # Get DataGrid element
        $RolesDataGrid = $WPFForm.FindName("RolesDataGrid")
        if (-not $RolesDataGrid) {
            Write-Error "Error: Could not find DataGrid element 'RolesDataGrid' in XAML."
            return # Exit function if DataGrid not found
        }
        Write-Host "Show-PIMRoleForm: RolesDataGrid element found."

        # Connect to Microsoft Graph
        Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "RoleManagement.ReadWrite.Directory", "User.Read" -UseDeviceAuthentication -NoWelcome

        # Get current user account ID
        $CurrentAccountId = (Get-AzContext).Account.Id
        $CurrentUser = Get-MgUser -UserId $CurrentAccountId
        $CurrentAccountId = $CurrentUser.Id

        # Retrieve role eligibility schedules for the current user
        $PimRoles = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -Filter "principalId eq '$CurrentAccountId'" -ExpandProperty "roleDefinition"

        # Sort the PIM roles
        $SortedRoles = $PimRoles | Sort-Object { $_.RoleDefinition.DisplayName }

        Write-Host "Show-PIMRoleForm: Populating DataGrid..."
        # Populate DataGrid (Directly in Main Thread - NO RUNSPACE)
        foreach ($Role in $SortedRoles) {
            try {
                $RoleDisplayName = $Role.RoleDefinition.DisplayName
                $RoleItem = [PSCustomObject]@{
                    Role = $RoleDisplayName
                }

                # --- Debug Output for Data Binding ---
                Write-Host "Data Binding Debug: RoleDisplayName: '$RoleDisplayName'"
                Write-Host "Data Binding Debug: \$RoleItem object: $($RoleItem | ConvertTo-Json)"

                $RolesDataGrid.Items.Add($RoleItem) # Add to DataGrid
            }
            catch {
                Write-Warning "Warning processing role $($Role.Id): $_" # Use Warning for non-critical errors
            }
        }
        Write-Host "Show-PIMRoleForm: DataGrid population complete."

        # Show the WPF Form
        Write-Host "Show-PIMRoleForm: Showing WPF Form..."
        $null = $WPFForm.Dispatcher.InvokeAsync{$WPFForm.ShowDialog()}.Wait()
        Write-Host "Show-PIMRoleForm: ShowDialog() Completed."

    }
    catch {
        Write-Error "Show-PIMRoleForm: Error in script: $_"
        Write-Error "Exception Type: $($_.Exception.GetType().FullName)"
        Write-Error "Stack Trace: $($_.Exception.StackTrace)"
    }
    finally {
        Disconnect-MgGraph -ErrorAction SilentlyContinue # Disconnect after use
    }
}

# --- Script Block to Call the Function ---
try {
    Show-PIMRoleForm # Call the function to display the form
}
catch {
    Write-Error "Error calling Show-PIMRoleForm: $_" # Catch any errors when calling the function itself
}