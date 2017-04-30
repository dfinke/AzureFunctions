$ModuleName = "AzureFunctions"
$ModulePath = "C:\Program Files\WindowsPowerShell\Modules"
$TargetPath = "$($ModulePath)\$($ModuleName)"


Remove-Item $TargetPath -Recurse -Force -Confirm -ErrorAction Ignore