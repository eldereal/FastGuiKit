//
//  FGNullViewContext.m
//  train-helper
//
//  Created by 易元 白 on 15/3/26.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGNullViewContext.h"

@implementation FGNullViewContext

@synthesize parentContext;

- (void)reloadGui
{
    [parentContext reloadGui];
}

- (void)styleSheet
{
    [parentContext styleSheet];
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    return [parentContext customData:key data:data];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    return [parentContext customViewWithReuseId:reuseId initBlock:initBlock resultBlock:resultBlock applyStyleBlock:applyStyleBlock];
}

- (void)dismissViewController
{
    [parentContext dismissViewController];
}

@end
