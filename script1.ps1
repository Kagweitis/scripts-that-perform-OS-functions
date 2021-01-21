$FileName = 'C:\Users\hp\Desktop\fs folder\A.txt'
>> If (Test-Path $FileName){
>>    Remove-Item $FileName
>> }