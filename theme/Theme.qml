pragma Singleton
import QtQuick

QtObject {
  readonly property color accent: "#FF7E9CD8"
  readonly property color accentTransparent: "#777E9CD8"
  readonly property color accentFixed: "#FF658594"
  readonly property color secondary: "#FF98BB6C"
  readonly property color secondaryFixed: "#FF76946A"
  readonly property color tertiary: "#FF7FB4CA"
  readonly property color tertiaryFixed: "#FF7AA89F"
  readonly property color bg0: "#FF16161D"
  readonly property color bg0transparent: "#FF16161D" 
  readonly property color bg1: "#FF1F1F28"
  readonly property color bg1transparent: "#FF1F1F28"
  readonly property color bg1transparentLauncher: "#FF1F1F28"
  readonly property color bg2: "#FF2A2A37"
  readonly property color bg2transparent: "#FF2A2A37"
  readonly property color bgBright: "#FF54546D"
  readonly property color bgDim: "#FF16161D"
  readonly property color error: "#FFE82424"
  readonly property color onerror: "#FF1F1F28"
  readonly property color fg: "#FFDCD7BA"
  readonly property color fgStrong: "#FFDCD7BA"
  readonly property color fgMuted: "#FF727169"
  readonly property color border: "#FF54546D"
  readonly property color borderStrong: "#FF957FB8"
  readonly property color borderDim: "#FF363646"
  readonly property color overlay: "#99000000"
  readonly property color scrim: "#66000000"
    
  // Convenient aliases for common uses
  readonly property color backgroundTransparent: "#6616161D"

  // Spacing (for gaps between elements)
  readonly property int spacingXSmall: 4
  readonly property int spacingSmall: 8
  readonly property int spacingMedium: 16
  readonly property int spacingLarge: 20
  readonly property int spacingXLarge: 24

  // Shorter aliases
  readonly property int spacingXS: spacingXSmall
  readonly property int spacingS: spacingSmall
  readonly property int spacingM: spacingMedium
  readonly property int spacingL: spacingLarge
  readonly property int spacingXL: spacingXLarge
    
  // Margins (for outer padding)
  readonly property int marginXSmall: 4
  readonly property int marginSmall: 8
  readonly property int marginMedium: 12
  readonly property int marginLarge: 16
  readonly property int marginXLarge: 18

  // Shorter aliases
  readonly property int marginXS: marginXSmall
  readonly property int marginS: marginSmall
  readonly property int marginM: marginMedium
  readonly property int marginL: marginLarge
  readonly property int marginXL: marginXLarge
    
  // Font
  readonly property string fontFamily: "Ubuntu Nerd Font Propo"
  readonly property int fontSizeXSmall: 8
  readonly property int fontSizeSmall: 12
  readonly property int fontSizeMedium: 14
  readonly property int fontSizeLarge: 16
  readonly property int fontSizeXLarge: 18

  // Shorter aliases
  readonly property int fontSizeXS: fontSizeXSmall
  readonly property int fontSizeS: fontSizeSmall
  readonly property int fontSizeM: fontSizeMedium
  readonly property int fontSizeL: fontSizeLarge
  readonly property int fontSizeXL: fontSizeXLarge
    
  // Sizing
  readonly property int barHeight: 24
  readonly property int workspaceIndicatorSize: 10
    
  // Border Radius
  readonly property int radiusSmall: 3
  readonly property int radiusMedium: 6
  readonly property int radiusLarge: 8
  readonly property int radiusXLarge: 14
}
