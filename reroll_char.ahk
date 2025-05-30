#Include %A_ScriptDir%\Gdip_All.ahk 
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

; --- IMPORTANT: Image Search Settings ---
fiveStarImage := "FiveStar_Indicator.png" 
; --- NEW: Separate Variation Settings ---
fiveStar_imageSearchVariation := "*50"  ; <<< SET THIS to the best variation for your 5-star indicator (e.g., *50, *60)
targetChar_imageSearchVariation := "*165" ; <<< This is the value you found for your target character

; --- specific target character ---
targetCharacterImage := "target3.png" 
requiredCount := 1 ; Amount of five-star characcter you need

; --- IMPORTANT: Coordinates for Character Card Slots(Star) ---
numberOfSlotsToCheck := 10
slotTopY := 653          
slotBottomY := 674       
firstSlotLeftX := 371    
slotWidth := 95          
slotSpacing := 25        

; --- Coordinates for Character Card Slots (TARGET CHARACTER IMAGE) ---
targetChar_slotTopY := 415       
targetChar_slotBottomY := 653    
targetChar_firstSlotLeftX := 371 
targetChar_slotWidth := 97       


; === HOTKEY TO START/STOP ===
F9:: 
    Toggle := !Toggle
    if (Toggle) {
        ToolTip, Auto-pull started... Press F9 to stop
        SetTimer, AutoPull, 250 
    } else {
        SetTimer, AutoPull, Off
        ToolTip, Script stopped.
        Sleep, 1000
        ToolTip
    }
return

