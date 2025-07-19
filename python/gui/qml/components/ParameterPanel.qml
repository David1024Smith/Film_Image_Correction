import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: parameterPanel
    color: "#f5f5f5"
    border.color: "#ddd"
    border.width: 1

    ScrollView {
        anchors.fill: parent
        anchors.margins: 10
        
        ColumnLayout {
            width: parameterPanel.width - 20
            spacing: 15

            // 标题
            Label {
                text: "参数控制"
                font.bold: true
                font.pointSize: 12
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#ddd"
            }

            // 校准信息区域
            GroupBox {
                title: "校准信息"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // 分析状态
                    RowLayout {
                        Label {
                            text: "分析状态:"
                            Layout.minimumWidth: 80
                        }
                        
                        Label {
                            text: parameterController.analysisComplete ? "已完成" : "未分析"
                            color: parameterController.analysisComplete ? "#27ae60" : "#e74c3c"
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: analysisController.analysisRunning ? "停止分析" : "开始分析"
                            enabled: projectController.rollLoaded
                            highlighted: !parameterController.analysisComplete
                            onClicked: {
                                if (analysisController.analysisRunning) {
                                    analysisController.stopAnalysis()
                                } else {
                                    analysisController.startAnalysis(projectController.getCurrentRoll())
                                }
                            }
                        }
                    }

                    // D-min 值
                    RowLayout {
                        Label {
                            text: "D-min:"
                            Layout.minimumWidth: 80
                        }
                        
                        Label {
                            text: parameterController.analysisComplete ? 
                                  parameterController.dMin.toFixed(3) : 
                                  "未计算"
                            color: "#666"
                            font.family: "monospace"
                        }
                    }

                    // K 值显示
                    Label {
                        text: "K值 (RGB):"
                        Layout.fillWidth: true
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Repeater {
                            model: parameterController.analysisComplete ? 
                                   parameterController.kValues : [0, 0, 0]
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 30
                                color: "#fff"
                                border.color: "#ddd"
                                border.width: 1
                                radius: 4
                                
                                Label {
                                    anchors.centerIn: parent
                                    text: parameterController.analysisComplete ? 
                                          modelData.toFixed(3) : 
                                          "0.000"
                                    font.family: "monospace"
                                    font.pointSize: 9
                                    color: "#333"
                                }
                            }
                        }
                    }
                    
                    // 分析进度显示
                    ProgressBar {
                        Layout.fillWidth: true
                        visible: analysisController.analysisRunning
                        value: analysisController.analysisProgress
                        
                        Text {
                            anchors.centerIn: parent
                            text: Math.round(analysisController.analysisProgress * 100) + "%"
                            font.pointSize: 9
                            color: "#333"
                        }
                    }
                    
                    // 分析状态显示
                    Label {
                        Layout.fillWidth: true
                        visible: analysisController.analysisRunning
                        text: analysisController.analysisStatus
                        font.pointSize: 9
                        color: "#666"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // 颜色调整区域
            GroupBox {
                title: "颜色调整"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    // 重置按钮
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "重置全部"
                            icon.name: "edit-undo"
                            onClicked: parameterController.resetColorParameters()
                        }
                    }

                    // 曝光调整
                    Loader {
                        id: exposureSlider
                        Layout.fillWidth: true
                        source: "ParameterSlider.qml"
                        onLoaded: {
                            item.parameterName = "曝光"
                            item.value = Qt.binding(() => parameterController.exposure)
                            item.minimumValue = parameterController.getParameterRange("exposure")[0]
                            item.maximumValue = parameterController.getParameterRange("exposure")[1]
                            item.stepSize = 0.1
                            item.decimals = 1
                            item.suffix = " EV"
                            item.parameterValueChanged.connect((value) => parameterController.exposure = value)
                        }
                    }

                    // 对比度调整
                    Loader {
                        id: contrastSlider
                        Layout.fillWidth: true
                        source: "ParameterSlider.qml"
                        onLoaded: {
                            item.parameterName = "对比度"
                            item.value = Qt.binding(() => parameterController.contrast)
                            item.minimumValue = parameterController.getParameterRange("contrast")[0]
                            item.maximumValue = parameterController.getParameterRange("contrast")[1]
                            item.stepSize = 0.05
                            item.decimals = 2
                            item.parameterValueChanged.connect((value) => parameterController.contrast = value)
                        }
                    }

                    // 饱和度调整
                    Loader {
                        id: saturationSlider
                        Layout.fillWidth: true
                        source: "ParameterSlider.qml"
                        onLoaded: {
                            item.parameterName = "饱和度"
                            item.value = Qt.binding(() => parameterController.saturation)
                            item.minimumValue = parameterController.getParameterRange("saturation")[0]
                            item.maximumValue = parameterController.getParameterRange("saturation")[1]
                            item.stepSize = 0.05
                            item.decimals = 2
                            item.parameterValueChanged.connect((value) => parameterController.saturation = value)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#ddd"
                    }

                    // 高光调整
                    Loader {
                        id: highlightsSlider
                        Layout.fillWidth: true
                        source: "ParameterSlider.qml"
                        onLoaded: {
                            item.parameterName = "高光"
                            item.value = Qt.binding(() => parameterController.highlights)
                            item.minimumValue = parameterController.getParameterRange("highlights")[0]
                            item.maximumValue = parameterController.getParameterRange("highlights")[1]
                            item.stepSize = 1
                            item.decimals = 0
                            item.parameterValueChanged.connect((value) => parameterController.highlights = value)
                        }
                    }

                    // 阴影调整
                    Loader {
                        id: shadowsSlider
                        Layout.fillWidth: true
                        source: "ParameterSlider.qml"
                        onLoaded: {
                            item.parameterName = "阴影"
                            item.value = Qt.binding(() => parameterController.shadows)
                            item.minimumValue = parameterController.getParameterRange("shadows")[0]
                            item.maximumValue = parameterController.getParameterRange("shadows")[1]
                            item.stepSize = 1
                            item.decimals = 0
                            item.parameterValueChanged.connect((value) => parameterController.shadows = value)
                        }
                    }

                    // 自然饱和度调整
                    Loader {
                        id: vibranceSlider
                        Layout.fillWidth: true
                        source: "ParameterSlider.qml"
                        onLoaded: {
                            item.parameterName = "自然饱和度"
                            item.value = Qt.binding(() => parameterController.vibrance)
                            item.minimumValue = parameterController.getParameterRange("vibrance")[0]
                            item.maximumValue = parameterController.getParameterRange("vibrance")[1]
                            item.stepSize = 1
                            item.decimals = 0
                            item.parameterValueChanged.connect((value) => parameterController.vibrance = value)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#ddd"
                    }

                    // 色温调整
                    Loader {
                        id: temperatureSlider
                        Layout.fillWidth: true
                        source: "ParameterSlider.qml"
                        onLoaded: {
                            item.parameterName = "色温"
                            item.value = Qt.binding(() => parameterController.temperature)
                            item.minimumValue = parameterController.getParameterRange("temperature")[0]
                            item.maximumValue = parameterController.getParameterRange("temperature")[1]
                            item.stepSize = 50
                            item.decimals = 0
                            item.suffix = " K"
                            item.parameterValueChanged.connect((value) => parameterController.temperature = value)
                        }
                    }

                    // 色调调整
                    Loader {
                        id: tintSlider
                        Layout.fillWidth: true
                        source: "ParameterSlider.qml"
                        onLoaded: {
                            item.parameterName = "色调"
                            item.value = Qt.binding(() => parameterController.tint)
                            item.minimumValue = parameterController.getParameterRange("tint")[0]
                            item.maximumValue = parameterController.getParameterRange("tint")[1]
                            item.stepSize = 1
                            item.decimals = 0
                            item.parameterValueChanged.connect((value) => parameterController.tint = value)
                        }
                    }
                }
            }

            // 导出设置区域
            GroupBox {
                title: "导出设置"
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // 导出格式选择
                    RowLayout {
                        Label {
                            text: "格式:"
                            Layout.minimumWidth: 60
                        }
                        
                        ComboBox {
                            id: formatCombo
                            Layout.fillWidth: true
                            model: ["JPEG", "TIFF", "PNG"]
                            currentIndex: 0
                        }
                    }

                    // 质量设置（仅JPEG）
                    RowLayout {
                        visible: formatCombo.currentText === "JPEG"
                        
                        Label {
                            text: "质量:"
                            Layout.minimumWidth: 60
                        }
                        
                        Slider {
                            id: qualitySlider
                            Layout.fillWidth: true
                            from: 1
                            to: 100
                            value: 90
                            stepSize: 1
                        }
                        
                        Label {
                            text: Math.round(qualitySlider.value) + "%"
                            Layout.minimumWidth: 40
                        }
                    }

                    // 导出按钮
                    Button {
                        text: "批量导出"
                        Layout.fillWidth: true
                        enabled: projectController.rollLoaded
                        highlighted: true
                        icon.name: "document-export"
                        onClicked: {
                            // TODO: 启动导出流程
                            mainController.setStatus("准备导出...")
                        }
                    }
                }
            }

            // 底部填充
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 20
            }
        }
    }
} 