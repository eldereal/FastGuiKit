//
//  FGViewPool.h
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FGTypes.h"

@interface FGViewPool : NSObject

@property (nonatomic, strong, readonly) NSMutableArray * oldViews;

@property (nonatomic, strong, readonly) NSMutableArray * views;

@property (nonatomic, strong, readonly) NSMutableArray * needAddViews;

@property (nonatomic, strong, readonly) NSMutableArray * needRemoveViews;

- (void) prepareUpdateViews;

- (UIView *) updateView: (NSString *) reuseId initBlock:(FGInitCustomViewBlock)initBlock notifyBlock: (FGNotifyCustomViewResultBlock) notifyBlock outputIsNewView: (BOOL *)isNewView;

- (void) finishUpdateViews: (void(^)(UIView *)) needAdd needRemove: (void(^)(UIView *)) needRemove;

@end
