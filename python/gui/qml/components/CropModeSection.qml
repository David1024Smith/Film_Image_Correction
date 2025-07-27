import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "transparent"
    implicitHeight: 140
    height: implicitHeight
    
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#333333"
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // 向内裁剪选项
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                RadioButton {
                    id: inwardCropRadio
                    checked: true
                    
                    indicator: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        border.color: "#FFD60A"
                        border.width: 1
                        color: "transparent"
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            anchors.centerIn: parent
                            color: "#FFD60A"
                            visible: parent.parent.checked
                        }
                    }
                    
                    onCheckedChanged: {
                        if (checked) {
                            autoCropRadio.checked = false
                            console.log("选择向内裁剪模式")
                            if (typeof parameterController !== 'undefined') {
                                parameterController.setCropMode("inward")
                            }
                        }
                    }
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "向内裁剪"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            inwardCropRadio.checked = true
                        }
                    }
                }
            }
            
            // 向内裁剪百分比设置
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 24
                spacing: 8
                
                Rectangle {
                    width: 60
                    height: 32
                    color: "transparent"
                    border.color: "#333333"
                    border.width: 1
                    radius: 4
                    
                    TextInput {
                        id: inwardCropPercent
                        anchors.fill: parent
                        anchors.margins: 8
                        text: "100"
                        font.pixelSize: 14
                        color: "#FFFFFF"
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter
                        validator: IntValidator { bottom: 0; top: 100 }
                        
                        onTextChanged: {
                            var value = parseInt(text) || 0
                            console.log("向内裁剪百分比:", value)
                            if (typeof parameterController !== 'undefined') {
                                parameterController.setInwardCropPercent(value)
                            }
                        }
                    }
                }
                
                Text {
                    text: "%"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                }
                
                Item {
                    Layout.fillWidth: true
                }
            }
        }
        
        // 自动框选选项
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RadioButton {
                id: autoCropRadio
                checked: false
                
                indicator: Rectangle {
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    border.color: "#FFD60A"
                    border.width: 1
                    color: "transparent"
                    
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        anchors.centerIn: parent
                        color: "#FFD60A"
                        visible: parent.parent.checked
                    }
                }
                
                onCheckedChanged: {
                    if (checked) {
                        inwardCropRadio.checked = false
                        console.log("选择自动框选模式")
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setCropMode("auto")
                        }
                    }
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: "自动框选"
                color: "#FFFFFF"
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        autoCropRadio.checked = true
                    }
                }
            }
        }
    }
}