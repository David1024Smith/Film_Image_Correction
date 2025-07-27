import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "transparent"
    implicitHeight: headerHeight + (expanded ? contentHeight : 0)
    height: implicitHeight
    
    property int headerHeight: 64
    property int contentHeight: 120
    property bool expanded: false
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#333333"
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.headerHeight
            color: "transparent"
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.expanded = !root.expanded
                }
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                
                Text {
                    Layout.fillWidth: true
                    text: "成像比例"
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                }
                
                Text {
                    text: root.expanded ? "▲" : "▼"
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    
                    Behavior on rotation {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
        
        // 内容区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.expanded ? root.contentHeight : 0
            color: "transparent"
            clip: true
            
            GridLayout {
                anchors.fill: parent
                anchors.margins: 16
                anchors.topMargin: 0
                columns: 2
                columnSpacing: 8
                rowSpacing: 8
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "3:2"
                    
                    background: Rectangle {
                        color: parent.hovered ? "#333333" : "#1A1A1A"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                    }
                    
                    onClicked: {
                        console.log("选择比例: 3:2")
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setAspectRatio(3, 2)
                        }
                    }
                }
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "3:4"
                    
                    background: Rectangle {
                        color: parent.hovered ? "#333333" : "#1A1A1A"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                    }
                    
                    onClicked: {
                        console.log("选择比例: 3:4")
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setAspectRatio(3, 4)
                        }
                    }
                }
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "16:9"
                    
                    background: Rectangle {
                        color: parent.hovered ? "#333333" : "#1A1A1A"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                    }
                    
                    onClicked: {
                        console.log("选择比例: 16:9")
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setAspectRatio(16, 9)
                        }
                    }
                }
            }
        }
    }
}