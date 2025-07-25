import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import Revela 1.0

ApplicationWindow {
    id: fileManagementWindow
    width: 1400
    height: 900
    title: "Film Manager - Revela"
    visible: true

    property string currentPath: ""
    property var rollList: []
    property string selectedRoll: ""
    property int imageCount: 16
    property var imageList: []


    // 连接主控制器
    Component.onCompleted: {
        mainController.initialize()
        loadRolls()
        // 启动时不加载默认图像，等待用户导入
    }

    // 主背景
    Rectangle {
        anchors.fill: parent
        color: "#1C1C1E"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 顶部工具栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: "#000000"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#262626"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16

                    // 左侧图像数量控制
                    RowLayout {
                        spacing: 24

                        RowLayout {
                            spacing: 12

                            Button {
                                id: decreaseBtn
                                width: 24
                                height: 24
                                text: "−"
                                enabled: imageCount > 8
                                onClicked: {
                                    if (imageCount > 8) {
                                        imageCount--
                                        imageCountSlider.value = imageCount
                                    }
                                }

                                background: Rectangle {
                                    color: "transparent"
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? (parent.hovered ? "white" : "#9CA3AF") : "#4B5563"
                                    font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Slider {
                                id: imageCountSlider
                                width: 120
                                height: 20
                                from: 8
                                to: 32
                                value: imageCount
                                stepSize: 1
                                onValueChanged: {
                                    imageCount = Math.round(value)
                                }

                                background: Rectangle {
                                    x: imageCountSlider.leftPadding
                                    y: imageCountSlider.topPadding + imageCountSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 120
                                    implicitHeight: 4
                                    width: imageCountSlider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#333333"
                                }

                                handle: Rectangle {
                                    x: imageCountSlider.leftPadding + imageCountSlider.visualPosition * (imageCountSlider.availableWidth - width)
                                    y: imageCountSlider.topPadding + imageCountSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    radius: 8
                                    color: "#FFD60A"
                                }
                            }

                            Button {
                                id: increaseBtn
                                width: 24
                                height: 24
                                text: "+"
                                enabled: imageCount < 32
                                onClicked: {
                                    if (imageCount < 32) {
                                        imageCount++
                                        imageCountSlider.value = imageCount
                                    }
                                }

                                background: Rectangle {
                                    color: "transparent"
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? (parent.hovered ? "white" : "#9CA3AF") : "#4B5563"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Text {
                                text: imageCount.toString()
                                color: "#9CA3AF"
                                font.pixelSize: 14
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // 中央分类按钮
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Button {
                            text: "Roll-2"
                            height: 30
                            
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "Date"
                            height: 30
                            
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "Film"
                            height: 30
                            
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // 右侧成片按钮
                    Button {
                        text: "成片"
                        height: 36
                        enabled: rollList.length > 0 && selectedRoll !== ""
                        onClicked: {
                            // 跳转到调整窗口
                            var component = Qt.createComponent("adjustmentWindow.qml")
                            if (component.status === Component.Ready) {
                                var newWindow = component.createObject()
                                if (newWindow) {
                                    newWindow.show()
                                    fileManagementWindow.close()
                                }
                            }
                        }
                        
                        background: Rectangle {
                            color: parent.enabled ? 
                                   (parent.pressed ? "#E6C200" : (parent.hovered ? "#E6C200" : "#FFD60A")) :
                                   "#666666"
                            radius: 8
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "black" : "#999999"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // 主内容区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // 左侧边栏
                Rectangle {
                    Layout.preferredWidth: 240
                    Layout.fillHeight: true
                    color: "#171717"

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: "#262626"
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        // 搜索框
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            color: "#262626"
                            radius: 8

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Text {
                                    text: "🔍"
                                    color: "#9CA3AF"
                                    font.pixelSize: 14
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    placeholderText: "Search..."
                                    color: "white"
                                    font.pixelSize: 14
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                }
                            }
                        }

                        // Rolls标题
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Rolls"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        // 分割线
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#262626"
                        }

                        // 胶卷列表
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                width: parent.width
                                spacing: 16

                                Repeater {
                                    model: rollList

                                    Button {
                                        Layout.fillWidth: true
                                        height: 48
                                        
                                        background: Rectangle {
                                            color: selectedRoll === modelData.name ? "#FFD60A" : 
                                                   (parent.hovered ? "#262626" : "transparent")
                                            radius: 8
                                        }
                                        
                                        contentItem: RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12

                                            Text {
                                                text: modelData.name
                                                color: selectedRoll === modelData.name ? "black" : "white"
                                                font.pixelSize: 14
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: modelData.count.toString()
                                                color: selectedRoll === modelData.name ? "#666666" : "#9CA3AF"
                                                font.pixelSize: 14
                                            }
                                        }
                                        
                                        onClicked: {
                                            selectedRoll = modelData.name
                                            loadImages()
                                        }
                                    }
                                }
                            }
                        }

                        // 导入按钮
                        Button {
                            Layout.fillWidth: true
                            height: 48
                            text: "Import New Roll"
                            onClicked: folderDialog.open()
                            
                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // 主图像网格区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#1C1C1E"

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 24

                        GridLayout {
                            id: imageGrid
                            columns: 4
                            columnSpacing: 16
                            rowSpacing: 16
                            width: parent.width

                            Repeater {
                                model: Math.min(imageCount, imageList.length)

                                Rectangle {
                                    Layout.preferredWidth: (imageGrid.width - 3 * imageGrid.columnSpacing) / 4
                                    Layout.preferredHeight: Layout.preferredWidth
                                    color: "#262626"
                                    radius: 8

                                    // 图像显示
                                    Image {
                                        id: imagePreview
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        source: {
                                            if (index < imageList.length && imageList[index].path) {
                                                // 使用ImageController获取预览路径（处理TIFF转换）
                                                return imageController.getPreviewImagePath(imageList[index].path)
                                            }
                                            return ""
                                        }
                                        visible: source !== ""
                                        
                                        // 处理加载错误
                                        onStatusChanged: {
                                            if (status === Image.Error) {
                                                console.log("Image load error for:", source)
                                            } else if (status === Image.Ready) {
                                                console.log("Image loaded successfully:", source)
                                            }
                                        }
                                        
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                            radius: 4
                                            border.color: "#FFD60A"
                                            border.width: 0
                                            opacity: 0
                                            
                                            Behavior on opacity {
                                                NumberAnimation { duration: 200 }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: overlay
                                        anchors.fill: parent
                                        color: "#000000"
                                        opacity: 0
                                        radius: 8
                                        
                                        Behavior on opacity {
                                            NumberAnimation { duration: 200 }
                                        }

                                        Button {
                                            anchors.centerIn: parent
                                            text: "View"
                                            visible: overlay.opacity > 0
                                            
                                            background: Rectangle {
                                                color: parent.pressed ? "#E6C200" : "#FFD60A"
                                                radius: 8
                                            }
                                            
                                            contentItem: Text {
                                                text: parent.text
                                                color: "black"
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            
                                            onClicked: {
                                                // 使用ImageController加载选中的图像
                                                if (index < imageList.length && imageList[index].path) {
                                                    console.log("Loading image:", imageList[index].name)
                                                    imageController.loadImage(imageList[index].path)
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            if (imagePreview.source === "") {
                                                return "No Image"
                                            } else if (imagePreview.status === Image.Loading) {
                                                return "Loading..."
                                            } else if (imagePreview.status === Image.Error) {
                                                return "Error"
                                            } else {
                                                return ""
                                            }
                                        }
                                        color: "#9CA3AF"
                                        font.pixelSize: 14
                                        visible: overlay.opacity === 0 && (imagePreview.source === "" || imagePreview.status !== Image.Ready)
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: overlay.opacity = 0.4
                                        onExited: overlay.opacity = 0
                                        onClicked: {
                                            // 使用ImageController加载选中的图像
                                            if (index < imageList.length && imageList[index].path) {
                                                console.log("Loading image:", imageList[index].name)
                                                imageController.loadImage(imageList[index].path)
                                            }
                                        }
                                    }
                                }
                            }

                            // 如果图像数量不足，显示空白占位符
                            Repeater {
                                model: Math.max(0, imageCount - imageList.length)

                                Rectangle {
                                    Layout.preferredWidth: (imageGrid.width - 3 * imageGrid.columnSpacing) / 4
                                    Layout.preferredHeight: Layout.preferredWidth
                                    color: "#262626"
                                    radius: 8

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Empty"
                                        color: "#6B7280"
                                        font.pixelSize: 16
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 文件夹选择对话框
    FolderDialog {
        id: folderDialog
        title: "选择胶片文件夹"
        onAccepted: {
            var folderPath = selectedFolder.toString().replace("file:///", "")
            importRollFromFolder(folderPath)
        }
    }

    // 连接控制器信号
    Connections {
        target: projectController
        function onRollLoadedChanged() {
            if (projectController.rollLoaded) {
                // 胶卷加载成功，更新界面
                var frameCount = projectController.frameCount
                console.log("Roll loaded successfully with", frameCount, "frames")
                
                // 获取文件夹名称
                var folderName = projectController.getRollName()
                
                // 构建图像列表
                var images = []
                for (var i = 0; i < frameCount; i++) {
                    var framePath = projectController.getFramePath(i)
                    var frameName = projectController.getFrameName(i)
                    
                    // 过滤掉隐藏文件（以._开头的文件）
                    if (framePath && framePath !== "" && !frameName.startsWith("._")) {
                        images.push({
                            index: images.length,  // 重新索引
                            name: frameName,
                            path: framePath
                        })
                    }
                }
                
                // 检查是否已存在同名胶卷
                var existingIndex = -1
                for (var j = 0; j < rollList.length; j++) {
                    if (rollList[j].name === folderName) {
                        existingIndex = j
                        break
                    }
                }
                
                if (existingIndex >= 0) {
                    // 更新现有胶卷
                    var newRollList = rollList.slice()
                    newRollList[existingIndex] = {
                        name: folderName,
                        count: images.length,
                        path: projectController.rollPath
                    }
                    rollList = newRollList
                } else {
                    // 添加新胶卷
                    var newRollList = rollList.slice()
                    newRollList.push({
                        name: folderName,
                        count: images.length,
                        path: projectController.rollPath
                    })
                    rollList = newRollList
                }
                
                // 选择当前胶卷
                selectedRoll = folderName
                imageList = images
                
                console.log("Successfully imported roll:", folderName, "with", images.length, "valid images")
                
                // 加载第一张有效图像
                if (images.length > 0) {
                    imageController.loadImage(images[0].path)
                }
            }
        }

        function onErrorOccurred(message) {
            console.log("项目控制器错误:", message)
        }
    }

    Connections {
        target: imageController
        function onCurrentImageChanged() {
            // 当前图像变化时的处理
        }
    }

    Connections {
        target: mainController
        function onErrorOccurred(message) {
            console.log("主控制器错误:", message)
        }
    }

    // 函数
    function loadRolls() {
        // 启动时不加载默认胶卷，等待用户导入
        rollList = []
    }

    function loadImages() {
        // 切换胶卷时重新加载图像
        if (!selectedRoll) {
            imageList = []
            return
        }
        
        console.log("Loading images for roll:", selectedRoll)
        
        // 如果选中的胶卷有路径信息，重新加载
        var selectedRollData = null
        for (var i = 0; i < rollList.length; i++) {
            if (rollList[i].name === selectedRoll) {
                selectedRollData = rollList[i]
                break
            }
        }
        
        if (selectedRollData && selectedRollData.path) {
            // 重新加载这个胶卷
            projectController.loadRoll(selectedRollData.path)
        }
    }
    
    function importRollFromFolder(folderPath) {
        // 前端只负责调用后端，不处理文件扫描逻辑
        console.log("Importing roll from folder:", folderPath)
        
        // 设置默认胶片类型
        if (projectController.filmType === "未选择" || !projectController.filmType) {
            projectController.setFilmType("Portra 400")
        }
        
        // 调用ProjectController加载胶卷
        projectController.loadRoll(folderPath)
        
        // 等待ProjectController的信号通知结果
        // 结果将通过onRollLoadedChanged信号处理
    }
}