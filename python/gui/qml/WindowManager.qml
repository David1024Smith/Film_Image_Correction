import QtQuick 2.15
import QtQuick.Controls 2.15

QtObject {
    id: windowManager
    
    // 窗口类型枚举
    readonly property int ADJUSTMENT_WINDOW: 0
    readonly property int PARAMETER_CONTROL_WINDOW: 1
    readonly property int FILE_MANAGEMENT_WINDOW: 2
    
    // 当前窗口引用
    property var currentWindow: null
    
    // 导航到指定窗口
    function navigateToWindow(windowType) {
        console.log("导航到窗口类型:", windowType)
        
        var qmlFile = ""
        switch(windowType) {
            case ADJUSTMENT_WINDOW:
                qmlFile = "adjustmentWindow.qml"
                break
            case PARAMETER_CONTROL_WINDOW:
                qmlFile = "parameterControlWindow.qml"
                break
            case FILE_MANAGEMENT_WINDOW:
                qmlFile = "fileManagementWindow.qml"
                break
            default:
                console.error("未知的窗口类型:", windowType)
                return false
        }
        
        try {
            // 创建新窗口组件
            var component = Qt.createComponent(qmlFile)
            if (component.status === Component.Ready) {
                // 关闭当前窗口
                if (currentWindow) {
                    currentWindow.close()
                }
                
                // 创建并显示新窗口
                var newWindow = component.createObject()
                if (newWindow) {
                    newWindow.show()
                    currentWindow = newWindow
                    console.log("成功导航到:", qmlFile)
                    return true
                } else {
                    console.error("无法创建窗口对象:", qmlFile)
                }
            } else if (component.status === Component.Error) {
                console.error("组件加载错误:", component.errorString())
            }
        } catch (error) {
            console.error("导航错误:", error)
        }
        
        return false
    }
    
    // 从adjustmentWindow导航到parameterControlWindow
    function fromAdjustmentToParameterControl() {
        return navigateToWindow(PARAMETER_CONTROL_WINDOW)
    }
    
    // 从parameterControlWindow导航到fileManagementWindow
    function fromParameterControlToFileManagement() {
        return navigateToWindow(FILE_MANAGEMENT_WINDOW)
    }
    
    // 从fileManagementWindow导航到adjustmentWindow
    function fromFileManagementToAdjustment() {
        return navigateToWindow(ADJUSTMENT_WINDOW)
    }
}