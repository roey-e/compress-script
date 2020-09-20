$outputExtension = ".mp4";
$vcodec = "h265";
$scale = 0.33;
$mux = 'mp4';

$dateFormat = "yyyy.MM.dd-HH.mm";
$folderDateFormat = "yyyy.MM";

$sourceFolder = ".\sdcard"
$doneFolder = ".\sdcard.old"
if (-not (Test-Path $doneFolder)) {
  New-Item -Path . -Name $doneFolder -ItemType "directory";
}

foreach($inputFile in Get-ChildItem -Path $sourceFolder -Filter *.mov -Recurse)
{
  $date = $inputFile.LastWriteTime;

  $destinationFolder = ".\" + $date.ToString($folderDateFormat);
  if (-not (Test-Path $destinationFolder)) {
    New-Item -Path . -Name $destinationFolder -ItemType "directory";
  }
  $outputFileName = $date.ToString($dateFormat) + $outputExtension;
  $outputFilePath = [System.IO.Path]::Combine($destinationFolder, $outputFileName);
  $doneFilePath = [System.IO.Path]::Combine($doneFolder, $outputFileName);

  if (Test-Path $doneFilePath) {
    continue;
  }
  
  $programFiles = ${env:ProgramFiles};
  $processName = $programFiles + "\VideoLAN\VLC\vlc.exe";
  $processArgs = "-I dummy -vvv `"$($inputFile.FullName)`" --sout=#transcode{vcodec=`"$vcodec`",scale=`"$scale`",acodec=none}:standard{access=`"file`",mux=`"$mux`",dst=`"$outputFilePath`"} vlc://quit";
  
  Write-Host -NoNewline "Working on $outputFileName... ";
  Start-Process $processName $processArgs -wait;
  Move-Item $inputFile.FullName $doneFilePath
  Write-Output "Done";
}

Read-Host -Prompt "Done! Press Enter to exit"
