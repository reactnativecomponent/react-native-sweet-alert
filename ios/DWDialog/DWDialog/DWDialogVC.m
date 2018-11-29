//
//  DWDialogVC.m
//  RCTDowinTools
//
//  Created by Dowin on 2018/11/29.
//  Copyright © 2018年 Dowin. All rights reserved.
//

#import "DWDialogVC.h"

#define kHeightMargin        10.0
#define KTopMargin           20.0
#define kWidthMargin         10.0
#define kAnimatedViewHeight  60.0
#define kMaxHeight           300.0
#define kContentWidth        300.0
#define kButtonHeight        35.0
#define kTitleHeight         30.0


@interface DWDialogVC ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSMutableArray *btnArr;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (copy, nonatomic) userActionBlock userAction;

@end

@implementation DWDialogVC

- (void)dealloc{
    
}

+ (instancetype)sharedInstand{
    static DWDialogVC *vc = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vc = [[DWDialogVC alloc]init];
    });
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self resizeAndRelayout];
}

- (void)setupContentView{
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor;
    [self.view addSubview:_contentView];
}

- (void)setupTitleLabel{
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.text = @"";
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:25];
    self.titleLabel.textColor = [UIColor colorWithRed:87/255.0 green:87/255.0 blue:87/255.0 alpha:1.0];
    [self.contentView addSubview:self.titleLabel];
}

- (void)setupSubTitleLabel{
    self.subTitleLabel = [[UILabel alloc]init];
    self.subTitleLabel.numberOfLines = 0;
    self.subTitleLabel.text = @"";
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.font = [UIFont systemFontOfSize:16];
    self.subTitleLabel.textColor = [UIColor colorWithRed:121/255.0 green:121/255.0 blue:121/255.0 alpha:1.0];
    [self.contentView addSubview:self.subTitleLabel];
}

- (void)resizeAndRelayout{
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    self.view.frame = mainScreenBounds;
    CGFloat x = kWidthMargin;
    CGFloat y = KTopMargin;
    CGFloat width = kContentWidth - kWidthMargin*2;
    
    if (self.titleLabel.text.length) {
        self.titleLabel.frame = CGRectMake(x, y, width, kTitleHeight);
        [self.contentView addSubview:self.titleLabel];
        y += kTitleHeight + kHeightMargin;
    }
    if (self.subTitleLabel.text.length) {
        NSString *tmpStr = self.subTitleLabel.text;
        CGRect textRect = [tmpStr boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSForegroundColorAttributeName:self.subTitleLabel.font} context:nil];
        CGFloat textViewHeight = ceil(textRect.size.height)+15.0;
        self.subTitleLabel.frame = CGRectMake(x, y, width, textViewHeight);
        [self.contentView addSubview:self.subTitleLabel];
        y += textViewHeight + kHeightMargin;
    }
    
    if (self.btnArr.count) {
        NSMutableArray *btnRects = [NSMutableArray array];
        for (UIButton *btn in self.btnArr) {
            NSString *strBtn = btn.titleLabel.text;
            CGRect btnRect = [strBtn boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSForegroundColorAttributeName:btn.titleLabel.font} context:nil];
            [btnRects addObject:NSStringFromCGRect(btnRect)];
        }
        CGFloat totalWidth = 0.0;
        if (self.btnArr.count == 2) {
            CGRect btn1Rect = CGRectFromString(btnRects[0]);
            CGRect btn2Rect = CGRectFromString(btnRects[1]);
            totalWidth = btn1Rect.size.width + btn2Rect.size.width + kWidthMargin + 80;
        }else{
            totalWidth = CGRectFromString(btnRects[0]).size.width + 40;
        }
        y += kHeightMargin;
        CGFloat btnX = (kContentWidth - totalWidth ) / 2.0;
        for (int i=0; i<self.btnArr.count; i++) {
            UIButton *tmpBtn = self.btnArr[i];
            CGRect tmpBtnRect = CGRectFromString(btnRects[i]);
            tmpBtn.frame = CGRectMake(btnX, y, tmpBtnRect.size.width+40, tmpBtnRect.size.height+20);
            tmpBtn.layer.cornerRadius = 5.0;
            tmpBtn.layer.masksToBounds = YES;
            btnX = tmpBtn.frame.origin.x + kWidthMargin + tmpBtn.frame.size.width;
            [self.contentView addSubview:tmpBtn];
            [tmpBtn addTarget:self action:@selector(clickPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        CGRect firstRect = CGRectFromString(btnRects[0]);
        y += kHeightMargin + firstRect.size.height + 20.0;
    }
    if (y > kMaxHeight) {
        CGFloat diff = y - kMaxHeight;
        CGRect sFrame = self.subTitleLabel.frame;
        self.subTitleLabel.frame = CGRectMake(sFrame.origin.x, sFrame.origin.y, sFrame.size.width, sFrame.size.height-diff);
        for (UIButton *tmpBtn in self.btnArr) {
            CGRect bFrame = tmpBtn.frame;
            tmpBtn.frame = CGRectMake(bFrame.origin.x, bFrame.origin.y-diff, bFrame.size.width, bFrame.size.height);
        }
        y = kMaxHeight;
    }
    self.contentView.frame = CGRectMake((mainScreenBounds.size.width-kContentWidth)*0.5, (mainScreenBounds.size.height - y)*0.5, kContentWidth, y);
    self.contentView.clipsToBounds = YES;
}

- (void)clickPressed:(UIButton *)btn{
    [self closeAlert:btn.tag];
}

- (void)closeAlert:(NSInteger)tag{
    if (self.userAction) {
        self.userAction(tag);
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
        self.view.window.windowLevel = UIWindowLevelNormal - 1;
        [self.view removeFromSuperview];
        [self cleanUpAlert];
    }];
}

- (void)cleanUpAlert{
    [self.contentView removeFromSuperview];
    self.contentView = [[UIView alloc]init];
}



- (void)showAlertWithTitle:(NSString *)strTitle subTitle:(NSString *)strSubTitle btnTitle:(NSString *)strBtnTitle otherBtnTitle:(NSString *)strOther  userActionBlock:(userActionBlock)userAction{
    self.userAction = userAction;
    static UIWindow *wind;
    if (wind == nil) {
        wind = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    wind.windowLevel = UIWindowLevelStatusBar +2;
    [wind addSubview:self.view];
    [wind makeKeyAndVisible];
    [self setupContentView];
    [self setupTitleLabel];
    [self setupSubTitleLabel];

    self.titleLabel.text = strTitle;
    if (strSubTitle.length) {
        self.subTitleLabel.text = strSubTitle;
    }
    self.btnArr = [NSMutableArray array];

        if(strBtnTitle.length){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitle:strBtnTitle forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:147/255.0 green:222/255.0 blue:244/255.0 alpha:1.0]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:150/255.0 green:191/255.0 blue:210/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
            btn.userInteractionEnabled = YES;
            btn.tag = 1;
            [self.btnArr addObject:btn];
        }
        if(strOther.length){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitle:strOther forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:182/255.0 green:182/255.0 blue:182/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
            btn.userInteractionEnabled = YES;
            btn.tag = 0;
//            [self.btnArr addObject:btn];
            [self.btnArr insertObject:btn atIndex:0];
        }
    [self resizeAndRelayout];
    [self animateAlert];
}

- (void)animateAlert{
    self.view.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.view.alpha = 1.0;
    }];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
