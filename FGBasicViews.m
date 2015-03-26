//
//  FGBasicViews.m
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/NSObject+A2DynamicDelegate.h>
#import <objc/runtime.h>
#import "FGBasicViews.h"
#import "FGTypes.h"
#import "FGInternal.h"
#import "FGStyle.h"
#import <REKit/REKit.h>
#import "UIView+changingResult.h"

@interface FGColoredBlock : UIView<FGStylable>

@end

@implementation FGColoredBlock

- (void)styleWithBackgroundColor:(UIColor *)backgroundColor
{
    //this block ignores backgroundColor style;
}

@end

@implementation FastGui(FGBasicViews)

+ (void) scrollView
{
    [self scrollViewWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void) scrollViewWithStyleClass: (NSString *)styleClass
{
    [self scrollViewWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void) scrollViewWithReuseId: (NSString *) reuseId styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        if (reuseView == nil) {
            reuseView = [[UIScrollView alloc] init];
        }
        return reuseView;
    } resultBlock:nil];
}

+ (void) block
{
    [self blockWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void)blockWithStyleClass:(NSString *)styleClass
{
    [self blockWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void)blockWithReuseId: (NSString *) reuseId styleClass:(NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        if (reuseView == nil) {
            reuseView = [[UIView alloc] init];
        }
        return reuseView;
    } resultBlock: nil];
}

+ (void)blockWithColor:(UIColor *)color
{
    [self blockWithColor:color withReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void)blockWithColor:(UIColor *)color styleClass:(NSString *)styleClass
{
    [self blockWithColor:color withReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void) blockWithColor:(UIColor *)color withReuseId: (NSString *)reuseId styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        FGColoredBlock *view = (FGColoredBlock *)reuseView;
        if (view == nil) {
            view = [[FGColoredBlock alloc] init];
            
        }
        view.backgroundColor = color;
        return view;
    } resultBlock: nil];
}

+ (void) touchableBlockWithCallback:(FGVoidBlock)callback
{
    [self touchableBlockWithReuseId:[FGInternal callerPositionAsReuseId] withCallback:callback styleClass:nil];
}

+ (void)touchableBlockWithCallback:(FGVoidBlock)callback styleClass:(NSString *)styleClass
{
    [self touchableBlockWithReuseId:[FGInternal callerPositionAsReuseId] withCallback:callback styleClass:styleClass];
}

+ (void) touchableBlockWithReuseId:(NSString *) reuseId withCallback: (FGVoidBlock)callback styleClass:(NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:nil initBlock:^UIView *(UIView *reuseView) {
        UIControl *ctrl = (UIControl *) reuseView;
        if (ctrl == nil) {
            ctrl = [[UIControl alloc] init];
        }
        [ctrl bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
        [ctrl bk_addEventHandler: ^(id sender){
            callback();
        } forControlEvents:UIControlEventTouchUpInside];
        return ctrl;
    } resultBlock:nil];
}

+ (void)labelWithText:(NSString *)text
{
    [self labelWithReuseId:[FGInternal callerPositionAsReuseId] text:text styleClass:nil];
}

+ (void)labelWithText:(NSString *)text styleClass:(NSString *)styleClass
{
    [self labelWithReuseId:[FGInternal callerPositionAsReuseId] text:text styleClass: styleClass];
}

+ (void) labelWithReuseId:(NSString *)reuseId text: (NSString *)text styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UILabel *label = (UILabel *) reuseView;
        if(label == nil){
            label = [[UILabel alloc] init];
            label.numberOfLines = 0;
        }
        label.text = text;
        return label;
    } resultBlock: nil];
}

+ (void) selectableLabelWithText: (NSString *) text
{
    [self selectableLabelWithReuseId:[FGInternal callerPositionAsReuseId] text:text styleClass:nil];
}

+ (void) selectableLabelWithText: (NSString *) text styleClass: (NSString *)styleClass
{
    [self selectableLabelWithReuseId:[FGInternal callerPositionAsReuseId] text:text styleClass:styleClass];
}

+ (void) selectableLabelWithReuseId:(NSString *)reuseId text: (NSString *)text styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UITextView *label = (UITextView *) reuseView;
        if(label == nil){
            label = [[UITextView alloc] init];
            label.scrollEnabled = NO;
            label.editable = NO;
        }
        label.text = text;
        return label;
    } resultBlock: nil];
}

+ (void)imageWithName:(NSString *)name
{
    [self imageWithReuseId:[FGInternal callerPositionAsReuseId] imageNamed:name styleClass:nil];
}

+ (void)imageWithName:(NSString *)name styleClass:(NSString *)styleClass
{
    [self imageWithReuseId:[FGInternal callerPositionAsReuseId] imageNamed:name styleClass:styleClass];
}

+ (void)imageWithReuseId:(NSString *)reuseId imageNamed: (NSString *)name styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UIImageView *img = (UIImageView *) reuseView;
        if(img == nil){
            img = [[UIImageView alloc] init];
        }
        img.image = [UIImage imageNamed: name];
        return img;
    } resultBlock: nil];
}

+ (void)buttonWithTitle:(NSString *)title styleClass:(NSString *)styleClass onClick:(FGVoidBlock)onClick
{
    [self customViewWithClass:styleClass reuseId:[FGInternal callerPositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
        UIButton *btn = (UIButton *) reuseView;
        if (btn == nil) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:btn action:@selector(notify) forControlEvents:UIControlEventTouchUpInside];
        }
        [btn respondsToSelector:@selector(notify) withKey:nil usingBlock:^(id btn){
            onClick();
        }];
        [UIView setAnimationsEnabled:NO];
        [btn setTitle:title forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        return btn;
    } resultBlock:nil];
}

