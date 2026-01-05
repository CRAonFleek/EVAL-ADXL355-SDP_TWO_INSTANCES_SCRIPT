#Requires AutoHotkey v2.0

; =============================================================================
; ADXL355 Dual Sensor Automation Script
; F9 = Scroll, set filename based on window title, AND start measurements
; F10 = Scroll AND stop measurements
; F11 = Scroll to bottom-left to access buttons
; =============================================================================

; Hardcoded window titles
global isolatedTitle := "Producer/Consumer Design Pattern (Events)"
global nakedTitle := "[EVAL] Producer/Consumer Design Pattern (Events)"

; Function to scroll down and left in a window
ScrollToButtons(hwnd) {
    WinActivate(hwnd)
    Sleep(150)
    
    ; Scroll down 7 times (wheel down)
    Loop 7 {
        Send("{WheelDown 3}")
        Sleep(100)
    }
    
    ; Scroll left 2 times (wheel left)
    Loop 2 {
        Send("{WheelLeft 3}")
        Sleep(100)
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
    
    ; Try to find Isolated instance
    isolatedHwnd := WinExist(isolatedTitle)
    if (isolatedHwnd) {
        relevantWindows.Push(isolatedHwnd)
    }
    
    ; Try to find Naked instance
    nakedHwnd := WinExist(nakedTitle)
    if (nakedHwnd) {
        relevantWindows.Push(nakedHwnd)
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
    timestamp := FormatTime(, "yyyyMMdd_HHmmss")
    
    ; === SCROLL TO BUTTONS IN ALL INSTANCES ===
    for hwnd in relevantWindows {
        ScrollToButtons(hwnd)
    }
    
    Sleep(300)
    
    ; === PREP FILENAMES IN ALL INSTANCES ===
    for hwnd in relevantWindows {
        WinActivate(hwnd)
        Sleep(150)
        
        ; Get window title to determine prefix
        WinGetTitle(&title, hwnd)
        prefix := GetPrefix(title)
        
        ; Triple-click on filename field at 918, 835 to select all
        MouseClick("Left", 918, 835)
        Sleep(50)
        MouseClick("Left", 918, 835)
        Sleep(50)
        MouseClick("Left", 918, 835)
        Sleep(100)
        
        ; Generate filename and copy to clipboard
        filename := prefix "_" timestamp ".txt"
        A_Clipboard := filename
        Sleep(50)
        
        ; Paste filename with Ctrl+V
        Send("^v")
        Sleep(150)
    }
    
    ; Wait for all filenames to be set
    Sleep(500)
    
    ; === START DATA CAPTURE ===
    for hwnd in relevantWindows {
        WinActivate(hwnd)
        Sleep(150)
        
        ; Click Start button at screen position 1439, 718
        MouseClick("Left", 1439, 718)
        Sleep(200)
    }
    
    ; Confirmation tooltip
    ToolTip("✓ Filenames set and measurement started`nTimestamp: " timestamp "`nInstances: " relevantWindows.Length)
    SetTimer(() => ToolTip(), -3000)
}

; F10: Scroll AND stop data capture in both instances
F10:: {
    relevantWindows := GetRelevantWindows()
    
    if (relevantWindows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    ; === SCROLL TO BUTTONS IN ALL INSTANCES ===
    for hwnd in relevantWindows {
        ScrollToButtons(hwnd)
    }
    
    Sleep(300)
    
    stoppedCount := 0
    
    ; === STOP DATA CAPTURE ===
    for hwnd in relevantWindows {
        WinActivate(hwnd)
        Sleep(150)
        
        ; Click Stop button at screen position 1438, 826
        MouseClick("Left", 1438, 826)
        Sleep(300)
        
        stoppedCount++
    }
    
    ; Confirmation tooltip
    ToolTip("✓ Stopped " stoppedCount " sensor(s)`nData saved")
    SetTimer(() => ToolTip(), -2000)
}

; F11: Scroll to bottom-left to access buttons (standalone)
F11:: {
    relevantWindows := GetRelevantWindows()
    
    if (relevantWindows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    for hwnd in relevantWindows {
        ScrollToButtons(hwnd)
    }
    
    ToolTip("✓ Scrolled to buttons")
    SetTimer(() => ToolTip(), -2000)
}

; ESC: Emergency exit
Esc::ExitApp
