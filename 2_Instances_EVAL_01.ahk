#Requires AutoHotkey v2.0

; =============================================================================
; ADXL355 Dual Sensor Automation Script
; F9 = Scroll, set filename based on window title, AND start measurements
; F10 = Scroll, stop measurements, scroll back up, AND take screenshots
; =============================================================================

; Set title matching to exact match
SetTitleMatchMode(3)

; Hardcoded window titles
global isolatedTitle := "Producer/Consumer Design Pattern (Events)"
global nakedTitle := "[#] [EVAL] Producer/Consumer Design Pattern (Events) [#]"

; Screenshot save path
global graphPath := "C:\Users\cemat\Desktop\Studiprojekt_Vibrationssensor\Sensor\Graphs\"

; Function to scroll down and left in a window - FASTER VERSION
ScrollToButtons(hwnd) {
    WinActivate(hwnd)
    Sleep(100)
    
    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, hwnd)
    
    ; Move mouse to center of window before scrolling
    centerX := winX + (winWidth // 2)
    centerY := winY + (winHeight // 2)
    MouseMove(centerX, centerY)
    Sleep(50)
    
    ; Scroll down in one big scroll (21 notches = 7 scrolls of 3)
    Send("{WheelDown 21}")
    Sleep(150)
    
    ; Scroll left in one go (6 notches = 2 scrolls of 3)
    Send("{WheelLeft 6}")
    Sleep(100)
}

; Function to scroll back up in a window - FASTER VERSION
ScrollBackUp(hwnd) {
    WinActivate(hwnd)
    Sleep(100)
    
    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, hwnd)
    
    ; Move mouse to center of window before scrolling
    centerX := winX + (winWidth // 2)
    centerY := winY + (winHeight // 2)
    MouseMove(centerX, centerY)
    Sleep(50)
    
    ; Scroll up in one big scroll (21 notches = 7 scrolls of 3)
    Send("{WheelUp 21}")
    Sleep(100)
}

; Function to take screenshot using PowerShell
TakeScreenshot(prefix, timestamp) {
    ; Screenshot coordinates
    x := 178
    y := 344
    w := 1129  ; 1307 - 178
    h := 653   ; 997 - 344
    
    ; Create filename
    filename := prefix "_" timestamp "_screenshot.png"
    filepath := graphPath filename
    
    ; PowerShell script to capture screenshot (single line)
    psScript := "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $bitmap = New-Object System.Drawing.Bitmap " . w . "," . h . "; $graphics = [System.Drawing.Graphics]::FromImage($bitmap); $graphics.CopyFromScreen(" . x . "," . y . ",0,0,$bitmap.Size); $bitmap.Save('" . filepath . "',[System.Drawing.Imaging.ImageFormat]::Png); $graphics.Dispose(); $bitmap.Dispose()"
    
    ; Execute PowerShell command
    try {
        RunWait('powershell.exe -WindowStyle Hidden -Command "' . psScript . '"', , "Hide")
        return true
    } catch {
        return false
    }
}

; Function to get prefix based on window title
GetPrefix(title) {
    if (title = nakedTitle) {
        return "Naked"
    } else {
        return "Isolated"
    }
}

; Function to find all relevant windows
GetRelevantWindows() {
    relevantWindows := []
    
    ; Try to find Isolated instance (exact match only)
    isolatedHwnd := WinExist(isolatedTitle)
    if (isolatedHwnd) {
        obj := {}
        obj.hwnd := isolatedHwnd
        obj.title := isolatedTitle
        relevantWindows.Push(obj)
    }
    
    ; Try to find Naked instance (exact match only)
    nakedHwnd := WinExist(nakedTitle)
    if (nakedHwnd) {
        obj := {}
        obj.hwnd := nakedHwnd
        obj.title := nakedTitle
        relevantWindows.Push(obj)
    }
    
    return relevantWindows
}

; F9: Scroll, set filename based on window title, AND start data capture
F9:: {
    relevantWindows := GetRelevantWindows()
    
    if (relevantWindows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    ; Generate timestamp for this measurement session
    global currentTimestamp := FormatTime(, "yyyyMMdd_HHmmss")
    
    ; === PHASE 1: SCROLL TO BUTTONS IN ALL INSTANCES ===
    for window in relevantWindows {
        ScrollToButtons(window.hwnd)
    }
    
    Sleep(200)
    
    ; === PHASE 2: SET FILENAMES IN ALL INSTANCES ===
    for window in relevantWindows {
        WinActivate(window.hwnd)
        Sleep(100)
        
        ; Get prefix based on stored title
        prefix := GetPrefix(window.title)
        
        ; Triple-click on filename field at 918, 835 to select all
        MouseClick("Left", 918, 835)
        Sleep(40)
        MouseClick("Left", 918, 835)
        Sleep(40)
        MouseClick("Left", 918, 835)
        Sleep(80)
        
        ; Generate filename and copy to clipboard
        filename := prefix "_" currentTimestamp ".txt"
        A_Clipboard := filename
        Sleep(40)
        
        ; Paste filename with Ctrl+V
        Send("^v")
        Sleep(100)
    }
    
    ; Wait for all filenames to be confirmed
    Sleep(200)
    
    ; === PHASE 3: START DATA CAPTURE IN ALL INSTANCES ===
    for window in relevantWindows {
        WinActivate(window.hwnd)
        Sleep(100)
        
        ; Click Start button at screen position 1439, 718
        MouseClick("Left", 1439, 718)
        Sleep(150)
    }
    
    ; Confirmation tooltip
    ToolTip("✓ Filenames set and measurement started`nTimestamp: " currentTimestamp "`nInstances: " relevantWindows.Length)
    SetTimer(() => ToolTip(), -3000)
}

; F10: Scroll, stop data capture, scroll back up, AND take screenshots
F10:: {
    relevantWindows := GetRelevantWindows()
    
    if (relevantWindows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    ; === SCROLL TO BUTTONS IN ALL INSTANCES ===
    for window in relevantWindows {
        ScrollToButtons(window.hwnd)
    }
    
    Sleep(150)
    
    stoppedCount := 0
    
    ; === STOP DATA CAPTURE ===
    for window in relevantWindows {
        WinActivate(window.hwnd)
        Sleep(80)
        
        ; Click Stop button at screen position 1438, 826
        MouseClick("Left", 1438, 826)
        Sleep(150)
        
        stoppedCount++
    }
    
    ; Wait for stop to complete
    Sleep(200)
    
    ; === SCROLL BACK UP IN ALL INSTANCES ===
    for window in relevantWindows {
        ScrollBackUp(window.hwnd)
    }
    
    ; Wait for scroll to complete
    Sleep(500)
    
    ; === TAKE SCREENSHOTS ===
    screenshotCount := 0
    for window in relevantWindows {
        WinActivate(window.hwnd)
        Sleep(200)
        
        prefix := GetPrefix(window.title)
        if (TakeScreenshot(prefix, currentTimestamp)) {
            screenshotCount++
        }
        Sleep(300)  ; Wait between screenshots
    }
    
    ; Confirmation tooltip
    ToolTip("✓ Stopped " stoppedCount " sensor(s)`nData saved`nScreenshots: " screenshotCount)
    SetTimer(() => ToolTip(), -2500)
}

; ESC: Emergency exit
Esc::ExitApp
