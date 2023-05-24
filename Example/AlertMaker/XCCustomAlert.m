//
//  XCCustomAlert.m
//  AlertMaker_Example
//
//  Created by niren on 2023/5/24.
//  Copyright © 2023 ijinfeng. All rights reserved.
//

#import "XCCustomAlert.h"

@interface XCCustomAlert ()
@property (nonatomic, assign) CGFloat height;
@end

@implementation XCCustomAlert

- (void)dealloc {
    NSLog(@"dealloc XCCustomAlert");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    self.height = 200;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.flag) {
        [self xc_dismissAlert];
        return;
    }
    XCCustomAlert *alert = [XCCustomAlert new];
    alert.flag = YES;
    XCAlertMaker.custom(alert).onTapDismiss(YES).presentFrom([UIApplication sharedApplication].keyWindow);
}

#pragma mark - XCAlertContentProtocol

- (CGRect)frameForViewContent {
    CGFloat width = 200;
    CGFloat height = self.height;
    return  CGRectMake(([UIScreen mainScreen].bounds.size.width - width) / 2, ([UIScreen mainScreen].bounds.size.height - height) / 2, width, height);
}

- (UIColor *)animationTransitionColor {
    return [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
}

- (XCAlertAnimation)alertAnimation {
    return  XCAlertAnimationPopAlert;
}

@end
