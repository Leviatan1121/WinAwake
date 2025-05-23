using namespace System.Windows.Forms
using namespace System.Drawing

# Verify if runs in hidden mode
param([switch]$Hidden)

function Start-WinAwake {
    Add-Type -AssemblyName System.Windows.Forms

    # Create main form
    $form = New-Object Form
    $form.Text = "WinAwake - Active"
    $form.AutoSize = $true
    $form.AutoSizeMode = [AutoSizeMode]::GrowAndShrink
    $form.MinimumSize = New-Object Drawing.Size(250, 130)
    $form.StartPosition = "CenterScreen"
    $form.Padding = New-Object Padding(10)
    $form.TopMost = $true
    $form.FormBorderStyle = [FormBorderStyle]::Fixed3D
    $form.MaximizeBox = $false

    # Create container panel to center elements
    $panel = New-Object FlowLayoutPanel
    $panel.FlowDirection = [FlowDirection]::TopDown
    $panel.WrapContents = $false
    $panel.AutoSize = $true
    $panel.AutoSizeMode = [AutoSizeMode]::GrowAndShrink
    $panel.Anchor = [AnchorStyles]::None
    $panel.Dock = [DockStyle]::Fill

    # Create informative text
    $label = New-Object Label
    $label.Text = "[ON] ACTIVE: Your PC will stay awake`nPress the button to deactivate"
    $label.AutoSize = $true
    $label.TextAlign = [ContentAlignment]::MiddleCenter
    $label.Margin = New-Object Padding(0, 0, 0, 10)
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 11, [FontStyle]::Regular)

    # Create the button
    $button = New-Object Button
    $button.Text = "Pause"
    $button.Size = New-Object Drawing.Size(100, 30)
    $button.Anchor = [AnchorStyles]::None
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [FontStyle]::Regular)

    # Create the Windows Forms timer
    $timer = New-Object Windows.Forms.Timer
    $timer.Interval = 57500
    $timer.Add_Tick({
        [SendKeys]::SendWait("+")
    })
    $timer.Start()

    # Handle button event
    $button.Add_Click({
        if ($timer.Enabled) {
            $timer.Stop()
            $form.Text = "WinAwake - Stopped"
            $label.Text = "[OFF] PAUSED: Normal sleep enabled`nPress the button to activate"
            $button.Text = "Resume"
        } else {
            $timer.Start()
            $form.Text = "WinAwake - Active"
            $label.Text = "[ON] ACTIVE: Your PC will stay awake`nPress the button to deactivate"
            $button.Text = "Pause"
        }
    })

    # Add controls to panel and panel to form
    $panel.Controls.Add($label)
    $panel.Controls.Add($button)
    $form.Controls.Add($panel)

    # Show the form
    $form.Show()
    $form.Activate()
    [Application]::Run($form)

    # Cleanup at closing
    $timer.Stop()
    $timer.Dispose()
}

# Si estamos ejecutando desde irm | iex
if (-not $PSCommandPath) {
    $tempScript = [System.IO.Path]::GetTempFileName() + ".ps1"
    @"
using namespace System.Windows.Forms
using namespace System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$(${function:Start-WinAwake})
Start-WinAwake
"@ | Out-File -FilePath $tempScript -Encoding UTF8
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File `"$tempScript`"" -WindowStyle Hidden
    Start-Sleep -Seconds 1
    Remove-Item -Path $tempScript -Force -ErrorAction SilentlyContinue
    return
}

# Para ejecución local normal
if (-not $Hidden) {
    Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Hidden" -WindowStyle Hidden
    return
}

# Asegurarse de que estamos en STA para la interfaz gráfica
if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    PowerShell -STA -File $PSCommandPath -Hidden
    return
}

# Iniciar la aplicación
Start-WinAwake