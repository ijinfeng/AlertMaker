//
//  XCCustomSheet.m
//  XCCustomSheet
//
//  Created by jinfeng on 2021/9/7.
//  Copyright © 2021 ijinfeng. All rights reserved.
//

#import "XCCustomSheet.h"
#import <AlertMaker/XCAlertMaker.h>

@implementation XCCustomSheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if  (self) {
        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self XC_dismissAlertView];
}

#pragma mark -- XCAlertContentProtocol

- (CGRect)frameForViewContent {
    CGFloat height = 200;
    return CGRectMake(0, [UIScreen mainScreen].bounds.size.height - height, [UIScreen mainScreen].bounds.size.width, height);
}

- (UIEdgeInsets)insetsForMaskView {
    return UIEdgeInsetsMake(64, 0, 0, 0);
}

- (XCAlertAnimation)alertAnimation {
    return XCAlertAnimationSheet;
}

@end
