import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    spacing: 8
    
    property string labelText: ""
    property int minValue: 0
    property int maxValue: 100
    property int currentValue: 0
    
    signal valueChanged(int value)
    
    // 标签和数值输入
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        
        Text {
            Layout.fillWidth: true
            text: root.labelText
            color: "#FFFFFF"
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
        }
        
        Rectangle {
            width: 60
            height: 28
            color: "transparent"
            border.color: "#333333"
            border.width: 1
            radius: 4
            
            Text {
                id: numberDisplay
                anchors.fill: parent
                text: Math.round(slider.value).toString()
                font.pixelSize: 12
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    
    // 滑块和步进按钮
    RowLayout {
        Layout.fillWidth: true
        spacing: 4

        // 减少按钮
        Button {
            width: 24
            height: 24
            text: "−"

            background: Rectangle {
                color: parent.pressed ? "#404040" : (parent.hovered ? "#333333" : "#262626")
                radius: 4
                border.color: "#404040"
                border.width: 1
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                var newValue = Math.max(root.minValue, slider.value - 1)
                slider.value = newValue
            }
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: root.minValue
            to: root.maxValue
            value: root.currentValue
            focus: true
            
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 4
                width: slider.availableWidth
                height: implicitHeight
                radius: 2
                color: "#333333"
                
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    color: "#FFD60A"
                    radius: 2
                }
            }
            
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: "#FFD60A"
                border.color: slider.pressed ? "#E6C109" : "#FFD60A"
                border.width: 1
            }
            
            // 键盘左右键支持
            Keys.onLeftPressed: {
                var newValue = Math.max(root.minValue, slider.value - 1)
                slider.value = newValue
            }
            
            Keys.onRightPressed: {
                var newValue = Math.min(root.maxValue, slider.value + 1)
                slider.value = newValue
            }
            
            onValueChanged: {
                root.valueChanged(Math.round(value))
            }
            
            // 鼠标点击时获取焦点
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    slider.forceActiveFocus()
                    mouse.accepted = false
                }
            }
        }

        // 增加按钮
        Button {
            width: 24
            height: 24
            text: "+"

            background: Rectangle {
                color: parent.pressed ? "#404040" : (parent.hovered ? "#333333" : "#262626")
                radius: 4
                border.color: "#404040"
                border.width: 1
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                var newValue = Math.min(root.maxValue, slider.value + 1)
                slider.value = newValue
            }
        }
    }
}