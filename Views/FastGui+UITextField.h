//
//  FastGui+UITextField.h
//  exibitour
//
//  Created by 易元 白 on 15/4/4.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FastGui.h"
#import "FGStyle.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, FGTextFieldFocus)
{
    FGTextFieldFocusNone = 0,
    FGTextFieldFocusDismissTouchOutside = 1,
    FGTextFieldFocusDismissOnReturn = 2,
    FGTextFieldFocusAtStart = 4,
    FGTextFieldFocusSet = 8,
    FGTextFieldFocusDismiss = 16
};

typedef NS_ENUM(NSUInteger, FGTextFieldUpdate)
{
    FGTextFieldUpdateNone = 0,
    FGTextFieldUpdateOnChange = 1,
    FGTextFieldUpdateShortAfterChange = 2,
    FGTextFieldUpdateOnReturn = 4
};

@interface FastGui (UITextField)

+ (NSString *) textField;

+ (NSString *) textFieldWithText: (NSString *) text placeHolder: (NSString *)placeHolder focus: (FGTextFieldFocus) focus update: (FGTextFieldUpdate) updatePolicy styleClass: (NSString *)styleClass;

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder;

+ (NSString *) textFieldWithStyleClass: (NSString *)styleClass;

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass;

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder focus: (FGTextFieldFocus) focus styleClass: (NSString *)styleClass;

+ (NSString *) passwordField;

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder;

+ (NSString *) passwordFieldWithStyleClass: (NSString *)styleClass;

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass;

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder focus: (FGTextFieldFocus) focus styleClass: (NSString *)styleClass;

@end

@interface FGStyle(UITextField)

+ (void) textFieldReturnKey: (UIReturnKeyType) returnKey;

+ (void) textFieldCaretColor: (UIColor *) color;

+ (void) textFieldPlaceholderTextColor: (UIColor *) color;

+ (void) textFieldPadding: (UIEdgeInsets) padding;

+ (void) textFieldKeyboardType: (UIKeyboardType) type;

+ (void) textFieldPatternColors: (NSDictionary *) patternColors;

@end
