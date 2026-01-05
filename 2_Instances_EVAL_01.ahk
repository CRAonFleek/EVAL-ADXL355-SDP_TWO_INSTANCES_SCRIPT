#Requires AutoHotkey v2.0

; =============================================================================
; ADXL355 Dual Sensor Automation Script
; F9 = Set filename (triple-click + paste) AND start measurements
; F10 = Stop measurements in both instances
; F11 = Scroll GUI to bottom-left to access buttons
; =============================================================================

global windowTitle := "Producer/Consumer Design Pattern (Events)"

; F11: Scroll to bottom-left to access buttons
F11:: {
    windows := WinGetList(windowTitle)
    
    if (windows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    for hwnd in windows {
        WinActivate("ahk_id " hwnd)
        Sleep(150)
        
        ; Scroll down 4 times (wheel down)
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
    
    ToolTip("✓ Scrolled to buttons")
    SetTimer(() => ToolTip(), -2000)
}

; F9: Set filename AND start data capture in both instances
F9:: {
    windows := WinGetList(windowTitle)
    
    if (windows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    ; Generate timestamp for this measurement session
    timestamp := FormatTime(, "yyyyMMdd_HHmmss")
    
    ; Define prefixes for each instance
    prefixes := ["Isolated", "Naked"]
    instanceNum := 1
    
    ; === PREP FILENAMES IN ALL INSTANCES ===
    for hwnd in windows {
        WinActivate("ahk_id " hwnd)
        Sleep(150)
        
        ; Triple-click on filename field at 918, 835 to select all
        MouseClick("Left", 918, 835)
        Sleep(50)
        MouseClick("Left", 918, 835)
        Sleep(50)
        MouseClick("Left", 918, 835)
        Sleep(100)
        
        ; Generate filename with prefix and copy to clipboard
        prefix := prefixes[instanceNum]
        filename := prefix "_" timestamp ".txt"
        A_Clipboard := filename
        Sleep(50)
        
        ; Paste filename with Ctrl+V
        Send("^v")
        Sleep(150)
        
        instanceNum++
    }
    
    ; Wait for all filenames to be set
    Sleep(500)
    
    ; === START DATA CAPTURE ===
    instanceNum := 1
    for hwnd in windows {
        WinActivate("ahk_id " hwnd)
        Sleep(150)
        
        ; Click Start button at screen position 1439, 718
        MouseClick("Left", 1439, 718)
        Sleep(200)
        
        instanceNum++
    }
    
    ; Confirmation tooltip
    ToolTip("✓ Filenames set and measurement started`nTimestamp: " timestamp "`nInstances: " windows.Length)
    SetTimer(() => ToolTip(), -3000)
}

; F10: Stop Data Capture in both instances
F10:: {
    windows := WinGetList(windowTitle)
    
    if (windows.Length = 0) {
        MsgBox("No ADXL355 software windows found!")
        return
    }
    
    stoppedCount := 0
    
    for hwnd in windows {
        WinActivate("ahk_id " hwnd)
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

; ESC: Emergency exit
Esc::ExitApp
