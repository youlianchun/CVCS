//
//  FrontWindow.m
//  CVCS
//
//  Created by YLCHUN on 2017/2/21.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "FrontWindow.h"

@implementation FrontWindow

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self construction];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:UIKeyboardDidHideNotification object:nil];
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
    //    [self keyboardShow];
    self.windowLevel = UIWindowLevelAlert + 1;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self makeKeyAndVisible];
    UIApplication *app = [UIApplication sharedApplication];
    if (app.delegate && app.delegate.window) {
        [app.delegate.window makeKeyAndVisible];
    }
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
}

-(void)keyboardShow {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIWindow *lastWindow = (UIWindow *)[windows lastObject];
    self.windowLevel = lastWindow.windowLevel + 1;
}

-(void)keyboardHide {
    self.windowLevel = self.windowLevel - 1;
}
/**
 *  窗体拖动事件
 *
 *  @param sender <#sender description#>
 */
-(void)panAction:(UIPanGestureRecognizer*)sender {
    UIView *view = [UIApplication sharedApplication].delegate.window;
    CGPoint point = [sender translationInView:view];
    CGPoint center = CGPointMake(sender.view.center.x + point.x, sender.view.center.y + point.y);
    CGFloat w_2 = self.bounds.size.width/2;
    CGFloat H_2 = self.bounds.size.height/2;
    CGFloat r = view.bounds.size.width-w_2;
    CGFloat b = view.bounds.size.height-H_2;
    if (center.x < w_2) {
        center.x = w_2;
    }
    if (center.y < H_2) {
        center.y = H_2;
    }
    if (center.x > r) {
        center.x = r;
    }
    if (center.y > b) {
        center.y = b;
    }
    sender.view.center = center;
    [sender setTranslation:CGPointMake(0, 0) inView:view];
}

@end
