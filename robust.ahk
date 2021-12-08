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

; Source: https://www.autohotkey.com/boards/viewtopic.php?p=129052#p129052
; ported to AutoHotkey v2
WaitForShift(message) {
    waitingMessage := Gui()
    waitingMessage.Opt("+toolwindow")
    waitingMessage.Add("Text","",message)
    waitingMessage.Show()
    KeyWait("LShift", "D")
    ; Wait for release in case another screen position tries to confirm itself on the same input frame
    KeyWait("LShift", "U")
    waitingMessage.Destroy()
}