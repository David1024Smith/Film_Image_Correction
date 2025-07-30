import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: testWindow
    width: 600
    height: 400
    title: "滑块键盘支持测试"
    visible: true
    color: "#1C1C1E"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 32

        Text {
            text: "滑块键盘支持测试"
            color: "white"
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "点击滑块获取焦点，然后使用左右键进行微调"
            color: "#CCCCCC"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
        }

        // 测试ThresholdSlider
        GroupBox {
            Layout.fillWidth: true
            title: "阈值滑块测试"
            
            background: Rectangle {
                color: "#262626"
                radius: 8
                border.color: "#404040"
                border.width: 1
            }
            
            label: Text {
                text: parent.title
                color: "white"
                font.pixelSize: 16
            }

            ThresholdSlider {
                anchors.fill: parent
                anchors.margins: 16
                labelText: "测试阈值"
                minValue: 0
                maxValue: 100
                currentValue: 50
                
                onValueChanged: function(value) {
                    console.log("阈值滑块值:", value)
                }
            }
        }

        // 测试说明
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: "#262626"
            radius: 8
            border.color: "#404040"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Text {
                    text: "使用说明："
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: "1. 点击滑块获取焦点（滑块会显示焦点状态）"
                    color: "#CCCCCC"
                    font.pixelSize: 14
                }

                Text {
                    text: "2. 使用左箭头键减少数值，右箭头键增加数值"
                    color: "#CCCCCC"
                    font.pixelSize: 14
                }

                Text {
                    text: "3. 每次按键会按照设定的步长进行调整"
                    color: "#CCCCCC"
                    font.pixelSize: 14
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}