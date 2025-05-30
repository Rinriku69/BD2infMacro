

#Include %A_ScriptDir%\Gdip_All.ahk ; 
#Persistent
#SingleInstance Force
SetTitleMatchMode, 2
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen



; === GDI+ STARTUP ===

Global pToken 
pToken := Gdip_Startup()
if !pToken
{
    MsgBox, 16, GDI+ Error, GDI+ failed to start. Ensure Gdip_All.ahk is in the script directory and gdiplus.dll is accessible.
    ExitApp
}



; === CONFIGURABLE SETTINGS===

drawAgainX := 1462
drawAgainY := 999
skipX := 1765
skipY := 59



; ---  Image Search Settings ---

fiveStarImage := "FiveStar_Indicator.png"  
imageSearchVariation := "*50" ; Adjust tolerance 


; Amount of five-star characcters
requiredCount := 4



; --- Coordinates for Character Card Slots ---

numberOfSlotsToCheck := 10
slotTopY := 653          ; Y-coordinate for the TOP of where the STARS appear
slotBottomY := 674       ; Y-coordinate for the BOTTOM of where the STARS appear
firstSlotLeftX := 371    ; X-coordinate for the LEFT edge of the FIRST card's star area
slotWidth := 95          ; Width of the star area within ONE card slot
slotSpacing := 25        ; Horizontal pixel gap from the end of one star area to the start of the next
                         ; (Calculate as: start of slot 2 - (start of slot 1 + slotWidth) )



; === HOTKEY TO START/STOP ===

F9:: 
    Toggle := !Toggle
    if (Toggle) {
        ToolTip, Auto-pull started... Press F9 to stop
        SetTimer, AutoPull, 250 ; Run AutoPull a bit less aggressively
    } else {
        SetTimer, AutoPull, Off
        ToolTip, Script stopped.
        Sleep, 1000
        ToolTip
    }
return

; === DEBUG HOTKEY: TEST IMAGE SEARCH ===

