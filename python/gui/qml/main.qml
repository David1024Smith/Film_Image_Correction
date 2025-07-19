import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import Revela 1.0

ApplicationWindow {
    id: mainWindow
    width: 1400
    height: 900
    minimumWidth: 1000
    minimumHeight: 700
    visible: true
    title: "Film Image Correction - Revela"

    // 连接主控制器
    Component.onCompleted: {
        mainController.initialize()
    }

    // 菜单栏
    menuBar: MenuBar {
        Menu {
            title: "文件(&F)"
            Action {
                text: "打开胶卷文件夹(&O)"
                shortcut: "Ctrl+O"
                onTriggered: folderDialog.open()
            }
            MenuSeparator {}
            Action {
                text: "退出(&X)"
                shortcut: "Ctrl+Q"
                onTriggered: Qt.quit()
            }
        }
        
        Menu {
            title: "编辑(&E)"
            Action {
                text: "重置参数(&R)"
                onTriggered: parameterController.resetColorParameters()
            }
        }
        
        Menu {
            title: "视图(&V)"
            Action {
                text: "适应窗口(&F)"
                onTriggered: imageController.fitToWindow()
            }
            Action {
                text: "重置缩放(&Z)"
                onTriggered: imageController.resetZoom()
            }
        }
        
        Menu {
            title: "处理(&P)"
            Action {
                text: "分析胶卷(&A)"
                enabled: projectController.rollLoaded && !analysisController.analysisRunning
                onTriggered: {
                    mainController.setStatus("正在分析胶卷...")
                    analysisController.startAnalysis(projectController.getCurrentRoll())
                }
            }
            Action {
                text: "批量导出(&E)"
                enabled: projectController.rollLoaded
                onTriggered: {
                    exportDialog.open()
                }
            }
        }
        
        Menu {
            title: "帮助(&H)"
            Action {
                text: "关于(&A)"
                onTriggered: aboutDialog.open()
            }
        }
    }

    // 工具栏
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            
            ToolButton {
                text: "打开文件夹"
                icon.name: "folder-open"
                onClicked: folderDialog.open()
            }
            
            ToolSeparator {}
            
            ToolButton {
                text: analysisController.analysisRunning ? "停止分析" : "分析"
                icon.name: analysisController.analysisRunning ? "process-stop" : "analyze"
                enabled: projectController.rollLoaded
                onClicked: {
                    if (analysisController.analysisRunning) {
                        analysisController.stopAnalysis()
                    } else {
                        analysisController.startAnalysis(projectController.getCurrentRoll())
                    }
                }
            }
            
            ToolButton {
                text: "导出"
                icon.name: "export"
                enabled: projectController.rollLoaded
                onClicked: {
                    exportDialog.open()
                }
            }
            
            Item { Layout.fillWidth: true }
            
            // 分析进度显示
            ProgressBar {
                visible: analysisController.analysisRunning
                value: analysisController.analysisProgress
                Layout.preferredWidth: 120
                Layout.preferredHeight: 20
            }
            
            // 忙碌指示器
            BusyIndicator {
                visible: mainController.busy || analysisController.analysisRunning
                running: mainController.busy || analysisController.analysisRunning
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }
        }
    }

    // 主内容区域
    SplitView {
        id: mainSplitView
        anchors.fill: parent
        orientation: Qt.Horizontal

        // 左侧项目管理面板
        Loader {
            id: projectPanel
            SplitView.minimumWidth: 250
            SplitView.preferredWidth: 300
            SplitView.maximumWidth: 400
            source: "components/ProjectPanel.qml"
        }

        // 中央区域
        SplitView {
            SplitView.fillWidth: true
            SplitView.minimumWidth: 500
            orientation: Qt.Vertical

            // 实时图像预览区域
            Loader {
                id: liveImageViewer
                SplitView.fillHeight: true
                SplitView.minimumHeight: 400
                source: "components/LiveImageViewer.qml"
            }
        }

        // 右侧参数控制面板
        Loader {
            id: parameterPanel
            SplitView.minimumWidth: 250
            SplitView.preferredWidth: 320
            SplitView.maximumWidth: 450
            source: "components/ParameterPanel.qml"
        }
    }

    // 状态栏
    footer: ToolBar {
        height: 30
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            
            Label {
                text: analysisController.analysisRunning ? 
                      analysisController.analysisStatus : 
                      mainController.status
                Layout.fillWidth: true
            }
            
            Label {
                text: projectController.rollLoaded ? 
                      `胶卷: ${projectController.getRollName()} (${projectController.frameCount} 帧)` : 
                      "未加载胶卷"
                font.pointSize: 9
                color: "#666"
            }
            
            Label {
                text: imageController.imageLoaded ? 
                      `缩放: ${Math.round(imageController.zoomLevel * 100)}%` : 
                      ""
                font.pointSize: 9
                color: "#666"
            }
        }
    }

    // 文件夹选择对话框
    FolderDialog {
        id: folderDialog
        title: "选择胶卷文件夹"
        onAccepted: {
            if (projectController.filmType === "未选择") {
                filmTypeDialog.open()
                return
            }
            projectController.loadRollFromFolder(selectedFolder)
        }
    }

    // 胶片类型选择对话框
    Dialog {
        id: filmTypeDialog
        title: "选择胶片类型"
        width: 300
        height: 200
        anchors.centerIn: parent
        modal: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                text: "请选择胶片类型："
                font.bold: true
            }

            ComboBox {
                id: filmTypeCombo
                Layout.fillWidth: true
                model: projectController.supportedFilmTypes
                currentIndex: 0
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "取消"
                    onClicked: filmTypeDialog.close()
                }
                
                Button {
                    text: "确定"
                    highlighted: true
                    onClicked: {
                        projectController.setFilmType(filmTypeCombo.currentText)
                        filmTypeDialog.close()
                        projectController.loadRollFromFolder(folderDialog.selectedFolder)
                    }
                }
            }
        }
    }

    // 关于对话框
    Dialog {
        id: aboutDialog
        title: "关于 Film Image Correction"
        width: 400
        height: 300
        anchors.centerIn: parent
        modal: true

        ScrollView {
            anchors.fill: parent
            anchors.margins: 20

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: `
                <h2>Film Image Correction (Revela)</h2>
                <p>专业的胶片数字化处理系统</p>
                <p><b>版本:</b> 1.0.0</p>
                <p><b>基于:</b> PySide6 和 PyOpenColorIO</p>
                <br>
                <p>功能特性：</p>
                <ul>
                <li>• 自动胶片校准分析</li>
                <li>• 专业颜色管理</li>
                <li>• 批量图像处理</li>
                <li>• 高性能图像预览</li>
                </ul>
                `
            }
        }
    }

    // 错误消息处理
    Connections {
        target: mainController
        function onErrorOccurred(message) {
            errorDialog.text = message
            errorDialog.open()
        }
    }

    Connections {
        target: projectController
        function onErrorOccurred(message) {
            errorDialog.text = message
            errorDialog.open()
        }
        
        // 当帧列表变化时，确保图像控制器知道
        function onFrameCountChanged() {
            if (projectController.frameCount === 0) {
                imageController.loadImage("")  // 清除当前图像
            }
        }
    }
    
    Connections {
        target: analysisController
        function onAnalysisError(message) {
            errorDialog.text = "分析错误: " + message
            errorDialog.open()
        }
        
        function onAnalysisCompleted(calibrationData) {
            mainController.setStatus("胶卷分析完成")
        }
    }

    // 导出对话框
    Loader {
        id: exportDialog
        source: "components/ExportDialog.qml"
        active: false
        
        function open() {
            active = true
            if (item) {
                item.open()
            }
        }
    }

    // 预设管理对话框
    Loader {
        id: presetDialog
        source: "components/PresetDialog.qml"
        active: false
        
        property bool isLoadMode: true
        
        function open() {
            active = true
            if (item) {
                item.isLoadMode = isLoadMode
                item.open()
            }
        }
    }

    // 错误对话框
    Dialog {
        id: errorDialog
        title: "错误"
        property string text: ""
        anchors.centerIn: parent
        modal: true

        Label {
            text: errorDialog.text
            wrapMode: Text.WordWrap
            width: 300
        }
    }
} 