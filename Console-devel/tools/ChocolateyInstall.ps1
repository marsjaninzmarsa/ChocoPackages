$packageName = 'Console-devel'
$fileType = 'exe'
$silentArgs = '/silent'
$url = 'http://sourceforge.net/projects/console-devel/files/console-releases/2.0b147a/Console%202.00b147a%20win32.exe'
$url64bit = 'http://sourceforge.net/projects/console-devel/files/console-releases/2.0b147a/Console%202.00b147a%20x64.exe'

Install-ChocolateyPackage $packageName $fileType $silentArgs $url $url64bit

# Add a symlink/batch file to the path
$binary = $packageName
$exePath = "$binary\$binary.exe"

try {
    $is64bit = (Get-WmiObject Win32_Processor).AddressWidth -eq 64
    $programFiles = $env:programfiles
    if ($is64bit) {
        if($url64bit){
            $programFiles = $env:ProgramW6432}
        else{
            $programFiles = ${env:ProgramFiles(x86)}}
    }
    $executable = join-path $env:programfiles $exePath
    $fsObject = New-Object -ComObject Scripting.FileSystemObject
    $executable = $fsObject.GetFile("$executable").ShortPath

    $symLinkName = Join-Path $nugetExePath "$binary.exe"
    $batchFileName = Join-Path $nugetExePath "$binary.bat"

    # delete the batch file if it exists.
    if(Test-Path $batchFileName){
      Remove-Item "$batchFileName"}

    if( (gwmi win32_operatingSystem).version -ge 6){
      & $env:comspec /c mklink /H $symLinkName $executable}
    else{
    "@echo off
    SET DIR=%~dp0%
    start $executable %*" | Out-File $batchFileName -encoding ASCII
        }
    Write-ChocolateySuccess $packageName
} catch {
  Write-ChocolateyFailure $packageName "$($_.Exception.Message)"
  throw
}
