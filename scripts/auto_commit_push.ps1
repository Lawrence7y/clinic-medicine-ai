param(
    [string]$TargetBranch = ""
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $projectRoot

function Run-Git {
    param(
        [string[]]$GitArgs,
        [switch]$AllowFail
    )

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -c core.excludesfile=.git/info/exclude @GitArgs 2>&1
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
    $code = $LASTEXITCODE
    if (-not $AllowFail -and $code -ne 0) {
        throw "git $($GitArgs -join ' ') failed: $output"
    }
    return [PSCustomObject]@{
        Code = $code
        Output = ($output -join "`n").Trim()
    }
}

function U {
    param([int[]]$Codes)
    return -join ($Codes | ForEach-Object { [char]$_ })
}

function Get-LastNonEmptyLine {
    param([string]$Text)
    if (-not $Text) { return "" }
    $lines = @($Text -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
    if (-not $lines -or $lines.Count -eq 0) { return "" }
    return $lines[$lines.Count - 1]
}

function Build-CommitMessage {
    $nameStatus = Run-Git -GitArgs @("diff", "--cached", "--name-status")
    $lines = @()
    if ($nameStatus.Output) {
        $lines = $nameStatus.Output -split "`r?`n" | Where-Object { $_ -and $_.Trim() -ne "" }
    }

    $add = 0
    $modify = 0
    $delete = 0
    $topDirs = New-Object System.Collections.Generic.HashSet[string]

    foreach ($line in $lines) {
        $parts = $line -split "\s+", 2
        if ($parts.Count -lt 2) { continue }
        $status = $parts[0]
        $path = $parts[1]
        if ($status -notmatch '^(A|M|D|R|C|T|U|X|B)') { continue }

        if ($status -like "A*") { $add++ }
        elseif ($status -like "D*") { $delete++ }
        else { $modify++ }

        $normalized = $path.Replace("\", "/")
        $first = $normalized.Split("/")[0]
        if ($first) { [void]$topDirs.Add($first) }
    }

    $moduleText = if ($topDirs.Count -eq 0) {
        U @(39033, 30446) # 项目
    } else {
        ($topDirs | Select-Object -First 4) -join "/"
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $autoCommit = U @(33258, 21160, 25552, 20132) # 自动提交
    $update = U @(26356, 26032) # 更新
    $added = U @(26032, 22686) # 新增
    $modified = U @(20462, 25913) # 修改
    $deleted = U @(21024, 38500) # 删除

    return "${autoCommit}: ${update}${moduleText} [${added}${add},${modified}${modify},${deleted}${delete}] [$timestamp]"
}

$inside = Run-Git -GitArgs @("rev-parse", "--is-inside-work-tree") -AllowFail
$insideValue = Get-LastNonEmptyLine -Text $inside.Output
if ($inside.Code -ne 0 -or $insideValue -ne "true") {
    throw "Current directory is not a Git repository."
}

$branchInfo = Run-Git -GitArgs @("rev-parse", "--abbrev-ref", "HEAD")
$currentBranch = Get-LastNonEmptyLine -Text $branchInfo.Output
if ($currentBranch -eq "HEAD") {
    throw "Detached HEAD detected. Switch to a branch first."
}

if ($TargetBranch -and $TargetBranch.Trim() -ne "" -and $TargetBranch.Trim() -ne $currentBranch) {
    Run-Git -GitArgs @("checkout", $TargetBranch.Trim()) | Out-Null
    $currentBranch = $TargetBranch.Trim()
}

Run-Git -GitArgs @("add", "-A") | Out-Null

$diffResult = Run-Git -GitArgs @("diff", "--cached", "--quiet") -AllowFail
if ($diffResult.Code -gt 1) {
    throw "Failed to evaluate staged changes."
}
$hasStagedChanges = ($diffResult.Code -eq 1)

if (-not $hasStagedChanges) {
    Write-Host "No changes to commit. Skipped."
    exit 0
}

$message = Build-CommitMessage
Run-Git -GitArgs @("commit", "-m", $message) | Out-Null

$upstream = Run-Git -GitArgs @("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}") -AllowFail
if ($upstream.Code -ne 0) {
    Run-Git -GitArgs @("push", "-u", "origin", $currentBranch) | Out-Null
} else {
    Run-Git -GitArgs @("push", "origin", $currentBranch) | Out-Null
}

Write-Host "Auto commit and push completed."
Write-Host ("Branch: " + $currentBranch)
Write-Host ("Commit: " + $message)
