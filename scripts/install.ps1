$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$DefaultArchiveUrl = "https://github.com/vdaculan/bangit-commands/archive/refs/heads/main.zip"
$ArchiveUrl = if ([string]::IsNullOrWhiteSpace($env:BANGIT_COMMANDS_ARCHIVE_URL)) {
    $DefaultArchiveUrl
} else {
    $env:BANGIT_COMMANDS_ARCHIVE_URL
}

$UserHome = if ([string]::IsNullOrWhiteSpace($HOME)) {
    [Environment]::GetFolderPath("UserProfile")
} else {
    $HOME
}

$InstallDir = if ([string]::IsNullOrWhiteSpace($env:CODEX_SKILLS_DIR)) {
    Join-Path $UserHome ".codex/skills"
} else {
    $env:CODEX_SKILLS_DIR
}

function Stop-Install {
    param([string] $Message)

    Write-Error "Error: $Message"
    exit 1
}

$TempRoot = $null

try {
    $SourceRoot = $null

    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $LocalRoot = Resolve-Path (Join-Path $PSScriptRoot "..") -ErrorAction SilentlyContinue
        if ($LocalRoot) {
            $LocalSkills = Join-Path $LocalRoot.Path ".codex/skills"
            if (Test-Path $LocalSkills -PathType Container) {
                $SourceRoot = $LocalRoot.Path
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
        $TempRoot = Join-Path ([IO.Path]::GetTempPath()) "bangit-commands-$([Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null

        $ArchivePath = Join-Path $TempRoot "bangit-commands.zip"
        $RequestArgs = @{
            Uri = $ArchiveUrl
            OutFile = $ArchivePath
        }

        if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey("UseBasicParsing")) {
            $RequestArgs.UseBasicParsing = $true
        }

        Invoke-WebRequest @RequestArgs
        Expand-Archive -Path $ArchivePath -DestinationPath $TempRoot -Force

        $ArchiveRoot = Get-ChildItem -Path $TempRoot -Directory |
            Where-Object { $_.Name -like "bangit-commands-*" } |
            Select-Object -First 1

        if (-not $ArchiveRoot) {
            Stop-Install "could not find extracted bangit-commands archive"
        }

        $SourceRoot = $ArchiveRoot.FullName
    }

    $SkillsSource = Join-Path $SourceRoot ".codex/skills"
    if (-not (Test-Path $SkillsSource -PathType Container)) {
        Stop-Install "skills directory not found: $SkillsSource"
    }

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

    $SkillDirs = Get-ChildItem -Path $SkillsSource -Directory -Filter "ban-*"
    if (-not $SkillDirs) {
        Stop-Install "no ban-* skills found in $SkillsSource"
    }

    $InstalledCount = 0
    foreach ($SkillDir in $SkillDirs) {
        $SkillFile = Join-Path $SkillDir.FullName "SKILL.md"
        if (-not (Test-Path $SkillFile -PathType Leaf)) {
            Stop-Install "missing SKILL.md in $($SkillDir.FullName)"
        }

        $TargetDir = Join-Path $InstallDir $SkillDir.Name
        if (Test-Path $TargetDir) {
            Remove-Item -Path $TargetDir -Recurse -Force
        }

        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        Get-ChildItem -LiteralPath $SkillDir.FullName -Force |
            Copy-Item -Destination $TargetDir -Recurse -Force

        $InstalledCount += 1
        Write-Host "Installed $($SkillDir.Name)"
    }

    Write-Host "Installed $InstalledCount skill(s) to $InstallDir"
    Write-Host "Open a new Codex thread so the skill inventory reloads."
} finally {
    if ($TempRoot -and (Test-Path $TempRoot)) {
        Remove-Item -Path $TempRoot -Recurse -Force
    }
}
