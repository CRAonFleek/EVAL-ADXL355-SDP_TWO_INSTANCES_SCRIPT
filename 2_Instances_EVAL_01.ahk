#Requires AutoHotkey v2.0

; =============================================================================
; ADXL355 Dual Sensor Automation Script
; F9 = Clear charts, scroll, set filename based on window title, AND start measurements
; F10 = Scroll, stop, extract path, scroll up, take screenshots
; =============================================================================

; Set title matching to exact match
SetTitleMatchMode(3)

; Hardcoded window titles
global isolatedTitle := "Producer/Consumer Design Pattern (Events)"
global nakedTitle := "[#] [EVAL] Producer/Consumer Design Pattern (Events) [#]"

; Default screenshot save path (fallback)
global defaultGraphPath := "C:\\Users\\cemat\\Desktop\\Studiprojekt_Vibrationssensor\\Sensor\\Graphs\\"

; Function to clear chart in a window
ClearChart(hwnd) {
    WinActivate(hwnd)
    Sleep(150)
    
    ; Right-click at 1066, 474 to open context menu
    MouseClick("Right", 1066, 474)
    Sleep(500)  ; Increased delay to ensure menu fully appears
    
    ; Left-click at 1155, 580 to click "clear chart" button
    MouseClick("Left", 1155, 580)
    Sleep(200)  ; Added delay after click to ensure it registers
}

; Function to scroll down and left in a window - FASTER VERSION
ScrollToButtons(hwnd) {
    WinActivate(hwnd)
    Sleep(150)
    
    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, hwnd)
    
    ; Move mouse to center of window before scrolling
    centerX := winX + (winWidth // 2)
    centerY := winY + (winHeight // 2)
    MouseMove(centerX, centerY)
    Sleep(100)
    
    ; Scroll down in one big scroll (21 notches = 7 scrolls of 3)
    Send("{WheelDown 21}")
    Sleep(200)
    
    ; Scroll left in one go (6 notches = 2 scrolls of 3)
    Send("{WheelLeft 6}")
    Sleep(150)
}

; Function to scroll back up in a window - FASTER VERSION
ScrollBackUp(hwnd) {
    WinActivate(hwnd)
    Sleep(150)
    
    ; Get window position and size
    WinGetPos(&winX, &winY, &winWidth, &winHeight, hwnd)
    
    ; Move mouse to center of window before scrolling
    centerX := winX + (winWidth // 2)
    centerY := winY + (winHeight // 2)
    MouseMove(centerX, centerY)
    Sleep(100)
    
    ; Scroll up in one big scroll (21 notches = 7 scrolls of 3)
    Send("{WheelUp 21}")
    Sleep(200)
}

; Function to extract file path from the window and convert Recordings -> Graphs
ExtractGraphPath(hwnd) {
    WinActivate(hwnd)
    Sleep(150)
    
    ; Triple-click on filepath field at 1065, 762 to select all
    MouseClick("Left", 1065, 762)
    Sleep(40)
    MouseClick("Left", 1065, 762)
    Sleep(40)
    MouseClick("Left", 1065, 762)
    Sleep(100)
    
    ; Copy the selected path
    Send("^c")
    Sleep(150)
    
    ; Get the path from clipboard
    recordingPath := A_Clipboard
    
    ; Replace "Recordings" with "Graphs"
    graphPath := StrReplace(recordingPath, "Recordings", "Graphs")
    
    ; Ensure path ends with backslash
    if (!RegExMatch(graphPath, "\\$")) {
        graphPath .= "\\"
    }
    
    return graphPath
}

; Function to create directory if it doesn't exist
EnsureDirectory(dirPath) {
    if (!DirExist(dirPath)) {
        try {
            DirCreate(dirPath)
            return true
        } catch {
            return false
        }
    }
    return true
}

; Function to take screenshot using PowerShell
TakeScreenshot(filepath) {
    ; Screenshot coordinates
    x := 178
    y := 344
    w := 1129  ; 1307 - 178
    h := 653   ; 997 - 344
    
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

; F9: Clear charts, scroll, set filename based on window title, AND start data capture
F9:: {
    relevantWindows := GetRelevantWindows()
    
    if (relevantWindows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    ; Generate timestamp for this measurement session
    global currentTimestamp := FormatTime(, "yyyyMMdd_HHmmss")
    
    ; === PHASE 0: CLEAR CHARTS IN ALL INSTANCES ===
    for window in relevantWindows {
        ClearChart(window.hwnd)
    }
    
    Sleep(200)
    
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
    ToolTip("✓ Charts cleared`n✓ Filenames set and measurement started`nTimestamp: " currentTimestamp "`nInstances: " relevantWindows.Length)
    SetTimer(() => ToolTip(), -3000)
}

; F10: Scroll, stop, extract path, scroll up, take screenshots
F10:: {
    relevantWindows := GetRelevantWindows()
    
    if (relevantWindows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    ; === PHASE 1: SCROLL TO BUTTONS AND EXTRACT PATHS ===
    windowPaths := []
    
    for window in relevantWindows {
        ; Scroll down to access buttons and filepath
        ScrollToButtons(window.hwnd)
        Sleep(200)
        
        ; Extract the graph path from filepath field
        graphPath := ExtractGraphPath(window.hwnd)
        
        ; Store window and its path
        obj := {}
        obj.hwnd := window.hwnd
        obj.title := window.title
        obj.graphPath := graphPath
        windowPaths.Push(obj)
        
        Sleep(150)
    }
    
    ; === PHASE 2: STOP DATA CAPTURE ===
    stoppedCount := 0
    
    for window in windowPaths {
        WinActivate(window.hwnd)
        Sleep(150)
        
        ; Click Stop button at screen position 1438, 826
        MouseClick("Left", 1438, 826)
        Sleep(200)
        
        stoppedCount++
    }
    
    ; Wait for stop to complete
    Sleep(300)
    
    ; === PHASE 3: SCROLL BACK UP IN ALL INSTANCES (ONE AT A TIME) ===
    for window in windowPaths {
        ScrollBackUp(window.hwnd)
        Sleep(300)  ; Extra wait after each scroll-up
    }
    
    ; Additional wait for all scrolling to settle
    Sleep(500)
    
    ; === PHASE 4: TAKE SCREENSHOTS (ONE AT A TIME WITH FULL FOCUS) ===
    screenshotCount := 0
    
    for window in windowPaths {
        ; Fully activate and focus the window
        WinActivate(window.hwnd)
        WinWaitActive(window.hwnd, , 2)  ; Wait up to 2 seconds for window to be active
        Sleep(300)
        
        ; Get prefix based on title
        prefix := GetPrefix(window.title)
        
        ; Create full filepath for screenshot
        graphPath := window.graphPath
        
        ; Ensure the directory exists
        if (EnsureDirectory(graphPath)) {
            ; Create filename
            filename := prefix "_" currentTimestamp "_screenshot.png"
            fullFilepath := graphPath . filename
            
            ; Take screenshot
            if (TakeScreenshot(fullFilepath)) {
                screenshotCount++
            }
        } else {
            MsgBox("Failed to create directory: " graphPath)
        }
        
        Sleep(400)  ; Longer wait between screenshots
    }
    
    ; Confirmation tooltip
    ToolTip("✓ Stopped " stoppedCount " sensor(s)`nData saved`nScreenshots: " screenshotCount)
    SetTimer(() => ToolTip(), -2500)
}

; ESC: Emergency exit
Esc::ExitApp
