import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
  id: manager
  
  // Reference to the notification center manager
  required property var notificationCenterManager
  
  // Current notification data being displayed (for the popup)
  property string notifSummary: ""
  property string notifBody: ""
  property string notifApp: ""
  property bool hasNotification: false

  onHasNotificationChanged: {
    if (!hasNotification) {
      showTimer.stop()
    }
  }
  
  // Timer to hide notification popup after a few seconds
  Timer {
    id: showTimer
    interval: 5000 // Show for 5 seconds
    onTriggered: {
      manager.hasNotification = false
    }
  }
  
  // The actual notification server
  NotificationServer {
    id: notifServer
    
    onNotification: notification => {
      notificationCenterManager.addNotification(notification)
      
      // Then show the popup
      manager.notifSummary = notification.summary
      manager.notifBody = notification.body
      manager.notifApp = notification.appName
      manager.hasNotification = true
      
      showTimer.restart()
    }
  }
}
