//
//  FastGui+UITextField.m
//  exibitour
//
//  Created by 易元 白 on 15/4/4.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FastGui+UITextField.h"

#import "FGTypes.h"
#import "FGInternal.h"
#import "FGStyle.h"
#import "UIView+changingResult.h"
#import "UITextField+dismissFirstResponderTouchOutside.h"
#import "UIView+changingResult.h"

@interface FGTextField : UITextField

@property (nonatomic, assign) BOOL becomeFirstResponderOnStart;

@property (nonatomic, assign) BOOL dismissFirstResponderOnTouchOutside;
@property (nonatomic, assign) BOOL dismissFirstResponderOnReturn;


@property (nonatomic, assign) BOOL updateGuiOnReturnKey;
@property (nonatomic, assign) BOOL updateGuiOnChange;
@property (nonatomic, assign) BOOL updateGuiAfterContinuousChangeEnded;

@property (nonatomic, assign) BOOL continuousChangeEventDispatched;
@property (nonatomic, strong) NSDate * nextUpdateTime;

@property (nonatomic, assign) NSTimeInterval continuousChangeTime;

@property (nonatomic, weak) UITapGestureRecognizer *dismissRecognizer;
@property (nonatomic, weak) UIView *dismissRecognizerHolder;

@end


@implementation FastGui (UITextField)

+ (NSString *) textField
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil text:nil placeHolder:nil isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil text:nil placeHolder:placeHolder isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithStyleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:nil isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:placeHolder isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *)textFieldWithPlaceHolder:(NSString *)placeHolder focus:(FGTextFieldFocus)focus styleClass:(NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:placeHolder isPassword:NO focus: focus update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithText: (NSString *) text placeHolder: (NSString *)placeHolder focus: (FGTextFieldFocus) focus update: (FGTextFieldUpdate) updatePolicy styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:text placeHolder:placeHolder isPassword:NO focus: focus update:updatePolicy];
}

+ (NSString *) passwordField
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil text:nil placeHolder:nil isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil text:nil placeHolder:placeHolder isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithStyleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:nil isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:placeHolder isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}


+ (NSString *) textFieldWithReuseId: (NSString *)reuseId styleClass: (NSString *)styleClass text:(NSString *)text placeHolder: (NSString *)placeHolder isPassword: (BOOL) isPassword focus:(FGTextFieldFocus)focus update: (FGTextFieldUpdate) updatePolicy
{
    return [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        FGTextField *textField = (FGTextField *) reuseView;
        if (textField == nil) {
            textField = [[FGTextField alloc] init];
        }
        if (!textField.changingResult && text != nil) {
            textField.text = text;
        }
        
        textField.updateGuiOnChange = updatePolicy & FGTextFieldUpdateOnChange;
        textField.updateGuiAfterContinuousChangeEnded = updatePolicy & FGTextFieldUpdateShortAfterChange;
        textField.updateGuiOnReturnKey = updatePolicy & FGTextFieldUpdateOnReturn;
        
        textField.becomeFirstResponderOnStart = focus & FGTextFieldFocusAtStart;
        textField.dismissFirstResponderOnTouchOutside = focus & FGTextFieldFocusDismissTouchOutside;
        textField.dismissFirstResponderOnReturn = focus & FGTextFieldFocusDismissOnReturn;
        
        if (focus & FGTextFieldFocusSet) {
            [textField becomeFirstResponder];
        }else if (focus & FGTextFieldFocusDismiss) {
            [textField resignFirstResponder];
        }
        
        textField.placeholder = placeHolder;
        textField.secureTextEntry = isPassword;
        return textField;
    } resultBlock:^id(UIView *view) {
        UITextField *text = (UITextField *) view;
        return text.text;
    }];
}


@end

@implementation FGTextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.continuousChangeTime = 0.5;
        [self addTarget:self action:@selector(returnKeyDidPress) forControlEvents:UIControlEventEditingDidEndOnExit];
        [self addTarget:self action:@selector(textDidChange) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void) textDidChange{
    if (self.updateGuiOnChange) {
        [self reloadGuiChangingResult:self.text];
    }
    else if (self.updateGuiAfterContinuousChangeEnded)
    {
        self.nextUpdateTime = [NSDate dateWithTimeIntervalSinceNow:self.continuousChangeTime];
        [self tryReloadGuiAfterContinuousEdit];
    }
}

- (void) tryReloadGuiAfterContinuousEdit
{
    if (self.nextUpdateTime == nil) {
        return;
    }
    NSTimeInterval updateTimeSinceNow = [self.nextUpdateTime timeIntervalSinceNow];
    if (updateTimeSinceNow > 0) {
        if (!self.continuousChangeEventDispatched) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((updateTimeSinceNow + 0.01) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.continuousChangeEventDispatched = NO;
                [self tryReloadGuiAfterContinuousEdit];
            });
        }
    }else{
        [self reloadGuiChangingResult:self.text];
    }
}

- (void) returnKeyDidPress
{
    if (self.dismissFirstResponderOnReturn) {
        [self resignFirstResponder];
    }
    if (self.updateGuiOnReturnKey) {
        [self reloadGuiChangingResult:self.text];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (self.becomeFirstResponderOnStart) {
        [self becomeFirstResponder];
    }
}

- (BOOL)becomeFirstResponder
{
    if (self.dismissFirstResponderOnTouchOutside) {
        if (self.dismissRecognizer == nil) {
            UITapGestureRecognizer * r = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
            self.dismissRecognizer = r;
            UIView *rootView = self;
            while (rootView.superview != nil) {
                rootView = rootView.superview;
            }
            [rootView addGestureRecognizer:r];
            self.dismissRecognizerHolder = rootView;
        }
    }
    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    if (self.dismissRecognizer != nil) {
        [self.dismissRecognizerHolder removeGestureRecognizer:self.dismissRecognizer];
        self.dismissRecognizer = nil;
        self.dismissRecognizerHolder = nil;
    }
    return [super resignFirstResponder];
}

@end

@implementation FGStyle(UITextField)

+ (void) textFieldReturnKey: (UIReturnKeyType) returnKey
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UITextField class]]) {
            ((UITextField *) view).returnKeyType = returnKey;
        }
    }];
}

+ (void) textFieldCaretColor: (UIColor *) color
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UITextField class]]) {
            ((UITextField *) view).tintColor = color;
        }
    }];
}

@end
