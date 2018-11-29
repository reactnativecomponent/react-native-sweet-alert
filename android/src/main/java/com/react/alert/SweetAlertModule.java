package com.react.alert;

import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.net.Uri;
import android.util.Log;

import com.facebook.common.executors.CallerThreadExecutor;
import com.facebook.common.references.CloseableReference;
import com.facebook.datasource.DataSource;
import com.facebook.datasource.DataSubscriber;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.imagepipeline.datasource.BaseBitmapDataSubscriber;
import com.facebook.imagepipeline.image.CloseableImage;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.PixelUtil;

import java.util.Map;

import javax.annotation.Nullable;

import cn.pedant.SweetAlert.SweetAlertDialog;

/**
 * Created on 2018/9/14.
 */

@ReactModule(name = SweetAlertModule.NAME)
public class SweetAlertModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    final static String NAME = "SweetAlert";

    /* package */ static final String ACTION_BUTTON_CLICKED = "buttonClicked";
    /* package */ static final String ACTION_DISMISSED = "dismissed";

    /* package */ static final String KEY_TYPE = "type";
    /* package */ static final String KEY_TITLE = "title";
    /* package */ static final String KEY_MESSAGE = "message";
    /* package */ static final String KEY_BUTTON_POSITIVE = "buttonPositive";
    /* package */ static final String KEY_BUTTON_NEGATIVE = "buttonNegative";
    /* package */ static final String KEY_ITEMS = "items";
    /* package */ static final String KEY_CANCELABLE = "cancelable";

    /* package */ static final String KEY_TEXT = "text";
    /* package */ static final String KEY_IMAGE = "image";


    /* package */ static final String NORMAL_TYPE = "NORMAL_TYPE";
    /* package */ static final String ERROR_TYPE = "ERROR_TYPE";
    /* package */ static final String SUCCESS_TYPE = "SUCCESS_TYPE";
    /* package */ static final String WARNING_TYPE = "WARNING_TYPE";
    /* package */ static final String CUSTOM_IMAGE_TYPE = "CUSTOM_IMAGE_TYPE";
    /* package */ static final String PROGRESS_TYPE = "PROGRESS_TYPE";


    /* package */ static final Map<String, Object> CONSTANTS_TYPE = MapBuilder.<String, Object>of(
            NORMAL_TYPE, SweetAlertDialog.NORMAL_TYPE,
            ERROR_TYPE, SweetAlertDialog.ERROR_TYPE,
            SUCCESS_TYPE, SweetAlertDialog.SUCCESS_TYPE,
            WARNING_TYPE, SweetAlertDialog.WARNING_TYPE,
            CUSTOM_IMAGE_TYPE, SweetAlertDialog.CUSTOM_IMAGE_TYPE,
            PROGRESS_TYPE, SweetAlertDialog.PROGRESS_TYPE);

    /* package */ static final Map<String, Object> CONSTANTS = MapBuilder.<String, Object>of(
            ACTION_BUTTON_CLICKED, ACTION_BUTTON_CLICKED,
            ACTION_DISMISSED, ACTION_DISMISSED,

            KEY_BUTTON_POSITIVE, DialogInterface.BUTTON_POSITIVE,
            KEY_BUTTON_NEGATIVE, DialogInterface.BUTTON_NEGATIVE);

   static {
       CONSTANTS.putAll(CONSTANTS_TYPE);
   }

    private final ReactApplicationContext reactContext;
    private boolean mIsInForeground;
    private boolean showInForeground = false;

    public SweetAlertModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return NAME;
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        return CONSTANTS;
    }

    @Override
    public void initialize() {
        getReactApplicationContext().addLifecycleEventListener(this);
    }

    SweetAlertDialog sweetAlertDialog;

    @ReactMethod
    public void showAlert(ReadableMap options, Callback errorCallback, final Callback actionCallback) {

        Log.e(getName(), "" + options);
        if (options != null) {

            int type = SweetAlertDialog.NORMAL_TYPE;
            if (options.hasKey(KEY_TYPE)) {
                type = options.getInt(KEY_TYPE);
                if (type < SweetAlertDialog.NORMAL_TYPE) {
                    type = SweetAlertDialog.NORMAL_TYPE;
                }
                if (type > SweetAlertDialog.PROGRESS_TYPE) {
                    type = SweetAlertDialog.PROGRESS_TYPE;
                }
            }
            SweetAlertDialog dialog = new SweetAlertDialog(getCurrentActivity(), type);

            if (options.hasKey(KEY_TITLE)) {
                dialog.setTitleText(options.getString(KEY_TITLE));
            }
            if (options.hasKey(KEY_MESSAGE)) {
                dialog.setContentText(options.getString(KEY_MESSAGE));
            }
            if (options.hasKey(KEY_BUTTON_POSITIVE)) {
                ReadableType readableType = options.getType(KEY_BUTTON_POSITIVE);
                if (readableType == ReadableType.String) {
                    dialog.setConfirmText(options.getString(KEY_BUTTON_POSITIVE));
                } else if (readableType == ReadableType.Map) {
                    ReadableMap m = options.getMap(KEY_BUTTON_POSITIVE);
                    dialog.setConfirmText(m.getString(KEY_TEXT));
                    dialog.setConfirmClickListener(new SweetAlertDialog.OnSweetClickListener() {
                        @Override
                        public void onClick(SweetAlertDialog sDialog) {
                            sDialog.dismiss();
                            actionCallback.invoke(ACTION_BUTTON_CLICKED, DialogInterface.BUTTON_POSITIVE);
                        }
                    });
                }
            }

            if (options.hasKey(KEY_BUTTON_NEGATIVE)) {

                ReadableType readableType = options.getType(KEY_BUTTON_NEGATIVE);
                if (readableType == ReadableType.String) {
                    dialog.setCancelText(options.getString(KEY_BUTTON_NEGATIVE));
                } else if (readableType == ReadableType.Map) {
                    ReadableMap m = options.getMap(KEY_BUTTON_NEGATIVE);
                    dialog.setCancelText(m.getString(KEY_TEXT));
                    dialog.setCancelClickListener(new SweetAlertDialog.OnSweetClickListener() {
                        @Override
                        public void onClick(SweetAlertDialog sDialog) {
                            sDialog.dismiss();
                            actionCallback.invoke(ACTION_BUTTON_CLICKED, DialogInterface.BUTTON_NEGATIVE);
                        }
                    });
                }
            }
            dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    actionCallback.invoke(ACTION_DISMISSED);
                }
            });
            if (options.hasKey(KEY_ITEMS)) {
                ReadableArray items = options.getArray(KEY_ITEMS);
                CharSequence[] itemsArray = new CharSequence[items.size()];
                for (int i = 0; i < items.size(); i++) {
                    itemsArray[i] = items.getString(i);
                }
//                args.putCharSequenceArray(AlertFragment.ARG_ITEMS, itemsArray);
            }
            if (options.hasKey(KEY_CANCELABLE)) {
                dialog.setCancelable(options.getBoolean(KEY_CANCELABLE));
            }

            if (type == SweetAlertDialog.CUSTOM_IMAGE_TYPE && options.hasKey(KEY_IMAGE)) {
                loadImage(dialog, options.getMap(KEY_IMAGE));
            }

            if (mIsInForeground) {
                dialog.show();
            } else {
                sweetAlertDialog = dialog;
                showInForeground = true;
            }

