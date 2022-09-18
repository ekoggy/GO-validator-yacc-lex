Param (
[string]$mode = "all"
)
if ($mode -eq "all" -or $mode -eq "clear")
{
    echo "Clear"
    Remove-item parcer.c
    Remove-item parcer.h
    Remove-item validator.exe
    Remove-item lex.yy.c
}
if ($mode -eq "all" -or $mode -eq "build")
{
    echo "Build"
    .\win_bison.exe -o parcer.c -d analyser.y 
    .\win_flex.exe -o lexer.c lexer.l
    gcc lexer.c parcer.c parcer.h -o validator}
if ($mode -eq "all" -or $mode -eq "run")
{
    echo "Run"
    Get-Content config.in | .\validator.exe
}
