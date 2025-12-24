pragma Singleton

import QtQuick

QtObject {
  // Colors
  readonly property color accent: "#7E9CD8"
  readonly property color accentFixed: "#658594"
  readonly property color secondary: "#98BB6C"
  readonly property color secondaryFixed: "#76946A"
  readonly property color tertiary: "#7FB4CA"
  readonly property color tertiaryFixed: "#7AA89F"
  readonly property color bg0: "#16161D"
  readonly property color bg1: "#1F1F28"
  readonly property color bg2: "#2A2A37"
  readonly property color bgBright: "#54546D"
  readonly property color bgDim: "#16161D"
  readonly property color error: "#E82424"
  readonly property color onError: "#1F1F28"
  readonly property color fg: "#DCD7BA"
  readonly property color fgStrong: "#DCD7BA"
  readonly property color fgMuted: "#727169"
  readonly property color border: "#54546D"
  readonly property color borderStrong: "#957FB8"
  readonly property color borderDim: "#363646"
  readonly property color overlay: "#000000"
  readonly property color scrim: "#000000"
  
  // Convenient aliases for common uses
  readonly property color backgroundTransparent: "transparent"
    
  // Spacing (for gaps between elements)
  readonly property int spacingXSmall: 4
  readonly property int spacingSmall: 8
  readonly property int spacingMedium: 12
  readonly property int spacingLarge: 16
  readonly property int spacingXLarge: 18
  
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
  readonly property string fontFamily: "Ubuntu Nerd Font"
  readonly property int fontSizeXSmall: 8
  readonly property int fontSizeSmall: 10
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
  readonly property int barHeight: 26
  readonly property int workspaceIndicatorSize: 12
    
  // Border Radius
  readonly property int radiusSmall: 3
  readonly property int radiusMedium: 6
  readonly property int radiusLarge: 8
}