//            cust(source);
        }

    }

    @Override
    public void onHostResume() {
        mIsInForeground = true;
        if (showInForeground) {
            sweetAlertDialog.show();
            showInForeground = false;
        }
    }

    @Override
    public void onHostPause() {
        mIsInForeground = false;
    }

    @Override
    public void onHostDestroy() {

        if (sweetAlertDialog != null) {
            try {
                sweetAlertDialog.dismiss();
            } catch (Exception e) {
                e.printStackTrace();
            }
            sweetAlertDialog = null;
        }
    }

    void loadImage(final SweetAlertDialog dialog, ReadableMap source) {
        String uriString = source.getString("uri");
        Uri uri = Uri.parse(uriString);
        ImageRequest request = ImageRequestBuilder.newBuilderWithSource(uri).build();
        DataSource<CloseableReference<CloseableImage>> prefetchSource = Fresco.getImagePipeline().fetchDecodedImage(request, this);

        DataSubscriber<CloseableReference<CloseableImage>> prefetchSubscriber = new BaseBitmapDataSubscriber() {
            @Override
            protected void onNewResultImpl(@Nullable Bitmap bitmap) {
                dialog.setCustomImage(new BitmapDrawable(reactContext.getResources(), bitmap));
            }

            @Override
            protected void onFailureImpl(DataSource<CloseableReference<CloseableImage>> dataSource) {

            }
        };
        prefetchSource.subscribe(prefetchSubscriber, CallerThreadExecutor.getInstance());
    }

    StateListDrawable createColor(int pressdColor, int defaultColor) {

        StateListDrawable state = new StateListDrawable();
        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setCornerRadius(PixelUtil.toPixelFromDIP(6));
        drawable.setColor(pressdColor);
        state.addState(new int[]{}, drawable);

        drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setCornerRadius(PixelUtil.toPixelFromDIP(6));
        drawable.setColor(defaultColor);
        state.addState(new int[]{}, drawable);

        return state;
    }
}
