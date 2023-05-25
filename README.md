# AlertMaker

Create alert using functional calls.

![](https://img.shields.io/badge/iOS-9.0%2B-green)

## Ability

### Convenient call system alert!

### Convenient custom alert animation

You just focus on how to customize the alert style. If you want to customize alert component, the protocol `XCAlertContentProtocol` is what you need to look!

You can:

- [x] Customize alert frame
- [x] Customize alert display animation
- [x] Customize alert mask color

## Usage

### 1. System alert or sheet

```Objective-C
XCAlertMaker.alert.title(@"This is Title").message(@"You can input message in here").addDefaultAction(@"action1", ^{
    // code action1
    }).addDefaultAction(@"action2", ^{
        // code action2
    }).presentFrom(self);
```

If you want to display alertsheet, just replace alert with sheet.

### 2. Customize alert

The first step is to create the popover class, and you use UIView or UIViewController to create the contents of the popover.

```Objective-C
#import <UIKit/UIKit.h>

@import AlertMaker;
NS_ASSUME_NONNULL_BEGIN

@interface XCCustomAlert : UIViewController<XCAlertContentProtocol>

@end

NS_ASSUME_NONNULL_END


#import "XCCustomAlert.h"

@implementation XCCustomAlert
#pragma mark - XCAlertContentProtocol

- (CGRect)frameForViewContent {
    CGFloat width = 200;
    CGFloat height = 200;
    return  CGRectMake(([UIScreen mainScreen].bounds.size.width - width) / 2, ([UIScreen mainScreen].bounds.size.height - height) / 2, width, height);
}

- (UIColor *)animationTransitionColor {
    return [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
}

- (XCAlertAnimation)alertAnimation {
    return  XCAlertAnimationPopAlert;
}
@end
```

Then you can create your custom alert like this: 
```Objective-C
XCAlertMaker.custom([XCCustomAlert new]).onTapDismiss(YES).presentFrom(self);
```

It's OK.

## Import

Import by pod:

`pod 'AlertMaker', '~> 1.0.0'`