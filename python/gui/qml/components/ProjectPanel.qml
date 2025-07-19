import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: projectPanel
    color: "#f5f5f5"
    border.color: "#ddd"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // 标题
        Label {
            text: "项目管理"
            font.bold: true
            font.pointSize: 12
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#ddd"
        }

        // 胶卷信息区域
        GroupBox {
            title: "胶卷信息"
            Layout.fillWidth: true
            Layout.preferredHeight: 200

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                // 胶片类型选择
                RowLayout {
                    Label {
                        text: "胶片类型:"
                        Layout.minimumWidth: 60
                    }
                    
                    ComboBox {
                        id: filmTypeSelector
                        Layout.fillWidth: true
                        model: projectController.supportedFilmTypes
                        currentIndex: {
                            let index = model.indexOf(projectController.filmType)
                            return index >= 0 ? index : 0
                        }
                        onCurrentTextChanged: {
                            if (currentText !== projectController.filmType) {
                                projectController.setFilmType(currentText)
                            }
                        }
                    }
                }

                // 文件夹路径显示
                RowLayout {
                    Label {
                        text: "路径:"
                        Layout.minimumWidth: 60
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        
                        Label {
                            text: projectController.rollPath || "未选择文件夹"
                            wrapMode: Text.WrapAnywhere
                            color: projectController.rollPath ? "#333" : "#999"
                            width: parent.width
                        }
                    }
                }

                // 胶卷统计信息
                GridLayout {
                    columns: 2
                    columnSpacing: 10
                    Layout.fillWidth: true

                    Label {
                        text: "胶卷名称:"
                        font.pointSize: 9
                    }
                    Label {
                        text: projectController.rollLoaded ? projectController.getRollName() : "未加载"
                        font.pointSize: 9
                        color: "#666"
                    }

                    Label {
                        text: "帧数量:"
                        font.pointSize: 9
                    }
                    Label {
                        text: projectController.frameCount + " 帧"
                        font.pointSize: 9
                        color: "#666"
                    }

                    Label {
                        text: "状态:"
                        font.pointSize: 9
                    }
                    Label {
                        text: projectController.rollLoaded ? "已加载" : "未加载"
                        font.pointSize: 9
                        color: projectController.rollLoaded ? "#27ae60" : "#e74c3c"
                    }
                }

                // 加载进度条
                ProgressBar {
                    Layout.fillWidth: true
                    visible: projectController.loadingProgress > 0 && projectController.loadingProgress < 1
                    value: projectController.loadingProgress
                }
            }
        }

        // 操作按钮区域
        GroupBox {
            title: "操作"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Button {
                    text: "选择胶卷文件夹"
                    Layout.fillWidth: true
                    icon.name: "folder-open"
                    onClicked: {
                        // 触发主窗口的文件夹选择对话框
                        folderDialog.open()
                    }
                }

                Button {
                    text: "卸载当前胶卷"
                    Layout.fillWidth: true
                    enabled: projectController.rollLoaded
                    icon.name: "document-close"
                    onClicked: {
                        projectController.unloadRoll()
                        mainController.setStatus("胶卷已卸载")
                    }
                }

                Button {
                    text: "刷新胶卷"
                    Layout.fillWidth: true
                    enabled: projectController.rollLoaded
                    icon.name: "view-refresh"
                    onClicked: {
                        if (projectController.rollPath) {
                            projectController.loadRoll(projectController.rollPath)
                        }
                    }
                }
            }
        }

        // 帧列表预览区域
        GroupBox {
            title: "帧列表"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                anchors.fill: parent
                
                ListView {
                    id: frameListView
                    model: projectController.frameCount
                    
                    delegate: Rectangle {
                        width: frameListView.width
                        height: 40
                        color: mouseArea.containsMouse ? "#e3f2fd" : "transparent"
                        border.color: "#ddd"
                        border.width: mouseArea.containsMouse ? 1 : 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            Rectangle {
                                width: 24
                                height: 24
                                color: "#2196f3"
                                radius: 12

                                Label {
                                    anchors.centerIn: parent
                                    text: (index + 1).toString()
                                    color: "white"
                                    font.pointSize: 9
                                    font.bold: true
                                }
                            }

                            Label {
                                text: `帧 ${index + 1}`
                                Layout.fillWidth: true
                                font.pointSize: 10
                            }

                            Label {
                                text: "未处理"
                                font.pointSize: 9
                                color: "#999"
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                // 加载选中的帧到图像预览器
                                imageController.loadFrameByIndex(index)
                                mainController.setStatus(`已选择帧 ${index + 1}`)
                            }
                        }
                    }
                    
                    // 空状态显示
                    Label {
                        anchors.centerIn: parent
                        text: "未加载胶卷\n\n请先选择胶卷文件夹"
                        color: "#999"
                        font.pointSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        visible: !projectController.rollLoaded
                    }
                }
            }
        }

        // 底部信息
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#ddd"
        }

        Label {
            text: projectController.rollLoaded ? 
                  `总计 ${projectController.frameCount} 帧` : 
                  "请加载胶卷以开始"
            font.pointSize: 9
            color: "#666"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
} 