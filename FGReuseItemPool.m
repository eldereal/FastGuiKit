//
//  FGViewPool.m
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FGReuseItemPool.h"

@interface FGReuseItemPool()

@property (nonatomic, strong) NSMutableArray * mutableItems;

@property (nonatomic, strong) NSMutableArray * oldItems;

@property (nonatomic, strong) NSMutableArray * needAddItems;

@property (nonatomic, strong) NSMutableArray * needRemoveItems;

@end

@implementation FGReuseItemPool



- (NSMutableArray *)mutableItems
{
    return (NSMutableArray *) _items;
}

- (void)setMutableItems:(NSMutableArray *)mutableItems
{
    _items = mutableItems;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.oldItems = [NSMutableArray array];
        self.mutableItems = [NSMutableArray array];
        self.needAddItems = [NSMutableArray array];
        self.needRemoveItems = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array
{
    self = [self init];
    if (self) {
        [self.mutableItems addObjectsFromArray:array];
    }
    return self;
}

- (void)prepareUpdateItems
{
    NSMutableArray *temp = self.oldItems;
    self.oldItems = self.mutableItems;
    self.mutableItems = temp;
    [self.mutableItems removeAllObjects];
    [self.needAddItems removeAllObjects];
    [self.needRemoveItems removeAllObjects];
}

- (id<FGWithReuseId>) updateItem: (NSString *) reuseId initBlock:(FGInitReuseItemBlock)initBlock outputIsNewView: (BOOL *)isNewView;
{
    BOOL noOutIsNew;
    if (isNewView == NULL) {
        isNewView = &noOutIsNew;
    }
    UIView *foundReuseView = nil;
    for (NSUInteger i = 0; i < self.oldItems.count; i++) {
        UIView *view = self.oldItems[i];
        if ([view.reuseId isEqualToString: reuseId]) {
            foundReuseView = view;
            for (NSUInteger j = 0; j < i; j++) {
                [self.needRemoveItems addObject: self.oldItems[j]];
            }
            [self.oldItems removeObjectsInRange:NSMakeRange(0, i + 1)];
            break;
        }
    }
    id<FGWithReuseId> view = initBlock(foundReuseView);
    view.reuseId = reuseId;
    [self.mutableItems addObject: view];
    *isNewView = view != nil && view != foundReuseView;
    
    if (*isNewView) {
        [self.needAddItems addObject: view];
    }
    if (foundReuseView != nil && view != foundReuseView) {
        [self.needRemoveItems addObject: foundReuseView];
    }
    
    return view;
}

- (void) finishUpdateItems: (void(^)(id<FGWithReuseId>)) needAdd needRemove: (void(^)(id<FGWithReuseId>)) needRemove;
{
    if (needAdd != nil) {
        for (UIView *view in self.needAddItems) {
            needAdd(view);
        }
    }
    if (needRemove != nil){
        for (UIView *view in self.needRemoveItems) {
            needRemove(view);
        }
        for (UIView *view in self.oldItems) {
            needRemove(view);
        }
    }
    [self.needAddItems removeAllObjects];
    [self.needRemoveItems removeAllObjects];
    [self.oldItems removeAllObjects];
}



@end
