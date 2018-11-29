//
//  RCTDialogManager.m
//  RCTDowinTools
//
//  Created by Dowin on 2018/11/29.
//  Copyright © 2018年 Dowin. All rights reserved.
//

#import "RCTDialogManager.h"
#import "DWDialogVC.h"

@implementation RCTDialogManager

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(SweetAlert)


RCT_EXPORT_METHOD(showAlert:(NSString *)title message:(NSString *)message buttons:(NSArray *)btnArr resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
    NSString *strBtn = @"OK";
    NSString *strOtherBtn = @"";
    if(btnArr.count>1){
        strBtn = btnArr[1];
        strOtherBtn = btnArr[0];
    }else{
        strBtn = btnArr[0];
    }
    [[DWDialogVC sharedInstand] showAlertWithTitle:title subTitle:message btnTitle:strBtn otherBtnTitle:strOtherBtn userActionBlock:^(NSInteger tag) {
        resolve([NSNumber numberWithInteger:tag]);
    }];
}


@end
