import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== LAUNCHER FUNCTIONS ==========
  function launchColorPicker() {
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["hyprpicker", "-a"] }', manager)
    proc.startDetached()
    proc.destroy()
  }
  
  function takeScreenshot() {
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["hyprshot", "-m", "region"] }', manager)
    proc.startDetached()
    proc.destroy()
  }
  
  function openClipboard() {
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["kitty", "--class", "floating_term_s", "-e", "clipse"] }', manager)
    proc.startDetached()
    proc.destroy()
  }
}
