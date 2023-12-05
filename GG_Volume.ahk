; ╔═════════════════╗
; ║   Uses AHK v2   ║
; ╚═════════════════╝

#Warn All
#SingleInstance Ignore
SendMode "Input"

; ╔═════════════════════════════════════════════════════════════════════╗
; ║ Change volume amount here, as desired. 0.0 = 0%, 1.0 = 100% volume. ║
; ║ Ordered as in the GG Sonar Mixer settings                           ║
; ║ --> Game, Chat, Media, Aux                                          ║
; ╚═════════════════════════════════════════════════════════════════════╝

Profiles := {
    Game: [ 1.0, 0.5, 0.3, 0.1 ],
    Chat: [ 0.1, 1.0, 0.3, 0.5 ],
    Media: [ 0.1, 0.5, 1.0, 0.3 ],
    Aux: [ 0.3, 0.5, 0.1, 1.0 ],
    None: [ 1.0, 1.0, 1.0, 1.0 ]
}

; ╔═════════════════════════════════════════════════════════════════════════════════════╗
; ║ May need to change the pixel values here, since screen resolution may be different. ║
; ║ These are in Client coordinate mode, if using the AHKv2 Window Spy tool.            ║
; ╚═════════════════════════════════════════════════════════════════════════════════════╝

GGLocations := {
    SonarTab: { X: 178, Y: 226 },
    MixerTab: { X: 381, Y: 158 },
    CloseButton: { X: 1520, Y: 18 },
    MasterMute: { X: 469, Y: 614 },
    Volume100: 326,
    Volume0: 582,
    ChannelsX: [ 667, 847, 1027, 1207 ]
}

; ╔═══════════════════════════════════════════════════════════════════════════════════╗
; ║ If SteelSeries GG was installed to a non-standard location, change this variable. ║
; ╚═══════════════════════════════════════════════════════════════════════════════════╝

GGPath := "C:\Program Files\SteelSeries\GG\SteelSeriesGGClient.exe"


; ╔══════════════════════════════════════════╗
; ║   NO CHANGE NECESSARY BELOW THIS POINT   ║
; ╚══════════════════════════════════════════╝

GGWindow := "SteelSeries GG"

GGClick(x, y?) {
    if IsSet(y)
        coord := "x" x " y" y
    else
        coord := "x" x.X " y" x.Y
    
    ControlClick coord, GGWindow
}

SetVolume(profile) {
    volRange := GGLocations.Volume0 - GGLocations.Volume100
    For v in profile {
        y := GGLocations.Volume0 - v * volRange
        GGClick(GGLocations.ChannelsX[A_Index], y), GGWindow
        Sleep 200
    }

    if CloseGG.Value
        GGClick(GGLocations.CloseButton)

}

SwitchWindow() {
    if not WinExist(GGWindow) {
        Run GGPath
        Sleep 4000
    }

    GGClick(GGLocations.SonarTab), GGWindow
    Sleep 200
    GGClick(GGLocations.MixerTab), GGWindow
    Sleep 100
}

SwitchProfile(btn, info) {
    SwitchWindow()
    profile := Profiles.%btn.Text%
    SetVolume(profile)
}

ToggleMute(btn, info) {
    SwitchWindow()
    GGClick(GGLocations.MasterMute)
    btn.Text := (btn.Text == "Mute" ? "Unmute" : "Mute")
}

VolumeGui := Gui("AlwaysOnTop ToolWindow")

For Name in Profiles.OwnProps() {
    btn := VolumeGui.Add("Button", "w150 h50", Name)
    btn.OnEvent("Click", SwitchProfile)
}

MuteBtn := VolumeGui.Add("Button", "vMuteBtn w150 h50", "Mute")
MuteBtn.OnEvent("Click", ToggleMute)
CloseGG := VolumeGui.Add("CheckBox", "vCloseGG", "Close GG when done")

VolumeGui.Show