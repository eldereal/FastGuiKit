//
//  FastGui+FGTextFieldInputView.h
//  train-helper
//
//  Created by 易元 白 on 15/3/26.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGUI.h"

@interface FastGui (FGTextFieldInputView)

//+ (NSString *) beginInputViewOfTextFieldWithText:(NSString *) text;
//
//+ (NSString *) beginInputViewOfTextFieldWithText:(NSString *) text styleClass:(NSString *) styleClass;
//
//+ (NSString *) beginInputViewOfTextField;
//
//+ (NSString *) beginInputViewOfTextFieldWithStyleClass:(NSString *) styleClass;

+ (void) beginInputViewWithNextTextField;

+ (void) endInputViewOfTextField;

@end
