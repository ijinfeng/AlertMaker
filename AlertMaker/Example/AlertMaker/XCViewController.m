//
//  XCViewController.m
//  AlertMaker
//
//  Created by ijinfeng on 08/11/2021.
//  Copyright (c) 2021 ijinfeng. All rights reserved.
//

#import "XCViewController.h"
#import <AlertMaker/XCCustomAlertView.h>

@interface XCViewController ()

@end

@implementation XCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    XCCustomAlertMaker *alert = [XCCustomAlertMaker alert];
    [alert setTitle:@"你好呀"];
    [alert setContent:@"我很好呀"];
    [alert addDefaultAction:@"OK" action:^{
        [[[[[[XCCustomAlertMaker sheet] setTitle:@"好的"] setContent:@"学习学习学习学习"] addDefaultAction:@"1" action:^{
                                    
                        }] addCancelAction:@"2" action:^{
                            
                        }] presentFrom:self];
    }];
    [alert dismissOnTap:YES];
    [alert presentFrom:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
