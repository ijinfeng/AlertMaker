//  XCAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "XCAlertMaker.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(int, XCAlertControllerStyle) {
    XCAlertControllerStyleAlert,
    XCAlertControllerStyleSheet,
    XCAlertControllerStyleCustom,
};


#pragma mark - Alert Manager
@class XCAlertViewTransition;
@interface XCAlertManager : NSObject

+ (instancetype)shared;

- (void)addAlert:(XCAlertViewTransition *)alert;

- (void)removeAlert:(XCAlertViewTransition *)alert;

- (XCAlertViewTransition *)popAlert;

- (XCAlertViewTransition *)findWithCustom:(id)custom;

- (NSArray<XCAlertViewTransition *> *)findAllWithCustom:(id)custom;

@end

#pragma mark - Alert Configuration

@interface XCAlertConfiguration : NSObject
@property (nonatomic, assign) XCAlertControllerStyle alertStyle;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *message;

@property (nonatomic) BOOL onTapDismiss;

@property (nonatomic) XCAlertAnimation animationStyle;

@property (nonatomic) BOOL slideClose;

@property (nonatomic, strong) id<XCAlertContentProtocol> customAlert;

@property (nonatomic, assign, readonly) BOOL alertIsController;
@end

@implementation XCAlertConfiguration

- (BOOL)alertIsController {
    return [self.customAlert isKindOfClass:[UIViewController class]];
}

@end

#pragma mark - View Transition

@interface XCAlertBackgroundView : UIControl
@property (nonatomic, weak) id<XCAlertContentProtocol> delegate;
@property (nonatomic, weak) UIView *customAlert;
@property (nonatomic, assign) UIEdgeInsets maskViewInsets;
@property (nonatomic, strong) UIControl *bgMaskView;
@end

@implementation XCAlertBackgroundView

- (UIControl *)bgMaskView {
    if (!_bgMaskView) {
        _bgMaskView = [UIControl new];
        _bgMaskView.userInteractionEnabled = YES;
        [self addSubview:_bgMaskView];
    }
    return _bgMaskView;
}

- (void)layoutSubviews {
    if ([self.delegate respondsToSelector:@selector(frameForViewContent)]) {
        CGRect finalRect = [self.delegate frameForViewContent];
        self.customAlert.frame = finalRect;
    }
}

- (void)setMaskViewInsets:(UIEdgeInsets)maskViewInsets {
    self.bgMaskView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.bgMaskView.topAnchor constraintEqualToAnchor:self.topAnchor constant:maskViewInsets.top],
        [self.bgMaskView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:maskViewInsets.left],
        [self.bgMaskView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-maskViewInsets.bottom],
        [self.bgMaskView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-maskViewInsets.right]
    ]];
}

@end

@interface XCAlertViewTransition : NSObject

- (instancetype)initWithAlertConfiguration:(XCAlertConfiguration *)configuration onView:(UIView *)onView;

- (void)show;

- (void)dismiss;

- (void)setHidden:(BOOL)hidden;

- (void)setNeedsUpdateFrameWithAnimate:(BOOL)animate;

@end

@interface XCAlertViewTransition ()

@property (nonatomic, weak, readonly) UIView *alertContentView;

@property (nonatomic, weak, readonly) UIView *onView;

@property (nonatomic, strong) XCAlertBackgroundView *backgroundView;

@property (nonatomic, strong, readonly) XCAlertConfiguration *configuration;

@property (nonatomic, strong, readonly) id<XCAlertContentProtocol> delegate;

@end

@implementation XCAlertViewTransition

- (void)dealloc {
    NSLog(@"dealloc XCAlertViewTransition");
}

- (instancetype)initWithAlertConfiguration:(XCAlertConfiguration *)configuration onView:(UIView *)onView {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _onView = onView;
        if ([configuration.customAlert isKindOfClass:[UIView class]]) {
            _alertContentView = (UIView *)configuration.customAlert;
        } else if ([configuration.customAlert isKindOfClass:[UIViewController class]]) {
            _alertContentView = ((UIViewController *)configuration.customAlert).view;
        }
    }
    return self;
}

- (id<XCAlertContentProtocol>)delegate {
    return self.configuration.customAlert;
}

