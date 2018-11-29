import {NativeModules, Platform} from 'react-native'

const resolveAssetSource = require('resolveAssetSource');
const {SweetAlert} = NativeModules

export type Buttons = Array<{
    text?: string,
    onPress?: ?Function,
}>;

type Options = {
    cancelable?: ?boolean,
    onDismiss?: ?Function,
};

export default class SweetAlertRN {

    /**
     * SweetAlert.show("标题", "消息",
     [{
                            text: "取消", onPress: () => {
                                console.info("cancel");
                            }
                        }, {
                            text: "确定", onPress: () => {
                                console.info("confirm");
                            }
                        }], {
                            cancelable: true, onDismiss: (e) => {
                                console.info("dismiss");
                            }
                        });
     *
     * @param title
     * @param message
     * @param buttons
     * @param options
     */
    static show(title: ?string,
                message?: ?string,
                buttons?: Buttons,
                options?: Options,): void {
        console.info(SweetAlert);
        console.info("SweetAlertRN show", title, message, buttons, options);

        let config = {
            title: title || '',
            message: message || '',
            type: 0,
            image: undefined,
        };

        if (options) {
            config = {...config, cancelable: options.cancelable};
        }
        // At most three buttons (neutral, negative, positive). Ignore rest.
        // The text 'OK' should be probably localized. iOS Alert does that in native.
        const validButtons: Buttons = buttons
            ? buttons.slice(0, 2)
            : [{text: 'OK'}];
        const buttonPositive = validButtons.pop();
        const buttonNegative = validButtons.pop();
        if (buttonNegative) {
            config = {...config, buttonNegative: buttonNegative.text || ''};
        }
        if (buttonPositive) {
            config = {...config, buttonPositive: buttonPositive.text || ''};
        }
        SweetAlert.showAlert(
            config,
            errorMessage => console.warn(errorMessage),
            (action, buttonKey) => {
                if (action === SweetAlert.buttonClicked) {

                    if (buttonKey === SweetAlert.buttonNegative) {
                        buttonNegative.onPress && buttonNegative.onPress();
                    } else if (buttonKey === SweetAlert.buttonPositive) {
                        buttonPositive.onPress && buttonPositive.onPress();
                    }
                } else if (action === SweetAlert.dismissed) {
                    options && options.onDismiss && options.onDismiss();
                }
            },
        );

    }
}
