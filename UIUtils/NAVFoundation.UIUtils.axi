#IF_NOT_DEFINED __NAV_FOUNDATION_UIUTILS__
#DEFINE __NAV_FOUNDATION_UIUTILS__

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT


DEFINE_TYPE

////////////////////////////////////////////////////////////
// Button
////////////////////////////////////////////////////////////
struct _NAVUIButton {
    char Label[NAV_MAX_CHARS]
    char Bitmap[NAV_MAX_CHARS]
    integer Icon
    integer Enabled
    integer Hidden
    integer Channel
    integer Address
}


define_function NAVShowButtonArray(dev device[], integer address, integer state) {
    NAVCommandArray(device, "'^SHO-', itoa(address), ',', itoa(state)")
}


define_function NAVShowButton(dev device, integer address, integer state) {
    NAVCommand(device, "'^SHO-', itoa(address), ',', itoa(state)")
}


define_function NAVEnableButtonArray(dev device[], integer address, integer state) {
    NAVCommandArray(device, "'^ENA-', itoa(address), ',', itoa(state)")
}


define_function NAVEnableButton(dev device, integer address, integer state) {
    NAVCommand(device, "'^ENA-', itoa(address), ',', itoa(state)")
}


define_function NAVPageArray(dev device[], char page[]) {
    NAVCommandArray(device, "'PAGE-', page")
}


define_function NAVPage(dev device, char page[]) {
    NAVCommand(device, "'PAGE-', page")
}


define_function NAVPopupShowArray(dev device[], char popup[], char page[]) {
    if (!length_array(popup)) {
        return
    }

    if(length_array(page)) {
        NAVCommandArray(device, "'@PPN-', popup, ';', page")
        return
    }

    NAVCommandArray(device, "'@PPN-', popup")
}


define_function NAVPopupShow(dev device, char popup[], char page[]) {
    if (!length_array(popup)) {
        return
    }

    if(length_array(page)) {
        NAVCommand(device, "'@PPN-', popup,';', page")
        return
    }

    NAVCommand(device, "'@PPN-', popup")
}


define_function NAVPopupHideArray(dev device[], char popup[], char page[]) {
    if (!length_array(popup)) {
        return
    }

    if(length_array(page)) {
        NAVCommandArray(device, "'@PPF-', popup, ';', page")
        return
    }

    NAVCommandArray(device, "'@PPF-', popup")
}


define_function NAVPopupHide(dev device, char popup[], char page[]) {
    if (!length_array(popup)) {
        return
    }

    if(length_array(page)) {
        NAVCommand(device, "'@PPF-', popup, ';', page")
        return
    }

    NAVCommand(device, "'@PPF-', popup")
}


define_function NAVPopupKillArray(dev device[], char popup[]) {
    NAVCommandArray(device, "'@PPK-', popup")
}


define_function NAVPopupKill(dev device, char popup[]) {
    NAVCommand(device, "'@PPK-', popup")
}


define_function NAVPopupsClearArray(dev device[]) {
    NAVCommandArray(device, "'@PPX'")
}


define_function NAVPopupsClear(dev device) {
    NAVCommand(device, "'@PPX'")
}


define_function NAVTextArray(dev device[], integer address, char states[], char text[]) {
    NAVCommandArray(device, "'^TXT-', itoa(address), ',', states, ',', text")
}


define_function NAVText(dev device, integer address, char states[], char text[]) {
    NAVCommand(device, "'^TXT-', itoa(address), ',', states, ',', text")
}


define_function NAVDoubleBeepArray(dev device[]) {
    NAVCommandArray(device, "'ADBEEP'")
}


define_function NAVDoubleBeep(dev device) {
    NAVCommand(device, "'ADBEEP'")
}


define_function NAVBeepArray(dev device[]) {
    NAVCommandArray(device, "'ABEEP'")
}


define_function NAVBeep(dev device) {
    NAVCommand(device, "'ABEEP'")
}


#END_IF /* __NAV_FOUNDATION_UIUTILS__ */
