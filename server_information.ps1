#Modify the path below to this program's location on your computer
$root_path = "C:\Users\$env:USERNAME\Desktop\"
#other variables
$date=$(Get-Date -format "ddMMMyyyy")
$server_file=$root_path\server_list.txt

$answer = Read-Host "Edit server_list.txt? [N]o or [Return] for Yes"
if ($answer -ne "N") {
    notepad $server_file
    Read-Host "After saving, hit [ENTER] to continue"
}
$servers=$(get-content $server_file | ? {$_.trim() -ne "" } | Foreach {$_.TrimEnd()})
$servers | ForEach {
  $Each_server=$_
  $OUTPUT_Serverinfo=$(Get_serverinformation($Each_server))
}
$OUTPUT_Serverinfo | Export-Csv -Path $root_path\$date_serverinfo.csv
