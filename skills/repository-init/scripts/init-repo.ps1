# Write the files a repository carries on day one from the templates beside this
# script: AGENTS.md and its CLAUDE.md copy, README.md, CONTRIBUTING.md,
# SECURITY.md, CHANGELOG.md, a license, .gitignore, specs/, the agent rules check
# and its CI job. init-repo.sh is the same program in bash, and writes the same
# bytes for the same flags.
#
# It writes files and nothing else: no git init, no git add, no commit.
#
# Usage: pwsh init-repo.ps1 [flags]   (--help lists them)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
Set-StrictMode -Version Latest

$Templates = Join-Path $PSScriptRoot '..' 'templates'

function Show-Usage {
    @'
Usage: pwsh init-repo.ps1 [flags]

  --path <dir>                     where to write (default: .)
  --agent agents|claude            repeatable; claude adds CLAUDE.md, a copy of AGENTS.md
                                   (default: claude)
  --script sh|ps                   the language of the generated check (default: ps)
  --license mit|apache-2.0|none    (default: mit)
  --holder <name>                  the MIT copyright holder (default: git config user.name)
  --contributing | --no-contributing   (default: on)
  --security | --no-security           (default: on)
  --changelog | --no-changelog         (default: off)
  --specs | --no-specs                 (default: on)
  --ci github|none                 write the GitHub Actions job (default: github)
  --default-branch <name>          (default: read from git, otherwise asked)
  --skip-existing                  write only the files that do not exist
  --force                          overwrite the files that exist
  --dry-run                        print what would be written, and write nothing
  --non-interactive                never prompt; exit 2 naming the missing value

Exit status: 0 when written; 1 when a file exists and neither --skip-existing nor
--force was given, with nothing written; 2 on a usage error or a missing value.
'@
}

function Stop-Usage([string]$Message) {
    [Console]::Error.WriteLine("init-repo: $Message")
    exit 2
}

$Path = '.'
$AgentSeen = $false
$Claude = $false
$Script = 'ps'
$License = 'mit'
$Holder = ''
$Contributing = $true
$Security = $true
$Changelog = $false
$Specs = $true
$Ci = 'github'
$DefaultBranch = ''
$SkipExisting = $false
$Force = $false
$DryRun = $false
$NonInteractive = $false

$i = 0
while ($i -lt $args.Count) {
    $flag = [string]$args[$i]
    if ($flag -in @('--path', '--agent', '--script', '--license', '--holder', '--ci', '--default-branch')) {
        if ($i + 1 -ge $args.Count) { Stop-Usage "$flag needs a value" }
        $value = [string]$args[$i + 1]
        switch ($flag) {
            '--path' { $Path = $value }
            '--agent' {
                $AgentSeen = $true
                switch ($value) {
                    'agents' { }
                    'claude' { $Claude = $true }
                    default { Stop-Usage "--agent takes agents or claude, not '$value'" }
                }
            }
            '--script' {
                if ($value -cnotin @('sh', 'ps')) { Stop-Usage "--script takes sh or ps, not '$value'" }
                $Script = $value
            }
            '--license' {
                if ($value -cnotin @('mit', 'apache-2.0', 'none')) {
                    Stop-Usage "--license takes mit, apache-2.0 or none, not '$value'"
                }
                $License = $value
            }
            '--holder' { $Holder = $value }
            '--ci' {
                if ($value -cnotin @('github', 'none')) { Stop-Usage "--ci takes github or none, not '$value'" }
                $Ci = $value
            }
            '--default-branch' { $DefaultBranch = $value }
        }
        $i += 2
        continue
    }
    switch -CaseSensitive ($flag) {
        '--contributing' { $Contributing = $true }
        '--no-contributing' { $Contributing = $false }
        '--security' { $Security = $true }
        '--no-security' { $Security = $false }
        '--changelog' { $Changelog = $true }
        '--no-changelog' { $Changelog = $false }
        '--specs' { $Specs = $true }
        '--no-specs' { $Specs = $false }
        '--skip-existing' { $SkipExisting = $true }
        '--force' { $Force = $true }
        '--dry-run' { $DryRun = $true }
        '--non-interactive' { $NonInteractive = $true }
        { $_ -in @('-h', '--help') } { Show-Usage; exit 0 }
        default { Stop-Usage "unknown flag '$flag'; --help lists the flags" }
    }
    $i += 1
}

