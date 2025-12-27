import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
  id: manager
  
  // Current notification data being displayed
  property string notifSummary: ""
  property string notifBody: ""
  property string notifApp: ""
  property bool hasNotification: false

  onHasNotificationChanged: {
  if (!hasNotification) {
    showTimer.stop()
  }
}
  
  // Timer to hide notification after a few seconds
  Timer {
    id: showTimer
    interval: 5000 // Show for 5 seconds
    onTriggered: {
      manager.hasNotification = false
      console.log("Timer triggered, hiding notification")
    }
  }
  
  // The actual notification server
  NotificationServer {
    id: notifServer
    
    onNotification: notification => {
      console.log("=== GOT NOTIFICATION ===")
      console.log("Summary:", notification.summary)
      console.log("Body:", notification.body)
      console.log("App:", notification.appName)
      
      // Extract the data we need
      manager.notifSummary = notification.summary
      manager.notifBody = notification.body
      manager.notifApp = notification.appName
      manager.hasNotification = true
      
      console.log("Stored data:")
      console.log("  notifSummary:", manager.notifSummary)
      console.log("  notifBody:", manager.notifBody)
      console.log("  notifApp:", manager.notifApp)
      console.log("  hasNotification:", manager.hasNotification)
      
      showTimer.restart()
      console.log("Timer started for 5 seconds")
      console.log("========================")
    }
  }
  
  Component.onCompleted: {
    console.log("NotificationManager loaded")
    console.log("Initial hasNotification:", hasNotification)
  }
}
