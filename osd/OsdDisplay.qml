import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

LazyLoader {
	id: loader
	
	// Bind to the manager's state
	required property var manager
	
	active: manager.currentType !== manager.typeNone
	
	PanelWindow {
		anchors.bottom: true
		margins.bottom: screen.height / 8
		exclusiveZone: 0
		implicitWidth: 200
		implicitHeight: 50
		color: "transparent"
		mask: Region {}
		
		Rectangle {
			id: background
			anchors.fill: parent
			radius: height / 3
			color: "#80000000"
			
			RowLayout {
				anchors {
					fill: parent
          leftMargin: 10    // Space before the icon (adjust as needed)
          rightMargin: 20   // Extra space after the progress bar for balance
          topMargin: 6
          bottomMargin: 6
				}

				// Icon
				Text {
					Layout.alignment: Qt.AlignVCenter
					Layout.preferredWidth: 28
					Layout.preferredHeight: 28
					font.family: "Ubuntu Nerd Font Propo"
					font.pixelSize: 22
					color: "white"
					text: loader.manager.currentIcon
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
				
				// Progress bar container
				Item {
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.alignment: Qt.AlignVCenter
					
					Rectangle {
						anchors.centerIn: parent
						width: parent.width
						height: 6
						radius: 3
						color: "#50ffffff"
						
						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}
							width: parent.width * loader.manager.currentValue
							radius: parent.radius
							color: "white"
							
							Behavior on width {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}
						}
					}
				}
			}
		}
	}
}
