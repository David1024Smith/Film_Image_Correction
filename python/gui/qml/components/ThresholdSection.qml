import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "transparent"
    implicitHeight: headerHeight + (expanded ? contentHeight : 0)
    height: implicitHeight
    
    property int headerHeight: 64
    property int contentHeight: 320
    property bool expanded: false
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#333333"
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.headerHeight
            color: "transparent"
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.expanded = !root.expanded
                }
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                
                Text {
                    Layout.fillWidth: true
                    text: "阈值调节"
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                }
                
                Text {
                    text: root.expanded ? "▲" : "▼"
                    color: "#FFFFFF"
                    font.pixelSize: 12
                }
            }
        }
        
        // 内容区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.expanded ? root.contentHeight : 0
            color: "transparent"
            clip: true
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                anchors.topMargin: 0
                spacing: 16
                
                // 区域占比下限
                ThresholdSlider {
                    Layout.fillWidth: true
                    labelText: "区域占比下限"
                    minValue: 0
                    maxValue: 100
                    currentValue: 0
                    
                    onValueChanged: function(value) {
                        console.log("区域占比下限:", value)
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setAreaRatioMin(value)
                        }
                    }
                }
                
                // 区域占比上限
                ThresholdSlider {
                    Layout.fillWidth: true
                    labelText: "区域占比上限"
                    minValue: 0
                    maxValue: 100
                    currentValue: 100
                    
                    onValueChanged: function(value) {
                        console.log("区域占比上限:", value)
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setAreaRatioMax(value)
                        }
                    }
                }
                
                // 阈值上限
                ThresholdSlider {
                    Layout.fillWidth: true
                    labelText: "阈值上限"
                    minValue: 0
                    maxValue: 100
                    currentValue: 100
                    
                    onValueChanged: function(value) {
                        console.log("阈值上限:", value)
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setThresholdMax(value)
                        }
                    }
                }
                
                // 齿孔阈值
                ThresholdSlider {
                    Layout.fillWidth: true
                    labelText: "齿孔阈值"
                    minValue: 0
                    maxValue: 100
                    currentValue: 50
                    
                    onValueChanged: function(value) {
                        console.log("齿孔阈值:", value)
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setPerforationThreshold(value)
                        }
                    }
                }
                
                // 片夹阈值
                ThresholdSlider {
                    Layout.fillWidth: true
                    labelText: "片夹阈值"
                    minValue: 0
                    maxValue: 100
                    currentValue: 50
                    
                    onValueChanged: function(value) {
                        console.log("片夹阈值:", value)
                        if (typeof parameterController !== 'undefined') {
                            parameterController.setFilmClampThreshold(value)
                        }
                    }
                }
            }
        }
    }
}