//
//  FastGui+UIPickerView.h
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGUI.h"

@interface FastGui (UIPickerView)

+ (NSInteger) pickerWithTextList: (NSArray *)list;

+ (NSInteger) pickerWithTextList: (NSArray *)list styleClass:(NSString *) styleClass;

+ (id) pickerWithObjectList: (NSArray *)list objectLabel: (NSString *(^)(id)) objectLabel;

+ (id) pickerWithObjectList: (NSArray *)list objectLabel: (NSString *(^)(id)) objectLabel styleClass:(NSString *) styleClass;

@end
