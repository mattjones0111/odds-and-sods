# A script that installs Visual Studio selector functions, so that you can
# open the first found .sln file in VS by simply typing `vs` in the repo folder.
#
# Installation : Add the following to $profile

function Get-VisualStudioCommand
{
    [CmdletBinding()]
    param ( [AllowNull()][String] $vsVersion )
    $vs10 = """${env:ProgramFiles(x86)}\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"""
    $vs13 = """${env:ProgramFiles(x86)}\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"""
    $vs15 = """${env:ProgramFiles(x86)}\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"""
    $vs17 = """${env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\Professional\Common7\IDE\devenv.exe"""
    $vs19 = """${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"""
    $vs22 = """${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"""

    switch ($vsVersion) 
    { 
        '10' {$vs10}
        '13' {$vs13}
        '15' {$vs15} 
        '17' {$vs17} 
        '19' {$vs19}
        '22' {$vs22}
        default {$vs22} 
    }
}

function Get-SolutionName
{
    [CmdletBinding()]
    param ( [AllowNull()][String] $Name )

    if (!$Name)
    {
        $Name = (Get-ChildItem -Filter *.sln -Recurse | Select-Object -First 1).FullName
    }

    if ($Name)
    {
        $Name = ('"{0}"' -f $Name)
    }

    return $Name
}

function Start-VisualStudioProcess
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([String]$Version, [String]$Sln)

    $VsCommand = Get-VisualStudioCommand -vsVersion $Version
    $Sln = Get-SolutionName -Name $Sln

    Write-Verbose -Message ('Starting: command={0} solutionName={1}' -f $VsCommand, $Sln)

    if ($PSCmdlet.ShouldProcess($VsCommand, 'Start-Process'))
    {
        if ($Sln)
        {
            Start-Process -FilePath $vsCommand -ArgumentList $Sln
        }
        else
        {
            Start-Process -FilePath $vsCommand 
        }

    }
}

Set-Alias -Name vs -Value Start-VisualStudioProcess
