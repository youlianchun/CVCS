//
//  FrontWindow.h
//  CVCS
//
//  Created by YLCHUN on 2017/2/21.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrontWindow : NSObject

@property (nonatomic, readonly) CGFloat sideLength;

@property (nonatomic, readonly) CGRect bounds;

-(void)addSubview:(UIView*)view;
-(void)removeFromApplication;
@end
