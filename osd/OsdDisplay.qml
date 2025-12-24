import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

LazyLoader {
	id: loader
	
	Theme { id: theme }
	
	required property var manager
	
	active: manager.currentType !== manager.typeNone
	
	PanelWindow {
		anchors.bottom: true
		margins.bottom: screen.height / 8
		exclusiveZone: 0
		implicitWidth: theme.osdWidth
		implicitHeight: theme.osdHeight
		color: "transparent"
		mask: Region {}
		
		Rectangle {
			id: background
			anchors.fill: parent
			radius: height / 3
			color: theme.backgroundTransparent
			
			RowLayout {
				anchors {
					fill: parent
					leftMargin: theme.marginMedium
					rightMargin: theme.marginLarge
					topMargin: theme.marginSmall
					bottomMargin: theme.marginSmall
				}

				// Icon
				Text {
					Layout.alignment: Qt.AlignVCenter
					Layout.preferredWidth: theme.iconSize
					Layout.preferredHeight: theme.iconSize
					font.family: theme.fontFamily
					font.pixelSize: theme.fontSizeIcon
					color: theme.white
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
						height: theme.progressBarHeight
						radius: theme.radiusSmall
						color: theme.whiteTransparent
						
						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}
							width: parent.width * loader.manager.currentValue
							radius: parent.radius
							color: theme.white
							
							Behavior on width {
								NumberAnimation {
									duration: theme.animationDuration
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
