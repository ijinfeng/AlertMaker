//
//  XCCustomAlert.h
//  AlertMaker_Example
//
//  Created by niren on 2023/5/24.
//  Copyright © 2023 ijinfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AlertMaker;
NS_ASSUME_NONNULL_BEGIN

@interface XCCustomAlert : UIViewController<XCAlertContentProtocol>
@property (nonatomic, assign) BOOL flag;
@end

NS_ASSUME_NONNULL_END