if (-not $AgentSeen) { $Claude = $true }
if ($SkipExisting -and $Force) { Stop-Usage '--skip-existing and --force contradict each other' }

# ── the target directory ─────────────────────────────────────────
$Root = [System.IO.Path]::TrimEndingDirectorySeparator([System.IO.Path]::GetFullPath($Path, (Get-Location).Path))
if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    $parent = Split-Path -Parent $Root
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        Stop-Usage "--path ${Path}: its parent directory does not exist"
    }
}
$Project = Split-Path -Leaf $Root

function Read-Required([string]$Flag, [string]$Question) {
    if ($NonInteractive -or [Console]::IsInputRedirected) { Stop-Usage "$Flag is required: $Question" }
    $answer = Read-Host $Question
    if (-not $answer) { Stop-Usage "$Flag is required: $Question" }
    $answer
}

function Test-InGit {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return $false }
    if (-not (Test-Path -LiteralPath $Root -PathType Container)) { return $false }
    & git -C $Root rev-parse --git-dir 2>$null | Out-Null
    $LASTEXITCODE -eq 0
}

# ── the values the templates need ────────────────────────────────
$NeedsBranch = $Contributing -or ($Claude -and $Ci -eq 'github')
if ($NeedsBranch -and -not $DefaultBranch) {
    if (Test-InGit) {
        $remoteHead = & git -C $Root symbolic-ref --short refs/remotes/origin/HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $remoteHead) { $DefaultBranch = ([string]$remoteHead) -replace '^origin/', '' }
        if (-not $DefaultBranch) {
            $current = & git -C $Root branch --show-current 2>$null
            if ($LASTEXITCODE -eq 0 -and $current) { $DefaultBranch = [string]$current }
        }
    }
    if (-not $DefaultBranch) { $DefaultBranch = Read-Required '--default-branch' "The default branch's name?" }
}

if ($License -eq 'mit' -and -not $Holder) {
    if (Test-InGit) {
        $name = & git -C $Root config user.name 2>$null
        if ($LASTEXITCODE -eq 0 -and $name) { $Holder = [string]$name }
    } elseif (Get-Command git -ErrorAction SilentlyContinue) {
        $name = & git config --global user.name 2>$null
        if ($LASTEXITCODE -eq 0 -and $name) { $Holder = [string]$name }
    }
    if (-not $Holder) { $Holder = Read-Required '--holder' 'The copyright holder for the MIT license?' }
}

$LicenseName = switch ($License) { 'mit' { 'MIT' } 'apache-2.0' { 'Apache-2.0' } default { '' } }
$CheckExt = if ($Script -eq 'sh') { 'sh' } else { 'ps1' }
$CheckCommand = if ($Script -eq 'sh') { 'bash scripts/check-agent-rules.sh' } else { 'pwsh scripts/check-agent-rules.ps1' }

$Flags = [System.Collections.Generic.HashSet[string]]::new()
if ($Claude) { [void]$Flags.Add('claude') }
if ($Contributing) { [void]$Flags.Add('contributing') }
if ($Security) { [void]$Flags.Add('security') }
if ($Changelog) { [void]$Flags.Add('changelog') }
if ($Specs) { [void]$Flags.Add('specs') }
if ($License -ne 'none') { [void]$Flags.Add('license') }
[void]$Flags.Add($Script)

$Tokens = [ordered]@{
    PROJECT        = $Project
    DEFAULT_BRANCH = $DefaultBranch
    CHECK_COMMAND  = $CheckCommand
    LICENSE_NAME   = $LicenseName
    YEAR           = [string](Get-Date).Year
    HOLDER         = $Holder
}

# ── the plan: template → file, in the order both variants write ──
$Plan = [System.Collections.Generic.List[object]]::new()
function Add-Plan([string]$Source, [string]$Destination) {
    $Plan.Add([pscustomobject]@{ Source = $Source; Destination = $Destination })
}