- (void)show {
    if (!self.alertContentView) {
        return;
    }
    [[XCAlertManager shared] addAlert:self];
    
    XCAlertBackgroundView *backgroundView = [[XCAlertBackgroundView alloc] init];
    self.backgroundView = backgroundView;
    backgroundView.customAlert = self.alertContentView;
    backgroundView.delegate = self.delegate;
    backgroundView.userInteractionEnabled = YES;
    backgroundView.clipsToBounds = YES;
    backgroundView.bgMaskView.clipsToBounds = YES;
    backgroundView.bgMaskView.backgroundColor = [UIColor clearColor];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.onView addSubview:backgroundView];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(insetsForMaskView)]) {
        insets = [self.delegate insetsForMaskView];
        // 设置不能穿透和没有设置，那么都是从顶部开始
        if ([self.delegate respondsToSelector:@selector(canGestureRecognizerThroughTheMaskView)] && [self.delegate canGestureRecognizerThroughTheMaskView]) {} else {
            insets = UIEdgeInsetsZero;
        }
    }
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [backgroundView.topAnchor constraintEqualToAnchor:self.onView.topAnchor constant:insets.top],
        [backgroundView.leftAnchor constraintEqualToAnchor:self.onView.leftAnchor constant:insets.left],
        [backgroundView.bottomAnchor constraintEqualToAnchor:self.onView.bottomAnchor constant:-insets.bottom],
        [backgroundView.rightAnchor constraintEqualToAnchor:self.onView.rightAnchor constant:-insets.right]
    ]];
    
    if ([self.delegate respondsToSelector:@selector(insetsForMaskView)]) {
        UIEdgeInsets insets = [self.delegate insetsForMaskView];
        // 明确设置不能穿透或没设置，那么都是不能穿透
        if ([self.delegate respondsToSelector:@selector(canGestureRecognizerThroughTheMaskView)] && [self.delegate canGestureRecognizerThroughTheMaskView]) {
            backgroundView.maskViewInsets = UIEdgeInsetsZero;
        } else {
            backgroundView.maskViewInsets = insets;
        }
    } else {
        backgroundView.maskViewInsets = UIEdgeInsetsZero;
    }
    [self.onView addSubview:self.alertContentView];
    
    if (self.configuration.onTapDismiss) {
        [backgroundView addTarget:self action:@selector(actionForTapOnTemp:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView.bgMaskView addTarget:self action:@selector(actionForTapOnTemp:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGRect finalRect = CGRectZero;
    if ([self.delegate respondsToSelector:@selector(frameForViewContent)]) {
        finalRect = [self.delegate frameForViewContent];
    }
    
    NSTimeInterval duration = 0.25;
    if ([self.delegate respondsToSelector:@selector(animationDuration)]) {
        duration = [self.delegate animationDuration];
    }
    
    UIColor *finalBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    if ([self.delegate respondsToSelector:@selector(animationTransitionColor)]) {
        finalBackgroundColor = [self.delegate animationTransitionColor];
    }
    
    XCAlertAnimation animation = self.configuration.animationStyle;
    if ([self.delegate respondsToSelector:@selector(alertAnimation)]) {
        animation = [self.delegate alertAnimation];
    }

    CGRect beginRect = finalRect;
    if (animation == XCAlertAnimationSheet) {
        beginRect.origin.y = CGRectGetHeight(self.onView.frame);
    } else if (animation == XCAlertAnimationPullDown) {
        beginRect.origin.y = CGRectGetMinY(self.onView.frame) - CGRectGetHeight(finalRect);
    }
    self.alertContentView.frame = beginRect;
    if (animation == XCAlertAnimationPopAlert) {
        self.alertContentView.alpha = 0;
        self.alertContentView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    }
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.bgMaskView.backgroundColor = finalBackgroundColor;
        self.alertContentView.alpha = 1;
        self.alertContentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alertContentView.frame = finalRect;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(alertDidShow)]) {
            [self.delegate alertDidShow];
        }
    }];
}

- (void)dismiss {
    CGRect finalRect = CGRectZero;
    if ([self.delegate respondsToSelector:@selector(frameForViewContent)]) {
        finalRect = [self.delegate frameForViewContent];
    }
    
    NSTimeInterval duration = 0.25;
    if ([self.delegate respondsToSelector:@selector(animationDuration)]) {
        duration = [self.delegate animationDuration];
    }
    
    XCAlertAnimation animation = self.configuration.animationStyle;
    if ([self.delegate respondsToSelector:@selector(alertAnimation)]) {
        animation = [self.delegate alertAnimation];
    }

    if (animation == XCAlertAnimationSheet) {
        finalRect.origin.y += finalRect.size.height;
    } else if (animation == XCAlertAnimationPullDown) {
        finalRect.origin.y -= finalRect.size.height;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.bgMaskView.backgroundColor = [UIColor clearColor];
        self.alertContentView.frame = finalRect;
        if (animation == XCAlertAnimationPopAlert) {
            self.alertContentView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self.alertContentView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(alertDidDismiss)]) {
            [self.delegate alertDidDismiss];
        }
        if (self.configuration.alertIsController && [self.alertContentView.nextResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)self.alertContentView.nextResponder;
            [vc willMoveToParentViewController:nil];
            [vc removeFromParentViewController];
            [vc didMoveToParentViewController:nil];
        }
        [[XCAlertManager shared] removeAlert:self];
        self.configuration.customAlert = nil;
    }];
}

