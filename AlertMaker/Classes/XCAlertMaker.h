//
//  XCAlertMaker.h
//  XCAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCAlertContentProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class XCAlertMaker, UIViewController, XCAlertAction;
typedef XCAlertMaker * _Nonnull(^XCActionBlock)(NSString *, void(^ _Nullable )(void));
typedef XCAlertMaker * _Nonnull(^XCCustomActionBlock)(NSString *, id _Nullable object, void(^ _Nullable )(void));
typedef XCAlertMaker * _Nonnull(^XCAlertTitle)(NSString *);
@interface XCAlertMaker : NSObject

/// 系统alert
+ (XCAlertMaker *)alert;
/// 系统sheet
+ (XCAlertMaker *)sheet;

/// 标题设置对sheet无效
@property (nonatomic, copy, readonly) XCAlertTitle title;
@property (nonatomic, copy, readonly) XCAlertTitle message;
/// 警告按钮
@property (nonatomic, copy, readonly) XCActionBlock addDestructiveAction;
/// 默认按钮
@property (nonatomic, copy, readonly) XCActionBlock addDefaultAction;
/// 禁止按钮
@property (nonatomic, copy, readonly) XCActionBlock addForbidAction;
@property (nonatomic, copy, readonly) XCActionBlock addCancelAction;
/// 添加自动义操作，可以传递自定义的参数进去，实现复杂的弹框
@property (nonatomic, copy, readonly) XCCustomActionBlock addCustomAction;

@property (nonatomic, copy, readonly) void (^presentFrom)(id viewOrViewController);

- (void)dismissAlert;

@end


typedef XCAlertMaker * _Nonnull(^XCAlertCustom)(id<XCAlertContentProtocol>);
/// Alert Custom
@interface XCAlertMaker (XCAlertCustom)
/// 传入遵守Protocol<XCAlertContentProtocol>的UIViewController实例
@property (nonatomic, copy, readonly, class) XCAlertCustom custom;
/// 点击空白处是否dismissm，注意只有设置为custom的弹框才有效
@property (nonatomic, copy, readonly) XCAlertMaker * _Nonnull(^onTapDismiss)(BOOL);
/// 弹框展示的动画类型，默认是‘XCAlertAnimationStyleAlert’类型
@property (nonatomic, copy, readonly) XCAlertMaker * _Nonnull(^animationStyle)(XCAlertAnimation);
/// 是否开启滑动关闭，默认关闭
@property (nonatomic, copy, readonly) XCAlertMaker *_Nonnull(^slideClose)(BOOL);
@end


#pragma mark - Alert Action

typedef NS_ENUM(NSInteger, XCAlertActionStyle) {
    XCAlertActionStyleDefault,
    XCAlertActionStyleDestructive,
    XCAlertActionStyleForbid,
    XCAlertActionStyleCancel,
    XCAlertActionStyleCustom,
};

@interface XCAlertAction : NSObject

@property (nonatomic, copy) void(^action)(void);

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong, nullable) id object;

@property (nonatomic) XCAlertActionStyle actionStyle;

@end

#pragma mark - Alert UserInterface

@protocol XCCustomAlertUserInterface <NSObject>

- (void)xc_setNeedsUpdateFrameWithAnimate:(BOOL)animate;

- (void)xc_dismissAlert;

- (void)xc_setAlertHidden:(BOOL)isHidden;

@end

@interface UIViewController (XCAlertUser)<XCCustomAlertUserInterface>
@end

@interface UIView (XCAlertUser)<XCCustomAlertUserInterface>
@end


NS_ASSUME_NONNULL_END
