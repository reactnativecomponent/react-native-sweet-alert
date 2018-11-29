//
//  DWDialogVC.h
//  RCTDowinTools
//
//  Created by Dowin on 2018/11/29.
//  Copyright © 2018年 Dowin. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^userActionBlock)(NSInteger);

@interface DWDialogVC : UIViewController

+ (instancetype)sharedInstand;
- (void)showAlertWithTitle:(NSString *)strTitle subTitle:(NSString *)strSubTitle btnTitle:(NSString *)strBtnTitle otherBtnTitle:(NSString *)strOther  userActionBlock:(userActionBlock)userAction;


@end