- (void)setHidden:(BOOL)hidden {
    self.backgroundView.hidden = hidden;
}

- (void)actionForTapOnTemp:(UIControl *)control {
    [self dismiss];
}

- (void)setNeedsUpdateFrameWithAnimate:(BOOL)animate {
    if ([self.delegate respondsToSelector:@selector(frameForViewContent)]) {
        CGRect rect = [self.delegate frameForViewContent];
        NSTimeInterval duration = 0;
        if (animate) {
            if ([self.delegate respondsToSelector:@selector(setNeedsUpdateFrameAnimationDuration)]) {
                duration = [self.delegate setNeedsUpdateFrameAnimationDuration];
            } else {
                duration = 0.25;
            }
        }
        [UIView animateWithDuration:duration animations:^{
            self.alertContentView.frame = rect;
        }];
    }
}

@end


#pragma mark - Alert Action

@implementation XCAlertAction

@end

#pragma mark - Alert Maker

@interface XCAlertMaker ()

- (instancetype)initWithAlertStyle:(XCAlertControllerStyle)style;
- (instancetype)initWithAlertStyle:(XCAlertControllerStyle)style
                            custom:(id<XCAlertContentProtocol>)viewController;

@property (nonatomic, strong) XCAlertConfiguration *configuration;

@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, strong) XCAlertViewTransition *viewTransition;

@end

@implementation XCAlertMaker

- (void)dealloc {}

- (NSMutableArray *)actions {
    if (!_actions) {
        _actions = [NSMutableArray array];
    }
    return _actions;
}

+ (XCAlertMaker *)alert {
    return [[XCAlertMaker alloc] initWithAlertStyle:XCAlertControllerStyleAlert];
}

+ (XCAlertMaker *)sheet {
    return [[XCAlertMaker alloc] initWithAlertStyle:XCAlertControllerStyleSheet];
}

- (instancetype)initWithAlertStyle:(XCAlertControllerStyle)style {
    return [self initWithAlertStyle:style custom:nil];
}

- (instancetype)initWithAlertStyle:(XCAlertControllerStyle)style custom:(id<XCAlertContentProtocol>)customAlert {
    if (self = [super init]) {
        _configuration = [XCAlertConfiguration new];
        _configuration.alertStyle = style;
        _configuration.customAlert = customAlert;
        _configuration.onTapDismiss = NO;
        _configuration.animationStyle = XCAlertAnimationPopAlert;
    }
    return self;
}

- (XCAlertMaker * (^)(NSString *))title {
    XCAlertMaker *(^maker)(NSString *) = ^XCAlertMaker *(NSString *x) {
        self.configuration.title = x;
        return self;
    };
    return maker;
}

- (XCAlertMaker * (^)(NSString *))message {
    XCAlertMaker *(^maker)(NSString *) = ^XCAlertMaker *(NSString *x) {
        self.configuration.message = x;
        return self;
    };
    return maker;
}

