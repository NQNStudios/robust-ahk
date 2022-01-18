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

WaitForShift(message)
{
    ToolTip(message)
    KeyWait("LShift", "D")
    ; Wait for release in case another screen position tries to confirm itself on the same input frame
    KeyWait("LShift", "U")
    ToolTip()
}

RobustSleep(DelayName)
{
    File := RobustFileName(DelayName)
    If (FileExist(File)) {
        ToolTip("Waiting for " . DelayName)
        Sleep(Number(FileRead(File)))
        ToolTip("")
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
    checkBoxWindow.Add("Button", "Default", "Submit").OnEvent("Click", Submit.Bind(callOnChecked))
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
    BranchingChoice("Did the script work?", "&Yes", OnYes, "&No", OnNo)
}

TimeStamp()
{
    return "" A_MM "-" A_DD "-" A_YYYY "-" A_Hour "-" A_Min "-" A_Sec
}