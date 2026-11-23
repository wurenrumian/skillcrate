# 安装 skillcrate 里的 skill。
#   ./install.ps1              # 全装
#   ./install.ps1 geeklens     # 只装一个
$ErrorActionPreference = 'Stop'

$all = @('calm-explain', 'geeklens', 'informed-decision', 'project-memory', 'host-memory', 'file-conversion-toolkit')
$targets = if ($args.Count -gt 0) { $args } else { $all }

foreach ($s in $targets) {
    if ($s -notin $all) { throw "unknown skill: $s (known: $($all -join ', '))" }
    Write-Host "> $s"
    npx --yes skills add wurenrumian/skillcrate --global --skill $s --yes
    if ($LASTEXITCODE -ne 0) { throw "install failed: $s" }
}

Write-Host "done. 更新用 'npx skills update -g -y'。"
