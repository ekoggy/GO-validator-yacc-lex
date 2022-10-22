Param (
[string]$mode = "all"
)
$ErrorActionPreference = 'SilentlyContinue'
if ($mode -eq "all" -or $mode -eq "clean")
{
    Write-Output "Clean"
    try{
        Remove-item parcer.c
        Remove-item parcer.h -f 
        Remove-item parcer.output
        Remove-item validator.exe
        Remove-item lexer.c
    }
    catch
    {
        Write-Output "No cleaning required"
    }
}
if ($mode -eq "all" -or $mode -eq "build")
{
    Write-Output "Build"
    .\win_bison.exe --verbose --debug -o parcer.c -d analyser.y 
    .\win_flex.exe -o lexer.c lexer.l
    gcc lexer.c parcer.c parcer.h -o validator
}