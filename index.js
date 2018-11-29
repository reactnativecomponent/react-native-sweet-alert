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

export default class SweetAlertAndroid {

    static show(title: ?string,
                message?: ?string,
                buttons?: Buttons,
                options?: Options,
                type?: number,
                image?): void {
        console.info(SweetAlert);
        console.info("SweetAlertAndroid show", title,message,buttons,options,type,resolveAssetSource(image));

        let config = {
            title: title || '',
            message: message || '',
            type: type || 0,
            image: resolveAssetSource(image) || undefined,
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
