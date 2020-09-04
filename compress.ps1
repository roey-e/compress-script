$outputExtension = ".mp4";
$vcodec = "h265";
$scale = 0.33;
$mux = 'mp4';

$dateFormat = "yyyy.MM.dd-HH.mm";
$folderDateFormat = "yyyy.MM";

foreach($inputFile in Get-ChildItem -Path ".\sdcard" -Filter *.mov -Recurse)
{
  $date = $inputFile.LastWriteTime;

  $destinationFolder = ".\" + $date.ToString($folderDateFormat);
  if (-not (Test-Path $destinationFolder)) {
    New-Item -Path . -Name $destinationFolder -ItemType "directory";
  }
  $outputFileName = $date.ToString($dateFormat) + $outputExtension;
  $outputFileName = [System.IO.Path]::Combine($destinationFolder, $outputFileName);

  if (Test-Path $outputFileName) {
    continue;
  }
  
  $programFiles = ${env:ProgramFiles};
  $processName = $programFiles + "\VideoLAN\VLC\vlc.exe";
  $processArgs = "-I dummy -vvv `"$($inputFile.FullName)`" --sout=#transcode{vcodec=`"$vcodec`",scale=`"$scale`",acodec=none}:standard{access=`"file`",mux=`"$mux`",dst=`"$outputFileName`"} vlc://quit";
  
  Write-Host -NoNewline "Working on $outputFileName... ";
  Start-Process $processName $processArgs -wait;
  Write-Output "Done";
}

Read-Host -Prompt "Done! Press Enter to exit"