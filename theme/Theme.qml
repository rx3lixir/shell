pragma Singleton
import QtQuick

QtObject {
    // ============================================================================
    // BASE PALETTE - Zinc Scale
    // ============================================================================
    // These are your neutral colors - when using matugen, these won't be used
    // directly but are here for manual theming
    
    readonly property color zinc50: "#fafafa"
    readonly property color zinc100: "#f4f4f5"
    readonly property color zinc200: "#e4e4e7"
    readonly property color zinc300: "#d4d4d8"
    readonly property color zinc400: "#a1a1aa"
    readonly property color zinc500: "#71717a"
    readonly property color zinc600: "#52525b"
    readonly property color zinc700: "#3f3f46"
    readonly property color zinc800: "#27272a"
    readonly property color zinc900: "#18181b"
    readonly property color zinc950: "#09090b"
    
    // ============================================================================
    // ACCENT PALETTE - Emerald (Primary)
    // ============================================================================
    
    readonly property color emerald50: "#ecfdf5"
    readonly property color emerald100: "#d1fae5"
    readonly property color emerald200: "#a7f3d0"
    readonly property color emerald300: "#6ee7b7"
    readonly property color emerald400: "#34d399"
    readonly property color emerald500: "#10b981"
    readonly property color emerald600: "#059669"
    readonly property color emerald700: "#047857"
    readonly property color emerald800: "#065f46"
    readonly property color emerald900: "#064e3b"
    readonly property color emerald950: "#022c22"
    
    // ============================================================================
    // SECONDARY PALETTE - Teal
    // ============================================================================
    
    readonly property color teal50: "#f0fdfa"
    readonly property color teal100: "#ccfbf1"
    readonly property color teal200: "#99f6e4"
    readonly property color teal300: "#5eead4"
    readonly property color teal400: "#2dd4bf"
    readonly property color teal500: "#14b8a6"
    readonly property color teal600: "#0d9488"
    readonly property color teal700: "#0f766e"
    readonly property color teal800: "#115e59"
    readonly property color teal900: "#134e4a"
    readonly property color teal950: "#042f2e"
    
    // ============================================================================
    // MATUGEN SEMANTIC TOKENS (Material Design 3)
    // ============================================================================
    // These are the EXACT tokens that matugen generates
    // When you run matugen, it will replace these values
    
    // --- Primary Colors (Main brand color - Emerald) ---
    readonly property color primary: emerald600
    readonly property color on_primary: zinc50
    readonly property color primary_container: emerald900
    readonly property color on_primary_container: emerald100
    readonly property color primary_fixed: emerald700
    readonly property color primary_fixed_dim: emerald800
    readonly property color on_primary_fixed: zinc950
    readonly property color on_primary_fixed_variant: emerald900
    
    // --- Secondary Colors (Supporting color - Teal) ---
    readonly property color secondary: teal600
    readonly property color on_secondary: zinc50
    readonly property color secondary_container: teal900
    readonly property color on_secondary_container: teal100
    readonly property color secondary_fixed: teal700
    readonly property color secondary_fixed_dim: teal800
    readonly property color on_secondary_fixed: zinc950
    readonly property color on_secondary_fixed_variant: teal900
    
    // --- Tertiary Colors (Third accent - Teal variant) ---
    readonly property color tertiary: teal500
    readonly property color on_tertiary: zinc50
    readonly property color tertiary_container: teal800
    readonly property color on_tertiary_container: teal50
    readonly property color tertiary_fixed: teal600
    readonly property color tertiary_fixed_dim: teal700
    readonly property color on_tertiary_fixed: zinc950
    readonly property color on_tertiary_fixed_variant: teal800
    
    // --- Error Colors ---
    readonly property color error: "#ef4444"
    readonly property color on_error: zinc50
    readonly property color error_container: "#7f1d1d"
    readonly property color on_error_container: "#fecaca"
    
    // --- Background Colors ---
    readonly property color background: zinc950
    readonly property color on_background: zinc100
    
    // --- Surface Colors (5-level elevation system) ---
    readonly property color surface: zinc950
    readonly property color on_surface: zinc100
    readonly property color surface_variant: zinc800
    readonly property color on_surface_variant: zinc400
    
    readonly property color surface_dim: zinc950
    readonly property color surface_bright: zinc700
    readonly property color surface_container_lowest: zinc950
    readonly property color surface_container_low: zinc900
    readonly property color surface_container: zinc900
    readonly property color surface_container_high: zinc800
    readonly property color surface_container_highest: zinc700
    
    // --- Outline Colors (Borders) ---
    readonly property color outline: zinc700
    readonly property color outline_variant: zinc800
    
    // --- Inverse Colors (for dark/light theme switching) ---
    readonly property color inverse_surface: zinc100
    readonly property color inverse_on_surface: zinc900
    readonly property color inverse_primary: emerald600
    
    // --- Scrim & Shadow ---
    readonly property color scrim: "#000000"
    readonly property color shadow: "#000000"
    
    // ============================================================================
    // CUSTOM EXTENSIONS (Not part of matugen, but useful)
    // ============================================================================
    // Add any custom tokens your app needs here
    // These won't be generated by matugen, so you manage them manually
    
    readonly property color primary_transparent: "#7710b981"
    readonly property color surface_transparent: "#AA09090b"
    readonly property color surface_container_transparent: "#AA18181b"
    readonly property color overlay: "#99000000"
    readonly property color scrim_transparent: "#66000000"
    
    // Extra status colors (not in MD3 spec)
    readonly property color success: emerald500
    readonly property color warning: "#f59e0b"
    readonly property color info: teal500
    
    // ============================================================================
    // SPACING SYSTEM
    // ============================================================================
    
    readonly property QtObject spacing: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 18
        readonly property int xl: 26 
        readonly property int xxl: 48
    }
    
    // ============================================================================
    // PADDING SYSTEM
    // ============================================================================
    
    readonly property QtObject padding: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 18
        readonly property int xl: 20
    }
    
    // ============================================================================
    // TYPOGRAPHY SYSTEM
    // ============================================================================
    
    readonly property QtObject typography: QtObject {
        readonly property string fontFamily: "Ubuntu Nerd Font Propo"
        
        readonly property int xs: 10
        readonly property int sm: 12
        readonly property int md: 14
        readonly property int lg: 16
        readonly property int xl: 18
        readonly property int xxl: 24
        readonly property int xxxl: 32
        
        readonly property int weightNormal: 400
        readonly property int weightMedium: 500
        readonly property int weightBold: 700
    }
    
    // ============================================================================
    // SHAPE SYSTEM (Border Radius)
    // ============================================================================
    
    readonly property QtObject radius: QtObject {
        readonly property int none: 0
        readonly property int sm: 6
        readonly property int md: 12
        readonly property int lg: 20
        readonly property int xl: 32 
        readonly property int xxl: 40
        readonly property int full: 9999
    }
    
    // ============================================================================
    // COMPONENT TOKENS
    // ============================================================================
    
    readonly property QtObject component: QtObject {
        readonly property int barHeight: 26
        readonly property int workspaceIndicatorSize: 10
        readonly property int buttonHeight: 36
        readonly property int inputHeight: 40
    }
    
    // ============================================================================
    // LEGACY ALIASES (for backward compatibility)
    // ============================================================================
    // Remove these after migrating your components to use the proper tokens
    
    readonly property color accent: primary
    readonly property color accentTransparent: primary_transparent
    readonly property color accentFixed: primary_fixed
    readonly property color bg0: surface
    readonly property color bg0transparent: surface_transparent
    readonly property color bg1: surface_container
    readonly property color bg1transparent: surface_container_transparent
    readonly property color bg2: surface_container_low
    readonly property color bgBright: surface_bright
    readonly property color bgDim: surface_dim
    readonly property color fg: on_surface
    readonly property color fgStrong: on_surface
    readonly property color fgMuted: on_surface_variant
    readonly property color border: outline
    readonly property color borderStrong: primary
    readonly property color borderDim: outline_variant
    readonly property color backgroundTransparent: surface_transparent
    
    // Spacing aliases
    readonly property int spacingXSmall: spacing.xs
    readonly property int spacingSmall: spacing.sm
    readonly property int spacingMedium: spacing.md
    readonly property int spacingLarge: spacing.lg
    readonly property int spacingXLarge: spacing.xl
    readonly property int spacingXS: spacing.xs
    readonly property int spacingS: spacing.sm
    readonly property int spacingM: spacing.md
    readonly property int spacingL: spacing.lg
    readonly property int spacingXL: spacing.xl
    
    // Margin aliases
    readonly property int marginXSmall: padding.xs
    readonly property int marginSmall: padding.sm
    readonly property int marginMedium: padding.md
    readonly property int marginLarge: padding.lg
    readonly property int marginXLarge: padding.xl
    readonly property int marginXS: padding.xs
    readonly property int marginS: padding.sm
    readonly property int marginM: padding.md
    readonly property int marginL: padding.lg
    readonly property int marginXL: padding.xl
    
    // Font aliases
    readonly property string fontFamily: typography.fontFamily
    readonly property int fontSizeXSmall: typography.xs
    readonly property int fontSizeSmall: typography.sm
    readonly property int fontSizeMedium: typography.md
    readonly property int fontSizeLarge: typography.lg
    readonly property int fontSizeXLarge: typography.xl
    readonly property int fontSizeXS: typography.xs
    readonly property int fontSizeS: typography.sm
    readonly property int fontSizeM: typography.md
    readonly property int fontSizeL: typography.lg
    readonly property int fontSizeXL: typography.xl
    
    // Radius aliases
    readonly property int radiusSmall: radius.sm
    readonly property int radiusMedium: radius.md
    readonly property int radiusLarge: radius.lg
    readonly property int radiusXLarge: radius.xl
    
    // Component aliases
    readonly property int barHeight: component.barHeight
    readonly property int workspaceIndicatorSize: component.workspaceIndicatorSize
}
