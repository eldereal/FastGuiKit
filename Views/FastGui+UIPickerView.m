//
//  FastGui+UIPickerView.m
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGui+UIPickerView.h"
#import "FGInternal.h"

@interface FGPickerView : UIPickerView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray * items;

@property (nonatomic) NSInteger selectedIndex;

@end

@implementation FastGui (UIPickerView)

+ (NSInteger)pickerWithTextList:(NSArray *)list
{
    return [self pickerWithReuseId:[FGInternal callerPositionAsReuseId] textList:list styleClass:nil];
}

+ (NSInteger)pickerWithTextList:(NSArray *)list styleClass:(NSString *)styleClass
{
    return [self pickerWithReuseId:[FGInternal callerPositionAsReuseId] textList:list styleClass:styleClass];
}

+ (NSInteger)pickerWithReuseId:(NSString *)reuseId textList:(NSArray *)list styleClass:(NSString *)styleClass
{
    FGPickerView *picker = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        FGPickerView *picker = (FGPickerView *)reuseView;
        if (picker == nil) {
            picker = [[FGPickerView alloc] init];
        }
        picker.items = list;
        [picker reloadAllComponents];
        return picker;
    } resultBlock:^id(UIView *view) {
        return view;
    }];
    return picker.selectedIndex;
}

@end

@implementation FGPickerView

- (instancetype)init
{
    if (self = [super init]) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.items.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.items[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedIndex = row;
}

@end
