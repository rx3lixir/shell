import QtQuick
import Quickshell
import "osd"
import "bar"
import "wlogout"
import "notifications"
import "launcher"
import "notificationcenter"
import "controlcenter"

ShellRoot {
  // Load the OSD manager (the brain)
  OsdManager {
    id: osdManager
  }
  
  // Load the OSD display (the visuals)
  OsdDisplay {
    manager: osdManager
  }
  
  // Load the control center system
  ControlCenterManager {
    id: controlCenterManager
  }
  
  ControlCenterDisplay {
    manager: controlCenterManager
  }
  
  // Load the notification center system
  NotificationCenterManager {
    id: notificationCenterManager
  }
  
  NotificationCenterDisplay {
    manager: notificationCenterManager
  }
  
  // Update NotificationManager
  NotificationManager {
    id: notificationManager
    notificationCenterManager: notificationCenterManager
  }
  
  NotificationDisplay {
    manager: notificationManager
  }
  
  // Load the launcher system
  LauncherManager {
    id: launcherManager
  }
  
  LauncherDisplay {
    manager: launcherManager
  }

  // Load the wlogout window (keeping it for reference, but not using in bar anymore)
  WLogout {
    id: wlogout
    visible: false
    
    // Define your logout buttons here
    LogoutButton {
      text: "Shutdown"
      nerdIcon: "󰐥"
      command: "systemctl poweroff"
      keybind: Qt.Key_S
    }
    
    LogoutButton {
      text: "Reboot"
      nerdIcon: "󰜉"
      command: "systemctl reboot"
      keybind: Qt.Key_R
    }
    
    LogoutButton {
      text: "Logout"
      nerdIcon: "󰍃"
      command: "hyprctl dispatch exit"
      keybind: Qt.Key_L
    }
    
    LogoutButton {
      text: "Lock"
      nerdIcon: "󰌾"
      command: "hyprlock"
      keybind: Qt.Key_K
    }
    
    LogoutButton {
      text: "Suspend"
      nerdIcon: "󰤄"
      command: "systemctl suspend"
      keybind: Qt.Key_U
    }
    
    LogoutButton {
      text: "Hibernate"
      nerdIcon: "󰋊"
      command: "systemctl hibernate"
      keybind: Qt.Key_H
    }
  }

  // Load the Bar component and pass references
  Bar {
    id: bar
    controlCenterManager: controlCenterManager
    notificationCenterManager: notificationCenterManager
    
    Component.onCompleted: {
      console.log("Bar controlCenterManager is:", controlCenterManager)
      console.log("Bar notificationCenterManager is:", notificationCenterManager)
    }
  }
}
