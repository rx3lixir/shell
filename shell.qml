import QtQuick
import Quickshell
import "osd"
import "bar"
import "notifications"
import "launcher"
import "notificationcenter"
import "controlcenter"
import "menu"
import "calendar"
import "wallpaper"
import "powermenu"

ShellRoot {
  // Load the power menu system first (needed by control center)
  PowerMenuManager {
    id: powerMenuManager
  }
  
  PowerMenuDisplay {
    manager: powerMenuManager
  }
  
  // Load the control center system (brightness monitoring happens here)
  ControlCenterManager {
    id: controlCenterManager
    powerMenuManager: powerMenuManager
  }
  
  ControlCenterDisplay {
    manager: controlCenterManager
  }
  
  // Load the OSD manager (depends on control center for brightness)
  OsdManager {
    id: osdManager
    brightnessManager: controlCenterManager.brightness
  }
  
  // Load the OSD display (the visuals)
  OsdDisplay {
    manager: osdManager
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
  
  // Load the wallpaper system
  WallpaperManager {
    id: wallpaperManager
  }
  
  WallpaperGrid {
    manager: wallpaperManager
  }
  
  // Load the menu system (needs launcher, wallpaper, and power menu references)
  MenuManager {
    id: menuManager
    launcherManager: launcherManager
    wallpaperManager: wallpaperManager
    powerMenuManager: powerMenuManager
  }
  
  MenuDisplay {
    manager: menuManager
  }
  
  // Load the calendar system
  CalendarManager {
    id: calendarManager
  }
  
  CalendarDisplay {
    manager: calendarManager
  }

  // Load the Bar component and pass references
  Bar {
    id: bar
    controlCenterManager: controlCenterManager
    notificationCenterManager: notificationCenterManager
    calendarManager: calendarManager
  }
}
