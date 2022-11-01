### init-alias-win.ps1 -- Utilities for Windows Only

### Skips on non-Windows platform
if (-not $rice.os_windows) {
    return
}

### Privileged operations
function test_admin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltinRole]::Administrator)
}

function run_as_admin {
    if (test_admin) {
        Write-Output "Current session is running with admin privilege already."
    } else {
        if ($args.Length -eq 0) {
            Write-Output "Usage: runasAdmin <command> [arguments]"
        } elseif ($args.Length -ge 1) {
            $commands = "-noexit -command cd $pwd;" + ($args -join ' ')
            $proc = New-Object -TypeName System.Diagnostics.Process
            $proc.StartInfo.FileName = "pwsh.exe"
            $proc.StartInfo.Arguments = $commands
            $proc.StartInfo.UseShellExecute = $true
            $proc.StartInfo.Verb = "runas"
            $proc.Start() | Out-Null
        }
    }
}
Set-Alias sudo run_as_admin

function open_admin_session {
    if (test_admin) {
        Write-Output "You are admin already!"
        Write-Output "Current session is running with admin privilege already."
    } else {
        $commands = "-noexit -command cd $pwd;"
        $proc = New-Object -TypeName System.Diagnostics.Process
        $proc.StartInfo.FileName = "pwsh.exe"
        $proc.StartInfo.Arguments = $commands
        $proc.StartInfo.UseShellExecute = $true
        $proc.StartInfo.Verb = "runas"
        $proc.Start() | Out-Null
    }
}
Set-Alias su open_admin_session

### Directory listing
function listDirectory {
    [CmdletBinding(PositionalBinding=$false, DefaultParameterSetName="sortByDefault")]
    param ([Parameter(Position=0)][string]$path=$PWD.Path,
           [Parameter(Mandatory=$false, ParameterSetName="sortByWriteTime")][switch]$write,
           [Parameter(Mandatory=$false, ParameterSetName="sortByAccessTime")][switch]$access,
           [Parameter(Mandatory=$false, ParameterSetName="sortByCreationTime")][switch]$creation,
           [Parameter(Mandatory=$false, ParameterSetName="sortByName")][switch]$name,
           [Parameter(Mandatory=$false, ParameterSetName="sortBySize")][switch]$size)
    if ($write) {
        Get-ChildItem $path `
            | Sort-Object LastWriteTime `
            | Select-Object Mode,Length,LastWriteTime,Name,Target `
            | Format-Table -AutoSize
        return
    }
    if ($access) {
        Get-ChildItem $path `
            | Sort-Object LastAccessTime `
            | Select-Object Mode,Length,LastAccessTime,Name,Target `
            | Format-Table -AutoSize
        return
    }
    if ($creation) {
        Get-ChildItem $path `
            | Sort-Object CreationTime `
            | Select-Object Mode,Length,CreationTime,Name,Target `
            | Format-Table -AutoSize
        return
    }
    if ($name) {
        Get-ChildItem $path `
            | Sort-Object Name `
            | Select-Object Mode,Length,LastWriteTime,Name,Target `
            | Format-Table -AutoSize
        return
    }
    if ($size) {
        Get-ChildItem $path `
            | Sort-Object Length `
            | Select-Object Mode,Length,LastWriteTime,Name,Target `
            | Format-Table -AutoSize
        return
    }
    ## Fallback
    Get-ChildItem $path `
        | Select-Object Mode,Length,LastWriteTime,Name,Target `
        | Format-Table -AutoSize
}
Set-Alias ll listDirectory

### Cygwin
function cygwin-install {
    cygwin-setup --no-admin --no-shortcuts @args
}
