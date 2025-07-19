import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Dialog {
    id: exportDialog
    title: "批量导出设置"
    width: 500
    height: 600
    anchors.centerIn: parent
    modal: true

    property alias exportController: exportController

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20

        ColumnLayout {
            width: parent.width
            spacing: 20

            // 导出格式设置
            GroupBox {
                title: "导出格式"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    // 格式选择
                    RowLayout {
                        Label {
                            text: "文件格式:"
                            Layout.minimumWidth: 80
                        }
                        
                        ComboBox {
                            id: formatCombo
                            Layout.fillWidth: true
                            model: exportController.supportedFormats
                            currentIndex: {
                                let index = model.indexOf(exportController.exportFormat)
                                return index >= 0 ? index : 0
                            }
                            onCurrentTextChanged: {
                                exportController.exportFormat = currentText
                            }
                        }
                    }

                    // JPEG质量设置
                    RowLayout {
                        visible: formatCombo.currentText === "JPEG"
                        
                        Label {
                            text: "质量:"
                            Layout.minimumWidth: 80
                        }
                        
                        Slider {
                            id: qualitySlider
                            Layout.fillWidth: true
                            from: 1
                            to: 100
                            value: exportController.exportQuality
                            stepSize: 1
                            onValueChanged: exportController.exportQuality = Math.round(value)
                        }
                        
                        Label {
                            text: Math.round(qualitySlider.value) + "%"
                            Layout.minimumWidth: 40
                            font.family: "monospace"
                        }
                    }

                    // TIFF位深度设置
                    RowLayout {
                        visible: formatCombo.currentText === "TIFF"
                        
                        Label {
                            text: "位深度:"
                            Layout.minimumWidth: 80
                        }
                        
                        RadioButton {
                            text: "8位"
                            checked: exportController.exportBitDepth === 8
                            onClicked: exportController.exportBitDepth = 8
                        }
                        
                        RadioButton {
                            text: "16位"
                            checked: exportController.exportBitDepth === 16
                            onClicked: exportController.exportBitDepth = 16
                        }
                    }
                }
            }

            // 文件命名设置
            GroupBox {
                title: "文件命名"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    RowLayout {
                        Label {
                            text: "后缀名:"
                            Layout.minimumWidth: 80
                        }
                        
                        TextField {
                            Layout.fillWidth: true
                            text: exportController.filenameSuffix
                            placeholderText: "processed"
                            onTextChanged: exportController.filenameSuffix = text
                        }
                    }

                    Label {
                        text: "示例: frame_001_" + exportController.filenameSuffix + "." + 
                              formatCombo.currentText.toLowerCase()
                        font.pointSize: 9
                        color: "#666"
                        Layout.fillWidth: true
                    }
                }
            }

            // 输出目录设置
            GroupBox {
                title: "输出目录"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    RowLayout {
                        TextField {
                            id: outputPathField
                            Layout.fillWidth: true
                            text: exportController.outputDirectory
                            placeholderText: "选择输出目录..."
                            readOnly: true
                        }
                        
                        Button {
                            text: "浏览..."
                            onClicked: outputFolderDialog.open()
                        }
                    }

                    Label {
                        visible: exportController.outputDirectory !== ""
                        text: "将导出到: " + exportController.outputDirectory
                        font.pointSize: 9
                        color: "#666"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // 导出预览信息
            GroupBox {
                title: "导出信息"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Label {
                            text: "胶卷:"
                            Layout.minimumWidth: 80
                        }
                        
                        Label {
                            text: projectController.rollLoaded ? 
                                  projectController.getRollName() : "未加载"
                            color: "#666"
                        }
                    }

                    RowLayout {
                        Label {
                            text: "帧数量:"
                            Layout.minimumWidth: 80
                        }
                        
                        Label {
                            text: projectController.frameCount + " 帧"
                            color: "#666"
                        }
                    }

                    RowLayout {
                        Label {
                            text: "预计大小:"
                            Layout.minimumWidth: 80
                        }
                        
                        Label {
                            text: _calculateEstimatedSize()
                            color: "#666"
                        }
                    }
                }
            }

            // 导出进度
            GroupBox {
                title: "导出进度"
                Layout.fillWidth: true
                visible: exportController.exportRunning

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    ProgressBar {
                        Layout.fillWidth: true
                        value: exportController.exportProgress
                        
                        Text {
                            anchors.centerIn: parent
                            text: Math.round(exportController.exportProgress * 100) + "%"
                            font.pointSize: 9
                            color: "#333"
                        }
                    }
                    
                    Label {
                        Layout.fillWidth: true
                        text: exportController.exportStatus
                        font.pointSize: 9
                        color: "#666"
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    // 对话框按钮
    footer: DialogButtonBox {
        Button {
            text: exportController.exportRunning ? "停止导出" : "开始导出"
            enabled: projectController.rollLoaded && 
                    exportController.outputDirectory !== ""
            highlighted: !exportController.exportRunning
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            onClicked: {
                if (exportController.exportRunning) {
                    exportController.stopExport()
                } else {
                    exportController.startExport(projectController.getCurrentRoll())
                }
            }
        }
        
        Button {
            text: "关闭"
            enabled: !exportController.exportRunning
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            onClicked: exportDialog.close()
        }
    }

    // 文件夹选择对话框
    FolderDialog {
        id: outputFolderDialog
        title: "选择导出目录"
        onAccepted: {
            exportController.setOutputDirectory(selectedFolder)
        }
    }

    // 连接导出完成信号
    Connections {
        target: exportController
        function onExportCompleted() {
            // 导出完成后可以选择关闭对话框或显示成功消息
            mainController.setStatus("导出完成: " + exportController.outputDirectory)
        }
        
        function onExportError(message) {
            errorDialog.text = "导出错误: " + message
            errorDialog.open()
        }
    }

    // 错误对话框
    Dialog {
        id: errorDialog
        title: "导出错误"
        property string text: ""
        anchors.centerIn: parent
        modal: true

        Label {
            text: errorDialog.text
            wrapMode: Text.WordWrap
            width: 300
        }
    }

    // 辅助函数
    function _calculateEstimatedSize() {
        if (!projectController.rollLoaded) return "未知"
        
        let frameCount = projectController.frameCount
        let sizePerFrame = 0
        
        switch (exportController.exportFormat) {
            case "JPEG":
                sizePerFrame = 2.5 // MB per frame (估算)
                break
            case "TIFF":
                sizePerFrame = exportController.exportBitDepth === 16 ? 15 : 8
                break
            case "PNG":
                sizePerFrame = 8
                break
        }
        
        let totalSize = frameCount * sizePerFrame
        if (totalSize < 1024) {
            return totalSize.toFixed(1) + " MB"
        } else {
            return (totalSize / 1024).toFixed(1) + " GB"
        }
    }
}