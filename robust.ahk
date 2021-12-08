RobustFiles := Map()

RobustFileName(Thing)
{
    File := "." Thing ".rahk"
    RobustFiles.Set(Thing, File)
    return File
}

RobustTypeText(TextName)
{
    File := RobustFileName(TextName)
    If (FileExist(File)) {
        SendText(FileRead(File))
    } Else {
        Value := InputBox("Value for " TextName).Value
        FileAppend(Value,File)
        SendText(Value)
    }
}

; Source: https://www.autohotkey.com/boards/viewtopic.php?p=129052#p129052
; ported to AutoHotkey v2
WaitForShift(message)
{
    waitingMessage := Gui()
    waitingMessage.Opt("+toolwindow")
    waitingMessage.Add("Text","",message)
    waitingMessage.Show()
    KeyWait("LShift", "D")
    ; Wait for release in case another screen position tries to confirm itself on the same input frame
    KeyWait("LShift", "U")
    waitingMessage.Destroy()
}

RobustSleep(DelayName)
{
    File := RobustFileName(DelayName)
    If (FileExist(File)) {
        Sleep(Number(FileRead(File)))
    } Else {
        Interval := 250
        Elapsed := 0
        UpdateCount()
        {
            Elapsed := Elapsed + Interval
        }
        SetTimer(UpdateCount, Interval)
        WaitForShift("Press LShift after delay for " DelayName)
        SetTimer(UpdateCount, 0)
        FileAppend("" Elapsed,File)
    }
}

BranchingChoice(message, ChoicesAndFunctions*)
{
    choiceBox := Gui()
    choiceBox.Add("Text", "", message)
    Close(*)
    {
        choiceBox.Destroy()
    }
    While ChoicesAndFunctions.Length >= 2
    {
        Text := ChoicesAndFunctions.RemoveAt(1)
        button := choiceBox.Add("Button","",Text)
        button.OnEvent("Click", ChoicesAndFunctions.RemoveAt(1))
        button.OnEvent("Click", Close)
    }
    choiceBox.Show()
}

Join(sep, params*) {
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}

CheckBoxes(Text, Choices, CallOnChecked)
{
    checkBoxWindow := Gui()
    checkBoxWindow.Add("Text","",Text)
    checkBoxes := []
    For choice in Choices
    {
        checkBoxes.Push(checkBoxWindow.Add("CheckBox", "", choice))
    }
    Submit(callOnChecked, *)
    {
        chosen := []

        For box in checkBoxes {
            if box.Value = 1 {
                chosen.push(Choices[A_Index])
            }
        }

        callOnChecked(chosen)
        checkBoxWindow.destroy()
    }
    checkBoxWindow.Add("Button", "", "Submit").OnEvent("Click", Submit.Bind(callOnChecked))
    checkBoxWindow.show()
}

RobustEnd()
{
    OnYes(*)
    {

    }
    OnNo(*)
    {
        ClearValues(Files)
        {
            For file in Files {
                FileDelete(RobustFiles[file])
            }
        }
        Things := []
        For Thing,File in RobustFiles {
            Things.push(Thing)
        }
        CheckBoxes("Were any of these stored values broken?", Things, ClearValues)
    }
    BranchingChoice("Did the script work?", "Yes", OnYes, "No", OnNo)
}