; === DEBUG HOTKEY: TEST IMAGE SEARCH FOR ONE SLOT ===
F8::
    TestSlotNumber := 5 
    
    ;-----------------------------------------------------------------------------------
    ; CHOOSE WHICH IMAGE TO TEST (manage by commenting/uncommenting /* ... */ blocks)
    ;-----------------------------------------------------------------------------------

    ; --- Block 1: TESTING 5-STAR INDICATOR ---
    /* 
    MsgBox, 64, Debug Mode, Testing for 5-Star Indicator in Slot %TestSlotNumber%
    debug_Search_X1 := firstSlotLeftX + ((TestSlotNumber - 1) * (slotWidth + slotSpacing))
    debug_Search_Y1 := slotTopY
    debug_Search_X2 := debug_Search_X1 + slotWidth
    debug_Search_Y2 := slotBottomY
    debug_ImageFile := fiveStarImage
    debug_ImageNameForMsg := "5-Star Indicator (" . fiveStarImage . ")"
    debug_CurrentVariation := fiveStar_imageSearchVariation ; Use 5-star variation
    debug_ImageForTooltipWidth := ImageWidth(fiveStarImage)  
    debug_ImageForTooltipHeight := ImageHeight(fiveStarImage) 
    */

    ; --- Block 2: TESTING TARGET CHARACTER ---
    ;/* 
    MsgBox, 64, Debug Mode, Testing for Target Character in Slot %TestSlotNumber%
    debug_Search_X1 := targetChar_firstSlotLeftX + ((TestSlotNumber - 1) * (targetChar_slotWidth + slotSpacing))
    debug_Search_Y1 := targetChar_slotTopY
    debug_Search_X2 := debug_Search_X1 + targetChar_slotWidth
    debug_Search_Y2 := targetChar_slotBottomY
    debug_ImageFile := targetCharacterImage
    debug_ImageNameForMsg := "Target Character (" . targetCharacterImage . ")"
    debug_CurrentVariation := targetChar_imageSearchVariation ; Use target char variation
    debug_ImageForTooltipWidth := ImageWidth(targetCharacterImage)  
    debug_ImageForTooltipHeight := ImageHeight(targetCharacterImage) 
    ;*/

    ; --- Common ImageSearch Logic (uses the debug_ variables set in the active block above) ---
    if (debug_ImageFile = "") { 
        MsgBox, 16, F8 Error, No debug block is active or debug_ImageFile not set. Please edit the F8 hotkey comments.
        return
    }

    ImageSearch, foundX, foundY, %debug_Search_X1%, %debug_Search_Y1%, %debug_Search_X2%, %debug_Search_Y2%, %debug_CurrentVariation% %debug_ImageFile% ; MODIFIED to use debug_CurrentVariation
    if (ErrorLevel = 0) {
        MsgBox, 64, F8 Test Result, Image '%debug_ImageNameForMsg%' FOUND (Var: %debug_CurrentVariation%) in Slot %TestSlotNumber% at X%foundX% Y%foundY%
        CustomTooltip("Found!", foundX, foundY, foundX + debug_ImageForTooltipWidth, foundY + debug_ImageForTooltipHeight, "Green", 2000)
    } else if (ErrorLevel = 1) {
        MsgBox, 16, F8 Test Result, Image '%debug_ImageNameForMsg%' NOT FOUND (Var: %debug_CurrentVariation%) in Slot %TestSlotNumber%.`nEnsure image is correct & visible in area:`nX1:%debug_Search_X1%, Y1:%debug_Search_Y1%, X2:%debug_Search_X2%, Y2:%debug_Search_Y2%`nImage path: %A_ScriptDir%\%debug_ImageFile%
        CustomTooltip("Not Found", debug_Search_X1, debug_Search_Y1, debug_Search_X2, debug_Search_Y2, "Red", 2000)
    } else {
        MsgBox, 16, F8 Test Result, ErrorLevel %ErrorLevel% occurred for '%debug_ImageNameForMsg%'. Cannot search. (Image file missing/path wrong?)
    }
return

; Helper functions for debug tooltip (remains the same)
CustomTooltip(Text, x1, y1, x2, y2, Color, Timeout) { 
    Gui, CustomTooltip:New, +AlwaysOnTop -Caption +ToolWindow +LastFound +E0x20
    Gui, CustomTooltip:Color, %Color%
    Gui, CustomTooltip:Font, s10, Arial
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

; ImageWidth and ImageHeight functions (remains the same)
ImageWidth(imagePath) {
    local pBitmap, Width 
    pBitmap := Gdip_CreateBitmapFromFile(imagePath)
    if !pBitmap {
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
        Return 0 
    }
    Height := Gdip_GetImageHeight(pBitmap) 
    Gdip_DisposeImage(pBitmap)    
    Return Height
}

; === MAIN FUNCTION ===
AutoPull:
    ; Step 1 & 2 (Clicks, Enter - remains the same)
    Click, %drawAgainX%, %drawAgainY%
    Sleep, 500
    Send, {Enter}
    Sleep, 1000 

    ; Step 3 (Skip button - remains the same)
    Loop, 10 { 
        Click, %skipX%, %skipY%
        Sleep, 250 
    }

    ; IMPORTANT: Wait for results (remains the same)
    Sleep, 3000 

    ; Step 4: ImageSearch for 5-star results AND the specific target character
    foundCount := 0
    targetCharacterFoundThisPull := false 

    Loop, %numberOfSlotsToCheck% {
        ; --- Coordinates for STAR search ---
        starSearch_X1 := firstSlotLeftX + ((A_Index - 1) * (slotWidth + slotSpacing))
        starSearch_Y1 := slotTopY
        starSearch_X2 := starSearch_X1 + slotWidth
        starSearch_Y2 := slotBottomY
        
        ImageSearch, fx, fy, %starSearch_X1%, %starSearch_Y1%, %starSearch_X2%, %starSearch_Y2%, %fiveStar_imageSearchVariation% %fiveStarImage% ; MODIFIED
        if (ErrorLevel = 0) {
            foundCount++
        }

        ; --- Coordinates for TARGET CHARACTER search ---
        ; MODIFIED: Corrected pitch calculation to use targetChar_slotWidth
        targetCharSearch_X1 := targetChar_firstSlotLeftX + ((A_Index - 1) * (targetChar_slotWidth + slotSpacing)) 
        targetCharSearch_Y1 := targetChar_slotTopY
        targetCharSearch_X2 := targetCharSearch_X1 + targetChar_slotWidth
        targetCharSearch_Y2 := targetChar_slotBottomY

        if (!targetCharacterFoundThisPull) {
            ImageSearch, target_fx, target_fy, %targetCharSearch_X1%, %targetCharSearch_Y1%, %targetCharSearch_X2%, %targetCharSearch_Y2%, %targetChar_imageSearchVariation% %targetCharacterImage% ; MODIFIED
            if (ErrorLevel = 0) {
                targetCharacterFoundThisPull := true
            }
        }
        Sleep, 50 
    }

    ; Tooltip update (remains the same)
    ToolTipText := "5-Stars: " . foundCount . "/" . requiredCount
    if (targetCharacterFoundThisPull) {
        ToolTipText .= " | Target Char: FOUND!"
    } else {
        ToolTipText .= " | Target Char: Not found"
    }
    ToolTip, %ToolTipText%

    ; Step 5: Stop condition (remains the same)
    if (foundCount >= requiredCount or targetCharacterFoundThisPull) { 
        SetTimer, AutoPull, Off 
        Toggle := false
        
        SuccessMsg := ""
        if (targetCharacterFoundThisPull) {
            SuccessMsg := "🎉 Found the target character!"
            if (foundCount >= requiredCount) { 
                SuccessMsg .= "`nAlso met 5-star count: " . foundCount . "."
            } else { 
                 SuccessMsg .= "`n(Current 5-star count: " . foundCount . "/" . requiredCount . ")"
            }
        } else { 
            SuccessMsg := "🎉 Found " . foundCount . " of " . requiredCount . " five-star characters!"
        }
        
        SoundBeep, 1000, 500 
        SoundBeep, 1000, 500
        MsgBox, 64, Success!, %SuccessMsg%`nScript stopping.
        ToolTip 
        return
    }

    ; Step 6: Wait (remains the same)
    Sleep, 1000
return

; === GDI+ SHUTDOWN === (remains the same)
OnExit:
    if pToken 
        Gdip_Shutdown(pToken)
Exit