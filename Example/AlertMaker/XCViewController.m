//
//  XCViewController.m
//  AlertMaker
//
//  Created by ijinfeng on 08/11/2021.
//  Copyright (c) 2021 ijinfeng. All rights reserved.
//

#import "XCViewController.h"
#import "XCCustomSheet.h"
#import "XCCustomAlert.h"
#import "XCCustomViewAlert.h"
@import AlertMaker;

@interface XCViewController ()
@property (nonatomic, strong) XCAlertMaker *maker;
@end

@implementation XCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.maker dismissAlert];
        NSLog(@"延时dismiss");
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    XCAlertMaker.sheet.title(@"我是鼻头爱").addDefaultAction(@"打开alert", ^{
        XCAlertMaker.custom([XCCustomAlert new])
                .onTapDismiss(YES)
                .presentFrom(self);
    }).addDefaultAction(@"打开sheet", ^{
        
    }).presentFrom(self);
}

- (IBAction)onClickSheet:(id)sender {
    self.maker = XCAlertMaker.custom([XCCustomSheet new]).onTapDismiss(YES);
        self.maker.presentFrom(self);
}

- (IBAction)onClickAlert:(id)sender {
    XCAlertMaker.custom([XCCustomAlert new]).onTapDismiss(YES).presentFrom(self);
//    XCAlertMaker.custom([XCCustomAlert new]).onTapDismiss(YES).presentFrom(self);
//    XCAlertMaker.custom([XCCustomAlert new]).onTapDismiss(YES).presentFrom(self);
//    XCAlertMaker.custom([XCCustomAlert new]).onTapDismiss(YES).presentFrom(self);
    
    
//    XCCustomAlert *alert = [XCCustomAlert new];
//    [self.view addSubview:alert.view];
//    alert.view.frame = [alert frameForViewContent];
//
//    [alert willMoveToParentViewController:self];
//    [self addChildViewController:alert];
//    [alert didMoveToParentViewController:self];
}

- (IBAction)onClickViewAlert:(id)sender {
    XCAlertMaker.custom([XCCustomViewAlert new]).onTapDismiss(YES).presentFrom(self);
}

@end