+ (BOOL) toggleButtonWithTitle:(NSString *)title
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:title styleClass: nil];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:title styleClass: styleClass];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:selectedTitle styleClass:nil];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:selectedTitle styleClass:styleClass];
}

+ (BOOL)toggleButtonWithReuseId:(NSString *)reuseId title:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    NSNumber *ret = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UIButton *btn = (UIButton *) reuseView;
        if (btn == nil){
            btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn bk_addEventHandler:^(id sender) {
                UIButton *btn = sender;
                btn.selected = !btn.selected;
                [FastGui reloadGui];
            } forControlEvents:UIControlEventTouchUpInside];
        }
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:selectedTitle forState:UIControlStateSelected];
        return btn;
    } resultBlock:^id(UIView *view) {
        UIButton *btn = (UIButton *) view;
        return [NSNumber numberWithBool: btn.selected];
    }];
    return ret.boolValue;
}

+ (NSString *) textField
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil placeHolder:nil isPassword:NO];
}

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil placeHolder:placeHolder isPassword:NO];
}

+ (NSString *) textFieldWithStyleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:nil isPassword:NO];
}

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:placeHolder isPassword:NO];
}

+ (NSString *) passwordField
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil placeHolder:nil isPassword:YES];
}

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil placeHolder:placeHolder isPassword:YES];
}

+ (NSString *) passwordFieldWithStyleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:nil isPassword:YES];
}

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:placeHolder isPassword:YES];
}


+ (NSString *) textFieldWithReuseId: (NSString *)reuseId styleClass: (NSString *)styleClass placeHolder: (NSString *)placeHolder isPassword: (BOOL) isPassword;
{
    return [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UITextField *text = (UITextField *) reuseView;
        if (text == nil) {
            text = [[UITextField alloc] init];
            [text bk_addEventHandler:^(id sender) {
                [FastGui reloadGui];
            } forControlEvents:UIControlEventEditingChanged];
        }
        text.placeholder = placeHolder;
        text.secureTextEntry = isPassword;
        return text;
    } resultBlock:^id(UIView *view) {
        UITextField *text = (UITextField *) view;
        return text.text;
    }];
}

+ (NSInteger)segmentControlWithReuseId: (NSString *) reuseId
                                 items: (NSArray *) array
                  selectedSegmentIndex: (NSNumber*) selectedSegmentIndex
                            styleClass: (NSString *)styleClass
{
    NSNumber *num = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UISegmentedControl *segment = (UISegmentedControl *) reuseView;
        if (segment == nil) {
            segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 0, 31)];
            [segment bk_addEventHandler:^(id sender) {
                UISegmentedControl *segment = sender;
                [segment reloadGuiChangingResult: [NSNumber numberWithInteger: segment.selectedSegmentIndex]];
            } forControlEvents:UIControlEventValueChanged];
        }
        while (segment.numberOfSegments > array.count ) {
            [segment removeSegmentAtIndex:segment.numberOfSegments - 1 animated:NO];
        }
        for (NSUInteger i = 0; i<segment.numberOfSegments; i++) {
            if (![[segment titleForSegmentAtIndex:i] isEqualToString: array[i]]) {
                [segment setTitle:array[i] forSegmentAtIndex:i];
            }
        }
        while (segment.numberOfSegments < array.count) {
            [segment insertSegmentWithTitle:array[segment.numberOfSegments] atIndex:segment.numberOfSegments animated:NO];
        }
        if (selectedSegmentIndex != nil && segment.changingResult == nil) {
            segment.selectedSegmentIndex = [selectedSegmentIndex integerValue];
        }
        return segment;
    } resultBlock:^id(UIView *view) {
        if (view.changingResult) {
            return view.changingResult;
        }else{
            return [NSNumber numberWithInteger:((UISegmentedControl *) view).selectedSegmentIndex];
        }
    }];
    return num == nil ? -1 : [num integerValue];
}


+ (NSUInteger)segmentControlWithItems:(NSArray *)items
{
    return [self segmentControlWithReuseId:[FGInternal callerPositionAsReuseId] items:items selectedSegmentIndex:nil styleClass:nil];
}

+ (NSUInteger)segmentControlWithItems:(NSArray *)items selectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    return [self segmentControlWithReuseId:[FGInternal callerPositionAsReuseId] items:items selectedSegmentIndex:[NSNumber numberWithInteger: selectedSegmentIndex] styleClass:nil];
}

+ (NSUInteger)segmentControlWithItems:(NSArray *)items styleClass:(NSString *)styleClass
{
    return [self segmentControlWithReuseId:[FGInternal callerPositionAsReuseId] items:items selectedSegmentIndex:nil styleClass:styleClass];
}

+ (NSUInteger)segmentControlWithItems:(NSArray *)items selectedSegmentIndex:(NSInteger)selectedSegmentIndex styleClass:(NSString *)styleClass
{
    return [self segmentControlWithReuseId:[FGInternal callerPositionAsReuseId] items:items selectedSegmentIndex:[NSNumber numberWithInteger: selectedSegmentIndex] styleClass:styleClass];
}

+ (void) activityIndicator
{
    [self activityIndicatorWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void) activityIndicatorWithStyleClass: (NSString *)styleClass
{
    [self activityIndicatorWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void) activityIndicatorWithReuseId: (NSString *) reuseId styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UIActivityIndicatorView *view = (UIActivityIndicatorView*)reuseView;
        if (view == nil) {
            view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        [view startAnimating];
        return view;
    } resultBlock:nil];
}


@end

@implementation FGStyle (FGBasicViews)

+ (void)labelLines:(NSInteger)lines
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UILabel class]]) {
            ((UILabel *)view).numberOfLines = lines;
        }
    }];
}

@end
