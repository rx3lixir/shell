import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components"

LazyLoader {
  id: loader
  
  required property var manager
  required property var systemState
  
  active: manager.visible
  
  WlSessionLock {
    id: sessionLock
    
    // Lock the session when manager becomes visible
    locked: manager.visible
    
    WlSessionLockSurface {
      // This creates a surface for each monitor
      
      color: "transparent"
      
      // Prevent clicks from going through
      MouseArea {
        anchors.fill: parent
        onClicked: {} // Consume clicks
      }
      
      // Main lockscreen container
      Rectangle {
        anchors.fill: parent
        color: Theme.surface_dim
        
        ColumnLayout {
          anchors.centerIn: parent
          spacing: Theme.spacing.xl
          width: 400
          
          // ========== TIME DISPLAY ==========
          ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spacing.xs
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: Qt.formatTime(new Date(), "hh:mm")
              color: Theme.on_surface
              font.pixelSize: 72
              font.family: Theme.typography.fontFamily
              font.weight: Theme.typography.weightBold
              
              Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: parent.text = Qt.formatTime(new Date(), "hh:mm")
              }
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: Qt.formatDate(new Date(), "dddd, MMMM d")
              color: Theme.on_surface_variant
              font.pixelSize: Theme.typography.lg
              font.family: Theme.typography.fontFamily
              opacity: 0.8
            }
          }
          
          // ========== PASSWORD INPUT ==========
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            Layout.topMargin: Theme.spacing.xl
            
            radius: Theme.radius.full
            color: Theme.surface_container
            border.width: loader.manager.authFailed ? 2 : 1
            border.color: loader.manager.authFailed 
                         ? Theme.error 
                         : (passwordInput.activeFocus 
                           ? Theme.primary 
                           : Theme.outline)
            
            Behavior on border.color {
              ColorAnimation { duration: 200 }
            }
            
            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: Theme.padding.lg
              anchors.rightMargin: Theme.padding.lg
              spacing: Theme.spacing.md
              
              // Lock icon
              Text {
                text: loader.manager.authFailed ? "󰍁" : "󰌾"
                color: loader.manager.authFailed ? Theme.error : Theme.primary
                font.pixelSize: Theme.typography.xl
                font.family: Theme.typography.fontFamily
                
                Behavior on text {
                  enabled: false
                }
                
                Behavior on color {
                  ColorAnimation { duration: 200 }
                }
              }
              
              // Password input
              TextInput {
                id: passwordInput
                Layout.fillWidth: true
                
                echoMode: TextInput.Password
                color: Theme.on_surface
                font.pixelSize: Theme.typography.lg
                font.family: Theme.typography.fontFamily
                verticalAlignment: TextInput.AlignVCenter
                
                enabled: !loader.manager.authenticating
                
                // Placeholder
                Text {
                  anchors.fill: parent
                  text: loader.manager.authFailed 
                       ? "Authentication failed - try again" 
                       : "Enter password"
                  color: loader.manager.authFailed ? Theme.error : Theme.on_surface_variant
                  font: passwordInput.font
                  verticalAlignment: Text.AlignVCenter
                  visible: !passwordInput.text
                  opacity: 0.6
                  
                  Behavior on color {
                    ColorAnimation { duration: 200 }
                  }
                }
                
                // Submit on Enter
                Keys.onReturnPressed: submitPassword()
                Keys.onEnterPressed: submitPassword()
                
                // Clear error state when typing
                onTextChanged: {
                  if (loader.manager.authFailed) {
                    loader.manager.authFailed = false
                  }
                }
                
                Component.onCompleted: {
                  forceActiveFocus()
                }
              }
              
              // Submit button / Loading indicator
              Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                
                // Loading spinner
                Text {
                  anchors.centerIn: parent
                  text: "󰔟"
                  color: Theme.primary
                  font.pixelSize: Theme.typography.xl
                  font.family: Theme.typography.fontFamily
                  visible: loader.manager.authenticating
                  
                  RotationAnimator on rotation {
                    running: loader.manager.authenticating
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                  }
                }
                
                // Submit arrow (when not authenticating)
                Text {
                  anchors.centerIn: parent
                  text: "󰁔"
                  color: passwordInput.text ? Theme.primary : Theme.outline
                  font.pixelSize: Theme.typography.xl
                  font.family: Theme.typography.fontFamily
                  visible: !loader.manager.authenticating
                  opacity: passwordInput.text ? 1.0 : 0.3
                  
                  Behavior on opacity {
                    NumberAnimation { duration: 150 }
                  }
                  
                  MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: passwordInput.text ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: passwordInput.text && !loader.manager.authenticating
                    onClicked: submitPassword()
                  }
                }
              }
            }
          }
          
          // ========== ERROR MESSAGE ==========
          Text {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.sm
            
            text: loader.manager.errorMessage
            color: Theme.error
            font.pixelSize: Theme.typography.sm
            font.family: Theme.typography.fontFamily
            horizontalAlignment: Text.AlignHCenter
            visible: loader.manager.authFailed && loader.manager.errorMessage
            opacity: 0.9
          }
          
          // ========== BATTERY INDICATOR (if on laptop) ==========
          RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.spacing.lg
            spacing: Theme.spacing.sm
            
            visible: loader.systemState.battery.isLaptopBattery
            
            Text {
              text: loader.systemState.battery.getBatteryIcon(
                loader.systemState.battery.percentage,
                loader.systemState.battery.isCharging
              )
              color: Theme.on_surface_variant
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
            }
            
            Text {
              text: Math.round(loader.systemState.battery.percentage * 100) + "%"
              color: Theme.on_surface_variant
              font.pixelSize: Theme.typography.sm
              font.family: Theme.typography.fontFamily
              opacity: 0.8
            }
          }
        }
      }
      
      // Submit function
      function submitPassword() {
        if (!passwordInput.text || loader.manager.authenticating) {
          return
        }
        
        // Get the current username (from env or system)
        var username = Quickshell.env("USER") || "user"
        
        // Start authentication
        loader.manager.authenticate(username, passwordInput.text)
        
        // Clear password field after a delay (security)
        Qt.callLater(function() {
          passwordInput.text = ""
        })
      }
    }
  }
}
