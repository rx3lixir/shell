import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Authentication state
  property bool authenticating: false
  property bool authFailed: false
  property string errorMessage: ""
  
  // Store password temporarily for PAM conversation
  property string pendingPassword: ""
  
  // PAM Context for authentication
  PamContext {
    id: pamContext
    
    config: "login"
    configDirectory: "/etc/pam.d"
    
    // When PAM asks for input - this is when we respond with password
    onResponseRequiredChanged: {
      if (responseRequired) {
        console.log("[Lockscreen] PAM requesting response:", message)
        console.log("[Lockscreen] Response visible:", responseVisible)
        
        // If we have a pending password and PAM is asking for input, respond
        if (manager.pendingPassword) {
          console.log("[Lockscreen] Responding with password")
          pamContext.respond(manager.pendingPassword)
          manager.pendingPassword = "" // Clear it immediately for security
        }
      }
    }
    
    // When authentication completes successfully
    onCompleted: {
      console.log("[Lockscreen] Authentication successful!")
      manager.authenticating = false
      manager.authFailed = false
      manager.pendingPassword = ""
      manager.visible = false
    }
    
    // When authentication fails
    onError: function(error) {
      console.log("[Lockscreen] Authentication failed:", error)
      manager.authenticating = false
      manager.authFailed = true
      manager.errorMessage = "Authentication failed"
      manager.pendingPassword = ""
    }
    
    // PAM messages
    onPamMessage: {
      console.log("[Lockscreen] PAM message:", message, "isError:", messageIsError)
    }
  }
  
  // Start authentication with username and password
  function authenticate(username, password) {
    console.log("[Lockscreen] Starting authentication for user:", username)
    
    manager.authenticating = true
    manager.authFailed = false
    manager.errorMessage = ""
    
    // Store password for when PAM asks for it
    manager.pendingPassword = password
    
    // Set the user and start PAM session
    pamContext.user = username
    pamContext.start()
  }
  
  // Abort authentication
  function abort() {
    console.log("[Lockscreen] Aborting authentication")
    pamContext.abort()
    manager.authenticating = false
    manager.authFailed = false
    manager.pendingPassword = ""
  }
  
  // Reset state when closing
  onVisibleChanged: {
    if (!visible) {
      manager.authenticating = false
      manager.authFailed = false
      manager.errorMessage = ""
      manager.pendingPassword = ""
    }
  }
  
  // IPC Handler for external control
  IpcHandler {
    target: "lockscreen"
    
    function toggle(): void {
      manager.visible = !manager.visible
    }
    
    function lock(): void {
      manager.visible = true
    }
    
    function unlock(): void {
      manager.visible = false
    }
  }
}
