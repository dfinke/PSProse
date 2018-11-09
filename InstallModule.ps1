$fullPath = 'C:\Program Files\WindowsPowerShell\Modules\PSProse'

Robocopy . $fullPath /mir /XD .vscode .git examples images /XF CODE_OF_CONDUCT.md .gitattributes .gitignore