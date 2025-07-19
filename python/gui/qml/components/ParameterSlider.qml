import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: parameterSlider
    
    property alias parameterName: nameLabel.text
    property alias value: slider.value
    property alias minimumValue: slider.from
    property alias maximumValue: slider.to
    property alias stepSize: slider.stepSize
    property int decimals: 1
    property string suffix: ""
    
    signal parameterValueChanged(real value)
    
    spacing: 4

    // 参数名称和数值显示
    RowLayout {
        Layout.fillWidth: true
        
        Label {
            id: nameLabel
            text: "参数"
            Layout.minimumWidth: 80
            font.pointSize: 9
        }
        
        Item { Layout.fillWidth: true }
        
        Rectangle {
            width: valueLabel.width + 12
            height: 24
            color: "#fff"
            border.color: "#ddd"
            border.width: 1
            radius: 3
            
            Label {
                id: valueLabel
                anchors.centerIn: parent
                text: value.toFixed(decimals) + suffix
                font.family: "monospace"
                font.pointSize: 9
                color: "#333"
            }
        }
    }
    
    // 滑块控件
    Slider {
        id: slider
        Layout.fillWidth: true
        
        onValueChanged: parameterSlider.parameterValueChanged(value)
        
        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 6
            width: slider.availableWidth
            height: implicitHeight
            radius: 3
            color: "#e0e0e0"
            
            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                color: "#2196f3"
                radius: 3
            }
        }
        
        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 20
            implicitHeight: 20
            radius: 10
            color: slider.pressed ? "#1976d2" : "#2196f3"
            border.color: "#fff"
            border.width: 2
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }
} 