Add-Plan 'AGENTS.md.tmpl' 'AGENTS.md'
if ($Claude) { Add-Plan '@copy' 'CLAUDE.md' }
Add-Plan 'README.md.tmpl' 'README.md'
if ($Contributing) { Add-Plan 'CONTRIBUTING.md.tmpl' 'CONTRIBUTING.md' }
if ($Security) { Add-Plan 'SECURITY.md.tmpl' 'SECURITY.md' }
if ($Changelog) { Add-Plan 'CHANGELOG.md.tmpl' 'CHANGELOG.md' }
if ($License -ne 'none') { Add-Plan "LICENSE-$License.tmpl" 'LICENSE' }
Add-Plan 'gitignore.tmpl' '.gitignore'
if ($Specs) { Add-Plan '@empty' 'specs/.gitkeep' }
if ($Claude) {
    Add-Plan "check-agent-rules.$CheckExt.tmpl" "scripts/check-agent-rules.$CheckExt"
    if ($Ci -eq 'github') { Add-Plan 'agent-rules.yml.tmpl' '.github/workflows/agent-rules.yml' }
}

function Test-Exists([string]$Target) {
    (Test-Path -LiteralPath $Target) -or ($null -ne (Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue))
}

$Existing = @($Plan | Where-Object { Test-Exists (Join-Path $Root $_.Destination) } | ForEach-Object { $_.Destination })
if ($Existing.Count -gt 0 -and -not $SkipExisting -and -not $Force) {
    [Console]::Error.WriteLine('init-repo: these files exist, and nothing was written:')
    foreach ($destination in $Existing) { [Console]::Error.WriteLine("  $destination") }
    [Console]::Error.WriteLine('Rerun with --skip-existing to write only the missing files, or with --force to overwrite.')
    exit 1
}

# ── the renderer ─────────────────────────────────────────────────
# A line starting with conditions (@name, @!name, …) is kept only when each holds,
# and is written without them and the one space after them. Each {{TOKEN}} is
# replaced with its value.
function Get-Rendered([string]$Name) {
    $text = [System.IO.File]::ReadAllText((Join-Path $Templates $Name)).Replace("`r`n", "`n")
    $lines = $text.Split("`n")
    if ($text.EndsWith("`n")) { $lines = $lines[0..($lines.Count - 2)] }
    $out = [System.Text.StringBuilder]::new()
    foreach ($line in $lines) {
        $match = [regex]::Match($line, '^((?:@!?[a-z]+)+)(?: (.*))?$')
        if ($match.Success) {
            $keep = $true
            foreach ($condition in [regex]::Matches($match.Groups[1].Value, '@(!?)([a-z]+)')) {
                $negated = $condition.Groups[1].Value -eq '!'
                if ($Flags.Contains($condition.Groups[2].Value) -eq $negated) { $keep = $false }
            }
            if (-not $keep) { continue }
            $line = $match.Groups[2].Value
        }
        foreach ($token in $Tokens.Keys) { $line = $line.Replace("{{$token}}", $Tokens[$token]) }
        [void]$out.Append($line).Append("`n")
    }
    $out.ToString()
}

# ── write ────────────────────────────────────────────────────────
$Utf8 = [System.Text.UTF8Encoding]::new($false)
foreach ($step in $Plan) {
    $target = Join-Path $Root $step.Destination
    if ($SkipExisting -and (Test-Exists $target)) {
        Write-Output "skipped $($step.Destination) (exists)"
        continue
    }
    if ($DryRun) {
        Write-Output "would write $($step.Destination)"
        continue
    }
    $directory = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    switch ($step.Source) {
        '@copy' { Copy-Item -LiteralPath (Join-Path $Root 'AGENTS.md') -Destination $target -Force }
        '@empty' { [System.IO.File]::WriteAllText($target, '', $Utf8) }
        default { [System.IO.File]::WriteAllText($target, (Get-Rendered $step.Source), $Utf8) }
    }
    if ($step.Destination.EndsWith('.sh') -and -not $IsWindows) { & chmod +x $target }
    Write-Output "wrote $($step.Destination)"
}

if ($DryRun) {
    Write-Output 'Dry run: nothing was written.'
    exit 0
}
Write-Output ''
Write-Output 'Next: fill every TODO(repository-init) line with the user:'
Write-Output "  grep -rn 'TODO(repository-init)' $Path"
Write-Output 'Nothing was staged or committed. A commit subject for these files:'
Write-Output '  Add the agent rules file, the contributor documents and the rules check'
