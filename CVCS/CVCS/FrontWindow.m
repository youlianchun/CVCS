//
//  FrontWindow.m
//  CVCS
//
//  Created by YLCHUN on 2017/2/21.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "FrontWindow.h"

@interface _FrontWindow : UIWindow
@property (nonatomic, retain) FrontWindow *controller;
//@property(nonatomic) BOOL enabled;
//-(void)_addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer;
//-(void)set_alpha:(CGFloat)alpha;
//-(void)set_windowLevel:(UIWindowLevel)windowLevel;
//-(void)_removeFromSuperview;
@end
@implementation _FrontWindow
//-(void)setBounds:(CGRect)bounds {}
//-(void)setFrame:(CGRect)frame {}
//-(void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer {}
//-(void)removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {}
//-(void)_addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer {[super addGestureRecognizer:gestureRecognizer];}
//-(void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {}
//-(void)setEnabled:(BOOL)enabled {super.userInteractionEnabled = enabled;}
//-(BOOL)enabled {return super.userInteractionEnabled;}
//-(void)setAlpha:(CGFloat)alpha {}
//-(void)set_alpha:(CGFloat)alpha {super.alpha = alpha;}
//-(void)removeFromSuperview {}
//-(void)_removeFromSuperview {[super removeFromSuperview];}
//-(void)setWindowLevel:(UIWindowLevel)windowLevel {}
//-(void)set_windowLevel:(UIWindowLevel)windowLevel {super.windowLevel = windowLevel;}
//-(void)setRootViewController:(UIViewController *)rootViewController {}
@end

static CGFloat fw_kSideLength = 50.0;

@interface FrontWindow()
@property (nonatomic, retain) _FrontWindow *frontWindow;
@end

@implementation FrontWindow

-(instancetype)init {
    self = [super init];
    if (self) {
        [self construction];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

/**
 *  属性初始化构造
 */
-(void)construction {
    self.frontWindow = [[_FrontWindow alloc] initWithFrame:CGRectMake(0, 0, fw_kSideLength, fw_kSideLength)];
    self.frontWindow.controller = self;//相互持有，避免被释放
    self.frontWindow.center = CGPointMake(self.frontWindow.bounds.size.height/3, 100);
    self.frontWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.frontWindow.windowLevel = UIWindowLevelAlert + 1;
    [self.frontWindow makeKeyAndVisible];
    UIApplication *app = [UIApplication sharedApplication];
    if (app.delegate && app.delegate.window) {
        [app.delegate.window makeKeyAndVisible];
    }
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    [self.frontWindow addGestureRecognizer:pan];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:UIKeyboardDidHideNotification object:nil];
}

-(void)keyboardShow {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIWindow *lastWindow = (UIWindow *)[windows lastObject];
    self.frontWindow.windowLevel = lastWindow.windowLevel + 1;
}

-(void)keyboardHide {
    self.frontWindow.windowLevel = self.frontWindow.windowLevel - 1;
}

/**
 *  窗体拖动事件
 *
 *  @param sender <#sender description#>
 */
-(void)panAction:(UIPanGestureRecognizer*)sender {
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [sender locationInView:appWindow];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.frontWindow.alpha = 1.0;
        }break;
        case UIGestureRecognizerStateChanged:
        {
            self.frontWindow.center = panPoint;
        }break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.frontWindow.alpha = 0.7;
            CGFloat selfWidth = self.frontWindow.bounds.size.width;
            CGFloat selfHeight = self.frontWindow.bounds.size.height;
            CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            
            CGFloat left = fabs(panPoint.x);
            CGFloat right = fabs(screenWidth - left);
            CGFloat top = fabs(panPoint.y);
            //        CGFloat bottom = fabs(screenHeight - top);
            
            CGFloat minSpace = 0;
            minSpace = MIN(left, right);//仅可停留在左、右
            //        minSpace = MIN(MIN(MIN(top, left), bottom), right);//可停留在上、下、左、右
            
            CGPoint center;
            CGFloat targetY = 0;
            
            //校正Y
            if (panPoint.y < 15 + selfHeight / 2.0) {
                targetY = 15 + selfHeight / 2.0;
            }else if (panPoint.y > (screenHeight - selfHeight / 2.0 - 15)) {
                targetY = screenHeight - selfHeight / 2.0 - 15;
            }else{
                targetY = panPoint.y;
            }
            
            if (minSpace == left) {
                center = CGPointMake(selfHeight / 3, targetY);
            }else if (minSpace == right) {
                center = CGPointMake(screenWidth - selfHeight / 3, targetY);
            }else if (minSpace == top) {
                center = CGPointMake(panPoint.x, selfWidth / 3);
            }else {
                center = CGPointMake(panPoint.x, screenHeight - selfWidth / 3);
            }
            
            [UIView animateWithDuration:0.25 animations:^{
                self.frontWindow.center = center;
            }];
        }break;
        default:
            break;
    }
    [sender setTranslation:CGPointMake(0, 0) inView:appWindow];
}

-(CGRect)bounds {
    return self.frontWindow.bounds;
}

-(CGFloat)sideLength {
    return fw_kSideLength;
}

-(void)addSubview:(UIView*)view {
    [self.frontWindow addSubview:view];
}
-(void)removeFromApplication {
    self.frontWindow.controller = nil;
    [self.frontWindow removeFromSuperview];
}
@end
