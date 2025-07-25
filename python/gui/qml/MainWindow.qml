import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800
    title: "Revela - 胶片处理系统"
    visible: true

    // 主布局
    Rectangle {
        anchors.fill: parent
        color: "#f8f9fa"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // 左侧导航栏
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: "#2c3e50"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 30

                    // Logo和标题
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 80
                            height: 80
                            color: "#e74c3c"
                            radius: 40

                            Text {
                                anchors.centerIn: parent
                                text: "R"
                                font.pixelSize: 40
                                font.bold: true
                                color: "white"
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Revela"
                            font.pixelSize: 28
                            font.bold: true
                            color: "white"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "胶片处理系统"
                            font.pixelSize: 16
                            color: "#bdc3c7"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#34495e"
                    }

                    // 主要功能按钮
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Text {
                            text: "主要功能"
                            font.pixelSize: 18
                            font.bold: true
                            color: "white"
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "📁 文件管理"
                            height: 60
                            font.pixelSize: 16
                            onClicked: {
                                var component = Qt.createComponent("fileManagementWindow.qml")
                                if (component.status === Component.Ready) {
                                    var newWindow = component.createObject()
                                    if (newWindow) {
                                        newWindow.show()
                                        mainWindow.close()
                                    }
                                }
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#34495e" : (parent.hovered ? "#3498db" : "transparent")
                                border.color: "#3498db"
                                border.width: 2
                                radius: 10
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: parent.font.pixelSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "🎛️ 参数控制"
                            height: 60
                            font.pixelSize: 16
                            onClicked: {
                                var component = Qt.createComponent("parameterControlWindow.qml")
                                if (component.status === Component.Ready) {
                                    var newWindow = component.createObject()
                                    if (newWindow) {
                                        newWindow.show()
                                        mainWindow.close()
                                    }
                                }
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#34495e" : (parent.hovered ? "#27ae60" : "transparent")
                                border.color: "#27ae60"
                                border.width: 2
                                radius: 10
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: parent.font.pixelSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "🎨 胶片调整"
                            height: 60
                            font.pixelSize: 16
                            onClicked: {
                                var component = Qt.createComponent("adjustmentWindow.qml")
                                if (component.status === Component.Ready) {
                                    var newWindow = component.createObject()
                                    if (newWindow) {
                                        newWindow.show()
                                        mainWindow.close()
                                    }
                                }
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#34495e" : (parent.hovered ? "#f39c12" : "transparent")
                                border.color: "#f39c12"
                                border.width: 2
                                radius: 10
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: parent.font.pixelSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#34495e"
                    }

                    // 快速操作
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Text {
                            text: "快速操作"
                            font.pixelSize: 18
                            font.bold: true
                            color: "white"
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "📤 批量导出"
                            height: 50
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: parent.pressed ? "#34495e" : (parent.hovered ? "#9b59b6" : "transparent")
                                border.color: "#9b59b6"
                                border.width: 1
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: parent.font.pixelSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "⚙️ 设置"
                            height: 50
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: parent.pressed ? "#34495e" : (parent.hovered ? "#95a5a6" : "transparent")
                                border.color: "#95a5a6"
                                border.width: 1
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: parent.font.pixelSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // 底部信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#34495e"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "版本 1.0.0"
                            font.pixelSize: 12
                            color: "#7f8c8d"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "© 2024 Revela"
                            font.pixelSize: 12
                            color: "#7f8c8d"
                        }
                    }
                }
            }

            // 右侧主内容区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#f8f9fa"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 40
                    spacing: 30

                    // 欢迎标题
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Text {
                            text: "欢迎使用 Revela"
                            font.pixelSize: 36
                            font.bold: true
                            color: "#2c3e50"
                        }

                        Text {
                            text: "专业的胶片数字化处理工具"
                            font.pixelSize: 18
                            color: "#7f8c8d"
                        }
                    }

                    // 功能卡片区域
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 2
                        rowSpacing: 20
                        columnSpacing: 20

                        // 文件管理卡片
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "white"
                            radius: 15
                            border.color: "#e9ecef"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 30
                                spacing: 20

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 80
                                    height: 80
                                    color: "#3498db"
                                    radius: 40

                                    Text {
                                        anchors.centerIn: parent
                                        text: "📁"
                                        font.pixelSize: 32
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "文件管理"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#2c3e50"
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "管理和组织您的胶片文件"
                                    font.pixelSize: 14
                                    color: "#7f8c8d"
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                }

                                Item { Layout.fillHeight: true }

                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "开始使用"
                                    height: 40
                                    width: 120
                                    onClicked: {
                                        var component = Qt.createComponent("fileManagementWindow.qml")
                                        if (component.status === Component.Ready) {
                                            var newWindow = component.createObject()
                                            if (newWindow) {
                                                newWindow.show()
                                                mainWindow.close()
                                            }
                                        }
                                    }
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#2980b9" : (parent.hovered ? "#3498db" : "#ecf0f1")
                                        radius: 8
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.hovered ? "white" : "#2c3e50"
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#f8f9fa"
                                onExited: parent.color = "white"
                            }
                        }

                        // 参数控制卡片
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "white"
                            radius: 15
                            border.color: "#e9ecef"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 30
                                spacing: 20

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 80
                                    height: 80
                                    color: "#27ae60"
                                    radius: 40

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🎛️"
                                        font.pixelSize: 32
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "参数控制"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#2c3e50"
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "精确控制胶片处理参数"
                                    font.pixelSize: 14
                                    color: "#7f8c8d"
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                }

                                Item { Layout.fillHeight: true }

                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "开始使用"
                                    height: 40
                                    width: 120
                                    onClicked: {
                                        var component = Qt.createComponent("parameterControlWindow.qml")
                                        if (component.status === Component.Ready) {
                                            var newWindow = component.createObject()
                                            if (newWindow) {
                                                newWindow.show()
                                                mainWindow.close()
                                            }
                                        }
                                    }
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#229954" : (parent.hovered ? "#27ae60" : "#ecf0f1")
                                        radius: 8
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.hovered ? "white" : "#2c3e50"
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#f8f9fa"
                                onExited: parent.color = "white"
                            }
                        }

                        // 胶片调整卡片
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "white"
                            radius: 15
                            border.color: "#e9ecef"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 30
                                spacing: 20

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 80
                                    height: 80
                                    color: "#f39c12"
                                    radius: 40

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🎨"
                                        font.pixelSize: 32
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "胶片调整"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#2c3e50"
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "实时调整胶片色彩和效果"
                                    font.pixelSize: 14
                                    color: "#7f8c8d"
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                }

                                Item { Layout.fillHeight: true }

                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "开始使用"
                                    height: 40
                                    width: 120
                                    onClicked: {
                                        var component = Qt.createComponent("adjustmentWindow.qml")
                                        if (component.status === Component.Ready) {
                                            var newWindow = component.createObject()
                                            if (newWindow) {
                                                newWindow.show()
                                                mainWindow.close()
                                            }
                                        }
                                    }
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#d68910" : (parent.hovered ? "#f39c12" : "#ecf0f1")
                                        radius: 8
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.hovered ? "white" : "#2c3e50"
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#f8f9fa"
                                onExited: parent.color = "white"
                            }
                        }

                        // 帮助和支持卡片
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "white"
                            radius: 15
                            border.color: "#e9ecef"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 30
                                spacing: 20

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 80
                                    height: 80
                                    color: "#9b59b6"
                                    radius: 40

                                    Text {
                                        anchors.centerIn: parent
                                        text: "❓"
                                        font.pixelSize: 32
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "帮助和支持"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#2c3e50"
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "获取使用帮助和技术支持"
                                    font.pixelSize: 14
                                    color: "#7f8c8d"
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                }

                                Item { Layout.fillHeight: true }

                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "查看帮助"
                                    height: 40
                                    width: 120
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#8e44ad" : (parent.hovered ? "#9b59b6" : "#ecf0f1")
                                        radius: 8
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.hovered ? "white" : "#2c3e50"
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#f8f9fa"
                                onExited: parent.color = "white"
                            }
                        }
                    }

                    // 底部状态信息
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "white"
                        radius: 10
                        border.color: "#e9ecef"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20

                            Text {
                                text: "系统状态: 就绪"
                                font.pixelSize: 14
                                color: "#27ae60"
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "最后更新: 2024-01-25"
                                font.pixelSize: 12
                                color: "#7f8c8d"
                            }
                        }
                    }
                }
            }
        }
    }
}