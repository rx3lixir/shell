import QtQuick

QtObject {
    // Colors
    readonly property color backgroundTransparent: "#80000000"
    readonly property color white: "#ffffff"
    readonly property color whiteTransparent: "#50ffffff"
    
    // Margins
    readonly property int marginSmall: 6
    readonly property int marginMedium: 10
    readonly property int marginLarge: 20
    
    // Font
    readonly property string fontFamily: "Ubuntu Nerd Font"
    readonly property int fontSizeIcon: 24
    
    // Sizing
    readonly property int osdWidth: 200
    readonly property int osdHeight: 50
    readonly property int iconSize: 28
    readonly property int progressBarHeight: 6
    
    // Border Radius
    readonly property int radiusSmall: 3
    
    // Animation
    readonly property int animationDuration: 100
}
