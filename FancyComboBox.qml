import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: control
    
    property bool isHovered: false
    
    Timer {
        id: hoverTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: control.isHovered = false
    }
    
    background: Item {
        implicitWidth: 200
        implicitHeight: 40
        
        // Main background
        Rectangle {
            id: mainBg
            anchors.fill: parent
            color: "#1a1a1a"
            radius: 4
            
            border.width: 2
            border.color: {
                if (control.popup.visible || control.activeFocus) return "#5294e2"
                if (control.isHovered) return "#4080c0"
                return "#333333"
            }
            
            // Animated gradient on hover
            gradient: Gradient {
                GradientStop { 
                    position: 0.0
                    color: control.isHovered ? "#2a2a2a" : "#1a1a1a"
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
                GradientStop { 
                    position: 0.5
                    color: control.isHovered ? "#252525" : "#151515"
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
                GradientStop { 
                    position: 1.0
                    color: control.isHovered ? "#1a1a1a" : "#0a0a0a"
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
            }
            
            // Inner glow
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 2
                color: "transparent"
                border.width: 1
                border.color: control.isHovered ? "#5294e2" : "transparent"
                opacity: 0.2
                
                Behavior on border.color {
                    ColorAnimation { duration: 300 }
                }
            }
            
            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }
        }
        
        // Hover detection
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                control.isHovered = true
                hoverTimer.restart()
            }
            onExited: {
                control.isHovered = false
                hoverTimer.stop()
            }
            onClicked: {
                if (!control.popup.visible) {
                    control.popup.open()
                } else {
                    control.popup.close()
                }
            }
        }
        
        // Multiple glow layers
        Repeater {
            model: 3
            Rectangle {
                anchors.fill: parent
                anchors.margins: -(index + 1) * 3
                radius: 6 + index * 2
                color: "transparent"
                border.width: 1
                border.color: "#5294e2"
                opacity: control.isHovered ? (0.3 - index * 0.1) : 0
                visible: opacity > 0
                
                Behavior on opacity {
                    NumberAnimation { 
                        duration: 200 + index * 100
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        
        // Animated corner accents
        Repeater {
            model: 4
            Rectangle {
                width: 20
                height: 20
                color: "transparent"
                border.width: 2
                border.color: "#5294e2"
                radius: 2
                opacity: control.isHovered ? 0.6 : 0
                
                x: {
                    if (index === 0 || index === 2) return -5
                    return parent.width - 15
                }
                y: {
                    if (index === 0 || index === 1) return -5
                    return parent.height - 15
                }
                
                rotation: control.isHovered ? 45 : 0
                
                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
                
                Behavior on rotation {
                    NumberAnimation { duration: 500 }
                }
            }
        }
        
        // Shimmer effect
        Rectangle {
            width: parent.width * 2
            height: 2
            x: control.isHovered ? -parent.width : parent.width
            y: parent.height / 2
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.4; color: "transparent" }
                GradientStop { position: 0.5; color: control.isHovered ? "#5294e2" : "transparent" }
                GradientStop { position: 0.6; color: "transparent" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            
            opacity: 0.8
            
            Behavior on x {
                NumberAnimation { 
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        // Wave effect at bottom
        Item {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 4
            clip: true
            
            Rectangle {
                width: parent.width * 2
                height: 4
                color: "#5294e2"
                opacity: control.isHovered ? 0.6 : 0
                
                x: control.isHovered ? -parent.width : 0
                
                SequentialAnimation on x {
                    running: control.isHovered
                    loops: Animation.Infinite
                    NumberAnimation { to: 0; duration: 2000 }
                }
                
                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
                
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.3; color: "#5294e2" }
                    GradientStop { position: 0.7; color: "#5294e2" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }
    
    contentItem: Text {
        leftPadding: 10
        rightPadding: control.indicator.width + control.spacing
        text: control.displayText
        font: control.font
        color: control.isHovered ? "#5294e2" : "#ffffff"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    indicator: Item {
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 20
        height: 20
        
        Canvas {
            id: canvas
            anchors.centerIn: parent
            width: 12
            height: 8
            contextType: "2d"
            
            rotation: control.popup.visible ? 180 : 0
            scale: control.isHovered ? 1.2 : 1.0
            
            Behavior on rotation {
                NumberAnimation { duration: 200 }
            }
            
            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
            
            onPaint: {
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                
                // Gradient fill
                var gradient = context.createLinearGradient(0, 0, 0, height);
                if (control.isHovered || control.popup.visible) {
                    gradient.addColorStop(0, "#5294e2");
                    gradient.addColorStop(1, "#3daee9");
                } else {
                    gradient.addColorStop(0, "#999999");
                    gradient.addColorStop(1, "#666666");
                }
                context.fillStyle = gradient;
                context.fill();
            }
            
            Connections {
                target: control
                onIsHoveredChanged: canvas.requestPaint()
            }
            
            Connections {
                target: control.popup
                onVisibleChanged: canvas.requestPaint()
            }
        }
        
        // Glow circle around indicator
        Rectangle {
            anchors.centerIn: parent
            width: 20
            height: 20
            radius: 10
            color: "transparent"
            border.width: 1
            border.color: "#5294e2"
            opacity: control.isHovered ? 0.5 : 0
            scale: control.isHovered ? 1.5 : 1.0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            Behavior on scale {
                NumberAnimation { duration: 300 }
            }
        }
    }
    
    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1
        
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        
        background: Rectangle {
            color: "#1a1a1a"
            border.color: "#5294e2"
            border.width: 1
            radius: 4
        }
    }
    
    delegate: ItemDelegate {
        width: control.width
        contentItem: Text {
            text: model.name || modelData || ""
            color: hovered ? "#5294e2" : "white"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: hovered ? "#2a2a2a" : "transparent"
        }
    }
}