F8::
    TestSlotNumber := 10 ; Change this to test different slots (1 to numberOfSlotsToCheck)
    
    ; Calculate coordinates for the slot being tested
    currentSlot_X1 := firstSlotLeftX + ((TestSlotNumber - 1) * (slotWidth + slotSpacing))
    currentSlot_Y1 := slotTopY
    currentSlot_X2 := currentSlot_X1 + slotWidth
    currentSlot_Y2 := slotBottomY

    ImageSearch, foundX, foundY, %currentSlot_X1%, %currentSlot_Y1%, %currentSlot_X2%, %currentSlot_Y2%, %imageSearchVariation% %fiveStarImage%
    if (ErrorLevel = 0) {
        MsgBox, Image FOUND in Slot %TestSlotNumber% at X%foundX% Y%foundY%
        ; Draw a green rectangle around the found image for 2 seconds
        CustomTooltip("Found!", foundX, foundY, foundX + ImageWidth(fiveStarImage), foundY + ImageHeight(fiveStarImage), "Green", 2000)
    } else if (ErrorLevel = 1) {
        MsgBox, Image NOT FOUND in Slot %TestSlotNumber%.`nEnsure '%fiveStarImage%' is correct & visible in area:`nX1:%currentSlot_X1%, Y1:%currentSlot_Y1%, X2:%currentSlot_X2%, Y2:%currentSlot_Y2%`nImage path: %A_ScriptDir%\%fiveStarImage%
        ; Draw a red rectangle where it searched for 2 seconds
        CustomTooltip("Not Found", currentSlot_X1, currentSlot_Y1, currentSlot_X2, currentSlot_Y2, "Red", 2000)
    } else {
        MsgBox, ErrorLevel %ErrorLevel% occurred. Cannot search for image. (Is image file missing or path wrong?)
    }
return

; Helper functions 

CustomTooltip(Text, x1, y1, x2, y2, Color, Timeout) { ; x1,y1 are top-left; x2,y2 are bottom-right
    Gui, CustomTooltip:New, +AlwaysOnTop -Caption +ToolWindow +LastFound +E0x20
    Gui, CustomTooltip:Color, %Color%
    Gui, CustomTooltip:Font, s10, Arial
    ; Removed vTooltipText from the line below as it's not used later for this control
    Gui, CustomTooltip:Add, Text, cWhite BackgroundTrans, %Text% 
    
    tooltip_w := x2 - x1
    tooltip_h := y2 - y1

    Gui, CustomTooltip:Show, NoActivate, x%x1% y%y1% w%tooltip_w% h%tooltip_h%
    
    if (Timeout > 0) {
        SetTimer, RemoveCustomTooltip, -%Timeout%
    }
    return

    RemoveCustomTooltip:
    Gui, CustomTooltip:Destroy
    return
}

; === ImageWidth and ImageHeight functions===
ImageWidth(imagePath) {
    local pBitmap, Width 
    pBitmap := Gdip_CreateBitmapFromFile(imagePath)
    if !pBitmap {
        ; ToolTip, GDI+ Error: Failed to load image (CreateBitmapFromFile) for ImageWidth - %imagePath%
        ; Sleep, 1000
        ; ToolTip
        Return 0 
    }
    
    Width := Gdip_GetImageWidth(pBitmap)  
    
    Gdip_DisposeImage(pBitmap)       
    Return Width
}

ImageHeight(imagePath) {
    local pBitmap, Height
    pBitmap := Gdip_CreateBitmapFromFile(imagePath)
    if !pBitmap {
        ; ToolTip, GDI+ Error: Failed to load image (CreateBitmapFromFile) for ImageHeight - %imagePath%
        ; Sleep, 1000
        ; ToolTip
        Return 0 
    }

    Height := Gdip_GetImageHeight(pBitmap) 

    Gdip_DisposeImage(pBitmap)         
    Return Height
}



; === MAIN FUNCTION ===

AutoPull:
    ;  Click Draw Again
    Click, %drawAgainX%, %drawAgainY%
    Sleep, 500

    ;  Press Enter to confirm 
    Send, {Enter}
    Sleep, 1000 ; Increased sleep slightly

    ;  Spam the Skip button
    Loop, 10 { ; Adjust loop count if more/less skips needed
        Click, %skipX%, %skipY%
        Sleep, 250 ; Slightly longer sleep, ensure clicks register
    }

    ;  Wait for results to fully load and animations to settle
    Sleep, 250 ; Adjust this time based on your game's loading

    ;  ImageSearch for 5-star results in defined slots
    foundCount := 0
    Loop, %numberOfSlotsToCheck% {
        ; Calculate coordinates for the current slot's star area
        currentSlot_X1 := firstSlotLeftX + ((A_Index - 1) * (slotWidth + slotSpacing))
        currentSlot_Y1 := slotTopY
        currentSlot_X2 := currentSlot_X1 + slotWidth
        currentSlot_Y2 := slotBottomY
        
        ImageSearch, fx, fy, %currentSlot_X1%, %currentSlot_Y1%, %currentSlot_X2%, %currentSlot_Y2%, %imageSearchVariation% %fiveStarImage%
        
        if (ErrorLevel = 0) {
            foundCount++
        }
        Sleep, 50 ; Small delay between checking each slot
    }

    ToolTip, Found %foundCount% of %requiredCount% five-stars. ; Update tooltip

    ;  Stop if enough 5-star found
    if (foundCount >= requiredCount) {
        SetTimer, AutoPull, Off ; Stop the timer/loop
        Toggle := false
        SoundBeep, 1000, 500 
        SoundFilePath := "Tuturu.mp3"
        SoundPlay, %SoundFilePath%, wait
        MsgBox, 64, Success!, 🎉 Found %foundCount% five-star characters! Script stopping.
        ToolTip ; Clear tooltip
        return
    }

    ;  Wait before repeating (if not enough found)
    Sleep, 250
return

; === GDI+ SHUTDOWN ===
OnExit:
    if pToken ; Only attempt shutdown if pToken was successfully created
        Gdip_Shutdown(pToken)
Exit
; --- END GDI+ SHUTDOWN ---