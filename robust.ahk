RobustTypeText(TextName)
{
    File := "." TextName ".rahk"
    If (FileExist(File)) {
        SendText(FileRead(File))
    } Else {
        Value := InputBox(TextName).Value
        FileAppend(Value,File)
        SendText(Value)
    }
}

MsgBox A_Args

#Include %A_Args[1]%