- (XCActionBlock)addDestructiveAction {
    XCAlertMaker *(^maker)(NSString *, void(^)(void)) = ^XCAlertMaker *(NSString *x, void(^b)(void)) {
        XCAlertAction *a = [[XCAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.actionStyle = XCAlertActionStyleDestructive;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (XCActionBlock)addDefaultAction {
    XCAlertMaker *(^maker)(NSString *, void(^)(void)) = ^XCAlertMaker *(NSString *x, void(^b)(void)) {
        XCAlertAction *a = [[XCAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.actionStyle = XCAlertActionStyleDefault;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (XCActionBlock)addForbidAction {
    XCAlertMaker *(^maker)(NSString *, void(^)(void)) = ^XCAlertMaker *(NSString *x, void(^b)(void)) {
        XCAlertAction *a = [[XCAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.actionStyle = XCAlertActionStyleForbid;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (XCActionBlock)addCancelAction {
    XCAlertMaker *(^maker)(NSString *, void(^)(void)) = ^XCAlertMaker *(NSString *x, void(^b)(void)) {
        XCAlertAction *a = [[XCAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.actionStyle = XCAlertActionStyleCancel;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (XCCustomActionBlock)addCustomAction {
    XCAlertMaker *(^maker)(NSString *,id, void(^)(void)) = ^XCAlertMaker *(NSString *x, id obj, void(^b)(void)) {
        XCAlertAction *a = [[XCAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.object = obj;
        a.actionStyle = XCAlertActionStyleCustom;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (void (^)(id _Nonnull))presentFrom {
    void (^maker)(id) = ^(id from) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *x = nil;
            UIView *v = nil;
            if ([from isKindOfClass:[UIViewController class]]) {
                x = (UIViewController *)from;
            } else if ([from isKindOfClass:[UIView class]]) {
                v = (UIView *)from;
            } else {
                return;
            }
            if (self.configuration.alertStyle == XCAlertControllerStyleSheet) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.configuration.title message:self.configuration.message preferredStyle:UIAlertControllerStyleActionSheet];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    UIPopoverPresentationController *pop = [alert popoverPresentationController];
                    pop.permittedArrowDirections = UIPopoverArrowDirectionUp;
                    pop.sourceView = x.view;
                    pop.sourceRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , 0);
                }
                
                for (int i = 0; i < self.actions.count; i++) {
                    XCAlertAction *a = self.actions[i];
                    UIAlertActionStyle style = UIAlertActionStyleDefault;
                    if (a.actionStyle == XCAlertActionStyleDestructive) {
                        style = UIAlertActionStyleDestructive;
                    } else if (a.actionStyle == XCAlertActionStyleDefault) {
                        style = UIAlertActionStyleDefault;
                    } else if (a.actionStyle == XCAlertActionStyleForbid) {
                        
                    } else {
                        style = UIAlertActionStyleCancel;
                    }
                    UIAlertAction *action = [UIAlertAction actionWithTitle:a.title style:style handler:^(UIAlertAction * _Nonnull action) {
                        if (a.action) {
                            a.action();
                        }
                    }];
                    [alert addAction:action];
                }
                
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                [x presentViewController:alert animated:YES completion:nil];
            } else if (self.configuration.alertStyle == XCAlertControllerStyleAlert) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.configuration.title message:self.configuration.message preferredStyle:UIAlertControllerStyleAlert];
                
                for (int i = 0; i < self.actions.count; i++) {
                    XCAlertAction *a = self.actions[i];
                    UIAlertActionStyle style = UIAlertActionStyleDefault;
                    if (a.actionStyle == XCAlertActionStyleDestructive) {
                        style = UIAlertActionStyleDestructive;
                    } else if (a.actionStyle == XCAlertActionStyleDefault) {
                        style = UIAlertActionStyleDefault;
                    } else if (a.actionStyle == XCAlertActionStyleForbid) {
                        
                    } else {
                        style = UIAlertActionStyleCancel;
                    }
                    UIAlertAction *action = [UIAlertAction actionWithTitle:a.title style:style handler:^(UIAlertAction * _Nonnull action) {
                        if (a.action) {
                            a.action();
                        }
                    }];
                    [alert addAction:action];
                }
                [x presentViewController:alert animated:YES completion:nil];
            } else {
                // custom alert
                if ([self.configuration.customAlert respondsToSelector:@selector(installWithTitle:message:actions:)]) {
                    [self.configuration.customAlert installWithTitle:self.configuration.title message:self.configuration.message actions:self.actions.copy];
                }
                UIView *onView = x ? x.view : v;
                self.viewTransition = [[XCAlertViewTransition alloc] initWithAlertConfiguration:self.configuration onView:onView];
                [self.viewTransition show];
                if (self.configuration.alertIsController && x != nil) {
                    UIViewController *alert = (UIViewController *)self.configuration.customAlert;
                    [alert willMoveToParentViewController:x];
                    [x addChildViewController:alert];
                    [alert didMoveToParentViewController:x];
                }
            }
        });
    };
    return maker;
}

- (UIViewController *)getp_vcFrom:(UIViewController *)x {
    UIViewController *p = x;
    while (p) {
        UIViewController *x_p = p.presentedViewController;
        if (!x_p) {
            break;
        }
        p = x_p;
    }
    return p;
}

- (void)dismissAlert {
    if (self.viewTransition) {
        [self.viewTransition dismiss];
    }
    self.viewTransition = nil;
}

@end

@implementation XCAlertMaker (XCAlertCustom)

+ (XCAlertCustom)custom {
    return ^XCAlertMaker *(id<XCAlertContentProtocol> x) {
        XCAlertMaker *maker = [[XCAlertMaker alloc] initWithAlertStyle:XCAlertControllerStyleCustom custom:x];
        return maker;
    };
}

/// 默认是点击空白处不会消失的
- (XCAlertMaker * (^)(BOOL))onTapDismiss {
    XCAlertMaker *(^maker)(BOOL) = ^XCAlertMaker *(BOOL x) {
        self.configuration.onTapDismiss = x;
        return self;
    };
    return maker;
}

- (XCAlertMaker * (^)(XCAlertAnimation))animationStyle {
    XCAlertMaker *(^maker)(XCAlertAnimation) = ^XCAlertMaker *(XCAlertAnimation x) {
        self.configuration.animationStyle = x;
        return self;
    };
    return maker;
}

- (XCAlertMaker * _Nonnull (^)(BOOL))slideClose {
    XCAlertMaker *(^maker)(BOOL) = ^XCAlertMaker *(BOOL slideClose) {
        self.configuration.slideClose = slideClose;
        return  self;
    };
    return maker;
}

@end

#pragma mark - XCAlertManager Impl

@implementation XCAlertManager {
    NSMutableArray<XCAlertViewTransition *> *_alerts;
}

+ (instancetype)shared {
    static XCAlertManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [XCAlertManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _alerts = [NSMutableArray array];
    }
    return self;
}

- (void)addAlert:(XCAlertViewTransition *)alert {
    if ([_alerts containsObject:alert]) return;
    [_alerts addObject:alert];
}

- (XCAlertViewTransition *)popAlert {
    XCAlertViewTransition *alert = [_alerts lastObject];
    [_alerts removeLastObject];
    return alert;
}

- (void)removeAlert:(XCAlertViewTransition *)alert {
    if (!alert) return;
    [_alerts removeObject:alert];
}

- (XCAlertViewTransition *)findWithCustom:(id)custom {
    UIView *v;
    UIViewController *c;
    if ([custom isKindOfClass:[UIView class]]) {
        v = (UIView *)custom;
    } else if ([custom isKindOfClass:[UIViewController class]]) {
        c = (UIViewController *)custom;
    } else {
        return nil;
    }
    for (XCAlertViewTransition *alert in _alerts) {
        if (alert.configuration.alertIsController) {
            UIViewController *vc = [alert.alertContentView.nextResponder isKindOfClass:[UIViewController class]] ? (UIViewController *)alert.alertContentView.nextResponder : nil;
            if (vc == c) {
                return alert;
            }
        } else {
            if (alert.alertContentView == v) {
                return alert;
            }
        }
    }
    return nil;
}

- (NSArray<XCAlertViewTransition *> *)findAllWithCustom:(id)custom {
    UIView *v;
    UIViewController *c;
    if ([custom isKindOfClass:[UIView class]]) {
        v = (UIView *)custom;
    } else if ([custom isKindOfClass:[UIViewController class]]) {
        c = (UIViewController *)custom;
    } else {
        return nil;
    }
    NSMutableArray *vts = [NSMutableArray array];
    for (XCAlertViewTransition *alert in _alerts) {
        if (alert.configuration.alertIsController) {
            UIViewController *vc = [alert.alertContentView.nextResponder isKindOfClass:[UIViewController class]] ? (UIViewController *)alert.alertContentView.nextResponder : nil;
            if (vc == c) {
                [vts addObject:alert];
            }
        } else {
            if (alert.alertContentView == v) {
                [vts addObject:alert];
            }
        }
    }
    return [vts copy];
}

@end

#pragma mark - Controller Present caegory

@implementation UIViewController (XCAlertUser)

- (void)xc_setNeedsUpdateFrameWithAnimate:(BOOL)animate {
    XCAlertViewTransition *vt = [[XCAlertManager shared] findWithCustom:self];
    [vt setNeedsUpdateFrameWithAnimate:animate];
}

- (void)xc_dismissAlert {
    XCAlertViewTransition *vt = [[XCAlertManager shared] findWithCustom:self];
    [vt dismiss];
}

- (void)xc_setAlertHidden:(BOOL)isHidden {
    XCAlertViewTransition *vt = [[XCAlertManager shared] findWithCustom:self];
    [vt setHidden:isHidden];
}

@end


@implementation UIView (XCAlertUser)

- (void)xc_setNeedsUpdateFrameWithAnimate:(BOOL)animate {
    XCAlertViewTransition *vt = [[XCAlertManager shared] findWithCustom:self];
    [vt setNeedsUpdateFrameWithAnimate:animate];
}

- (void)xc_dismissAlert {
    XCAlertViewTransition *vt = [[XCAlertManager shared] findWithCustom:self];
    [vt dismiss];
}

- (void)xc_setAlertHidden:(BOOL)isHidden {
    XCAlertViewTransition *vt = [[XCAlertManager shared] findWithCustom:self];
    [vt setHidden:isHidden];
}

@end

