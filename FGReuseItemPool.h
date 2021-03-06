//
//  FGViewPool.h
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FGTypes.h"

typedef id<FGWithReuseId> (^FGInitReuseItemBlock) (id<FGWithReuseId> reuseItem);

@interface FGReuseItemPool : NSObject

- (instancetype)initWithArray:(NSArray *) array;

@property (nonatomic, strong, readonly) NSArray * items;

- (void) prepareUpdateItems;

- (id<FGWithReuseId>) updateItem: (NSString *) reuseId initBlock:(FGInitReuseItemBlock)initBlock outputIsNewView: (BOOL *)isNewView;

- (void) finishUpdateItems: (void(^)(id<FGWithReuseId>)) needAdd needRemove: (void(^)(id<FGWithReuseId>)) needRemove;

@end
