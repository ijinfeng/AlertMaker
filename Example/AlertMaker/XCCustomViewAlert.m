//
//  XCCustomViewAlert.m
//  AlertMaker_Example
//
//  Created by niren on 2023/5/24.
//  Copyright © 2023 ijinfeng. All rights reserved.
//

#import "XCCustomViewAlert.h"

@implementation XCCustomViewAlert

- (void)dealloc {
    NSLog(@"dealloc XCCustomViewAlert");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if  (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
    }
    return self;
}

#pragma mark -- XCAlertContentProtocol

- (CGRect)frameForViewContent {
    CGFloat width = 200;
    CGFloat height = 200;
    return  CGRectMake(([UIScreen mainScreen].bounds.size.width - width) / 2, ([UIScreen mainScreen].bounds.size.height - height) / 2, width, height);
}

- (UIEdgeInsets)insetsForMaskView {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (XCAlertAnimation)alertAnimation {
    return XCAlertAnimationPopAlert;
}

@end
