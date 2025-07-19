import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: histogramViewer
    color: "#2b2b2b"
    border.color: "#555"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // 标题和控制
        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "直方图"
                font.bold: true
                font.pointSize: 10
                color: "#fff"
            }

            Item { Layout.fillWidth: true }

            // 显示模式选择
            ComboBox {
                id: modeCombo
                model: histogramController.supportedModes
                currentIndex: {
                    let index = model.indexOf(histogramController.histogramMode)
                    return index >= 0 ? index : 0
                }
                onCurrentTextChanged: {
                    histogramController.histogramMode = currentText
                }
                
                background: Rectangle {
                    color: "#444"
                    border.color: "#666"
                    border.width: 1
                    radius: 3
                }
                
                contentItem: Text {
                    text: parent.displayText
                    color: "#fff"
                    font.pointSize: 9
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                }
            }
        }

        // 直方图显示区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1e1e1e"
            border.color: "#444"
            border.width: 1
            radius: 4

            Canvas {
                id: histogramCanvas
                anchors.fill: parent
                anchors.margins: 5

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    if (!histogramController.rHistogram.length && 
                        !histogramController.luminanceHistogram.length) {
                        // 显示占位符
                        _drawPlaceholder(ctx)
                        return
                    }

                    var maxValue = histogramController.getMaxHistogramValue()
                    if (maxValue <= 0) return

                    // 根据模式绘制直方图
                    switch (histogramController.histogramMode) {
                        case "RGB":
                            _drawRGBHistogram(ctx, maxValue)
                            break
                        case "Luminance":
                            _drawLuminanceHistogram(ctx, maxValue)
                            break
                        case "All":
                            _drawAllHistograms(ctx, maxValue)
                            break
                    }
                }

                function _drawPlaceholder(ctx) {
                    ctx.fillStyle = "#666"
                    ctx.font = "12px Arial"
                    ctx.textAlign = "center"
                    ctx.fillText("选择图像以显示直方图", width / 2, height / 2)
                }

                function _drawRGBHistogram(ctx, maxValue) {
                    var rHist = histogramController.rHistogram
                    var gHist = histogramController.gHistogram
                    var bHist = histogramController.bHistogram

                    if (rHist.length === 0) return

                    var binWidth = width / rHist.length
                    
                    // 绘制红色通道
                    ctx.globalAlpha = 0.7
                    ctx.fillStyle = "#ff4444"
                    _drawHistogramBars(ctx, rHist, maxValue, binWidth)
                    
                    // 绘制绿色通道
                    ctx.fillStyle = "#44ff44"
                    _drawHistogramBars(ctx, gHist, maxValue, binWidth)
                    
                    // 绘制蓝色通道
                    ctx.fillStyle = "#4444ff"
                    _drawHistogramBars(ctx, bHist, maxValue, binWidth)
                    
                    ctx.globalAlpha = 1.0
                }

                function _drawLuminanceHistogram(ctx, maxValue) {
                    var lumHist = histogramController.luminanceHistogram
                    if (lumHist.length === 0) return

                    var binWidth = width / lumHist.length
                    
                    ctx.fillStyle = "#ffffff"
                    _drawHistogramBars(ctx, lumHist, maxValue, binWidth)
                }

                function _drawAllHistograms(ctx, maxValue) {
                    // 先绘制亮度直方图作为背景
                    var lumHist = histogramController.luminanceHistogram
                    if (lumHist.length > 0) {
                        var binWidth = width / lumHist.length
                        ctx.globalAlpha = 0.3
                        ctx.fillStyle = "#ffffff"
                        _drawHistogramBars(ctx, lumHist, maxValue, binWidth)
                    }
                    
                    // 然后绘制RGB直方图
                    _drawRGBHistogram(ctx, maxValue)
                }

                function _drawHistogramBars(ctx, histogram, maxValue, binWidth) {
                    for (var i = 0; i < histogram.length; i++) {
                        var barHeight = (histogram[i] / maxValue) * height
                        var x = i * binWidth
                        var y = height - barHeight
                        
                        ctx.fillRect(x, y, binWidth, barHeight)
                    }
                }

                // 监听直方图数据变化
                Connections {
                    target: histogramController
                    function onHistogramDataChanged() {
                        histogramCanvas.requestPaint()
                    }
                    function onHistogramModeChanged() {
                        histogramCanvas.requestPaint()
                    }
                }
            }

            // 加载指示器
            BusyIndicator {
                anchors.centerIn: parent
                running: histogramController.isCalculating
                width: 32
                height: 32
            }

            // 网格线（可选）
            Canvas {
                anchors.fill: parent
                anchors.margins: 5
                z: -1

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    
                    // 绘制垂直网格线
                    ctx.strokeStyle = "#333"
                    ctx.lineWidth = 1
                    ctx.globalAlpha = 0.3
                    
                    for (var i = 1; i < 4; i++) {
                        var x = (width / 4) * i
                        ctx.beginPath()
                        ctx.moveTo(x, 0)
                        ctx.lineTo(x, height)
                        ctx.stroke()
                    }
                    
                    // 绘制水平网格线
                    for (var j = 1; j < 4; j++) {
                        var y = (height / 4) * j
                        ctx.beginPath()
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                        ctx.stroke()
                    }
                    
                    ctx.globalAlpha = 1.0
                }
            }
        }

        // 统计信息显示
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "#333"
            border.color: "#555"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 15

                // RGB通道统计
                ColumnLayout {
                    visible: histogramController.histogramMode !== "Luminance"
                    spacing: 2

                    Label {
                        text: "RGB"
                        font.bold: true
                        font.pointSize: 9
                        color: "#fff"
                    }

                    RowLayout {
                        spacing: 8

                        Rectangle {
                            width: 12
                            height: 12
                            color: "#ff4444"
                            radius: 2
                        }
                        Label {
                            text: "R"
                            font.pointSize: 8
                            color: "#ccc"
                        }

                        Rectangle {
                            width: 12
                            height: 12
                            color: "#44ff44"
                            radius: 2
                        }
                        Label {
                            text: "G"
                            font.pointSize: 8
                            color: "#ccc"
                        }

                        Rectangle {
                            width: 12
                            height: 12
                            color: "#4444ff"
                            radius: 2
                        }
                        Label {
                            text: "B"
                            font.pointSize: 8
                            color: "#ccc"
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: parent.height * 0.6
                    color: "#555"
                    visible: histogramController.histogramMode === "All"
                }

                // 亮度统计
                ColumnLayout {
                    visible: histogramController.histogramMode !== "RGB"
                    spacing: 2

                    Label {
                        text: "亮度"
                        font.bold: true
                        font.pointSize: 9
                        color: "#fff"
                    }

                    RowLayout {
                        Rectangle {
                            width: 12
                            height: 12
                            color: "#ffffff"
                            radius: 2
                        }
                        Label {
                            text: "Lum"
                            font.pointSize: 8
                            color: "#ccc"
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // 刷新按钮
                Button {
                    text: "刷新"
                    enabled: !histogramController.isCalculating && 
                            imageController.imageLoaded
                    onClicked: {
                        if (imageController.imageLoaded) {
                            // 获取当前图像路径并计算直方图
                            var imagePath = imageController.currentImagePath
                            if (imagePath.startsWith("image://")) {
                                // 从图像提供器URL中提取实际路径
                                var parts = imagePath.split(":")
                                if (parts.length >= 3) {
                                    imagePath = parts.slice(2).join(":")
                                    histogramController.calculateHistogram(imagePath)
                                }
                            }
                        }
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#555" : "#444"
                        border.color: "#666"
                        border.width: 1
                        radius: 3
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#fff"
                        font.pointSize: 9
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // 监听图像变化，自动更新直方图
    Connections {
        target: imageController
        function onCurrentImageChanged() {
            if (imageController.imageLoaded) {
                // 延迟一点时间再计算，确保图像已加载
                updateTimer.restart()
            } else {
                histogramController.clearHistogram()
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (imageController.imageLoaded) {
                var imagePath = imageController.currentImagePath
                if (imagePath.startsWith("image://")) {
                    var parts = imagePath.split(":")
                    if (parts.length >= 3) {
                        imagePath = parts.slice(2).join(":")
                        histogramController.calculateHistogram(imagePath)
                    }
                }
            }
        }
    }
}