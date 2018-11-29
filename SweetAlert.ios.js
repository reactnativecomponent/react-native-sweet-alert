import { NativeModules, Platform, NetInfo } from 'react-native'

const { SweetAlert } = NativeModules


class Alert {

    /**
     * 弹框
     * title: 标题
     * message : 内容
     * buttons: ['cancel','ok']
     * @returns 点击确定返回1，取消返回0
     */
    showAlert(title, message, buttons) {
        return SweetAlert.showAlert(title, message, buttons)
    }  


}

export default new Alert()