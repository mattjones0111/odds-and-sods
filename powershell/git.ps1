# Delete all merged branches

git branch --merged | %{$_.trim()} | ?{$_ -notmatch 'develop' -and $_ -notmatch 'master' -and $_ -notmatch 'main'} | %{git branch -d $_}

# Pull all repos in subdirs

Get-ChildItem -Directory | foreach { Write-Host ">>> Getting latest for $_" | git -C $_.FullName pull --all --recurse-submodules --verbose }