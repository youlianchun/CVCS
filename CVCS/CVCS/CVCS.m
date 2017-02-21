//
//  CVCS.m
//  CVCS
//
//  Created by YLCHUN on 16/7/8.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "CVCS.h"

#if DEBUG && CVCS_DEBUG_TAG

#pragma mark - PanWindow

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface PanWindow : UIWindow
@end

@implementation PanWindow:UIWindow
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

#pragma mark - CVCS
@interface CVCS : NSObject
@property(nonatomic,weak)UIViewController*vc;//弱引用控制器
@property(nonatomic,copy)NSString*vcStr;//控制器标识字符串
@end

static NSMutableArray<CVCS*>*CVCSArray;// CVCS 控制对象器持用数组
static PanWindow *cvcsWin;//CVCS Window
@implementation CVCS
/**
 *  load类方法，延迟创建打印按钮
 */
+ (void)load {
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self performSelector:@selector(testButInWindow) withObject:nil afterDelay:0.2];
    });
}
/**
 *  注册控制器弱引用
 *
 *  @param vc <#vc description#>
 */
+(void)newVC:(UIViewController*)vc {
    CVCS*cVCS = [[CVCS alloc] init];
    cVCS.vc = vc;
    cVCS.vcStr = [NSString stringWithFormat:@"%@",cVCS.vc];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CVCSArray = [NSMutableArray array];
    });
    
    [CVCSArray addObject:cVCS];
    cVCS = nil;
}
/**
 *  打印持注册控制器和持有状态
 */
+(void)printCVCSArray {
    if (CVCSArray.count==0) {
        return;
    }
    NSMutableArray *array = [CVCSArray mutableCopy];
    printf("\n====CVCS_begin[%s]====⚠️:未释放====✅:已释放====\n",__TIME__);
    NSUInteger n1 = 0;//⚠️:未释放
    NSUInteger n0 = 0;//✅:已释放
    for (CVCS*cVCS in CVCSArray) {
        if (cVCS.vc) {
            n1++;
        }else {
            n0++;
        }
        NSString * pStr = [NSString stringWithFormat:@"%@:%@", cVCS.vc?@"⚠️":@"✅", cVCS.vcStr];
        printf("%s\n",[pStr UTF8String]);
        if (!cVCS.vc) {
            [array removeObject:cVCS];
        }
    }
    printf("====CVCS_end====⚠️:%ld====✅:%ld====\n", n1, n0);
    CVCSArray = array;
}

/**
 *  创建打印按钮
 */
+(void)testButInWindow {
    cvcsWin = [[PanWindow alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-20, 10, 40, 40)];
    UIButton *but = [[UIButton alloc]initWithFrame:cvcsWin.bounds];
    but.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    but.layer.cornerRadius = 20;
    but.layer.masksToBounds = true;
    but.layer.borderWidth = 2;
    but.layer.borderColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.5].CGColor;
    [but setTitle:@"CVCS" forState:UIControlStateNormal];
    but.titleLabel.font = [UIFont systemFontOfSize:13];
    [but setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(testButInAction) forControlEvents:UIControlEventTouchUpInside];
    [cvcsWin addSubview:but];
}

/**
 *  打印按钮事件
 */
+(void)testButInAction {
    [CVCS printCVCSArray];
}
@end

#pragma mark - UIViewController CVCS
@implementation UIViewController (CVCS)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector;
        SEL swizzledSelector;
        Method originalMethod;
        Method swizzledMethod;
        BOOL success;

        originalSelector = @selector(init);
        swizzledSelector = @selector(CVCS_init);
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        originalSelector = @selector(initWithCoder:);
        swizzledSelector = @selector(CVCS_initWithCoder:);
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        originalSelector = @selector(initWithNibName:bundle:);
        swizzledSelector = @selector(CVCS_initWithNibName:bundle:);
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

/**
 *  方法欺骗，注册控制器弱引用
 */
-(instancetype)CVCS_init {
    [CVCS newVC:self];
    return [self CVCS_init];
}

-(instancetype)CVCS_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [CVCS newVC:self];
    return [self CVCS_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

-(instancetype)CVCS_initWithCoder:(NSCoder *)aDecoder {
    [CVCS newVC:self];
    return [self CVCS_initWithCoder:aDecoder];
}
@end

#endif

