# Delete all merged branches

git branch --merged | %{$_.trim()} | ?{$_ -notmatch 'develop' -and $_ -notmatch 'master'} | %{git branch -d $_}