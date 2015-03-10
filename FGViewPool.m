//
//  FGViewPool.m
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FGViewPool.h"

@implementation FGViewPool

- (instancetype)init
{
    self = [super init];
    if (self) {
        _oldViews = [NSMutableArray array];
        _views = [NSMutableArray array];
        _needAddViews = [NSMutableArray array];
        _needRemoveViews = [NSMutableArray array];
    }
    return self;
}

- (void)prepareUpdateViews
{
    NSMutableArray *temp = _oldViews;
    _oldViews = _views;
    _views = temp;
    [_views removeAllObjects];
    [_needAddViews removeAllObjects];
    [_needRemoveViews removeAllObjects];
}

- (UIView *)updateView:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock notifyBlock:(FGNotifyCustomViewResultBlock)notifyBlock outputIsNewView:(BOOL *)isNewView
{
    UIView *foundReuseView = nil;
    for (NSUInteger i = 0; i < _oldViews.count; i++) {
        UIView *view = _oldViews[i];
        if ([view.reuseId isEqualToString: reuseId]) {
            foundReuseView = view;
            for (NSUInteger j = 0; j < i; j++) {
                [_needRemoveViews addObject: _oldViews[j]];
            }
            [_oldViews removeObjectsInRange:NSMakeRange(0, i + 1)];
            break;
        }
    }
    UIView *view = initBlock(foundReuseView, notifyBlock);
    view.reuseId = reuseId;
    [_views addObject: view];
    *isNewView = view != nil && view != foundReuseView;
    if (foundReuseView != nil && view != foundReuseView) {
        [_needRemoveViews addObject: foundReuseView];
    }
    if (view != nil && view != foundReuseView) {
        [_needAddViews addObject: view];
    }
    return view;
}

- (void)finishUpdateViews:(void (^)(UIView *))needAdd needRemove:(void (^)(UIView *))needRemove
{
    if (needAdd != nil) {
        for (UIView *view in _needAddViews) {
            needAdd(view);
        }
    }
    if (needRemove != nil){
        for (UIView *view in _needRemoveViews) {
            needRemove(view);
        }
        for (UIView *view in _oldViews) {
            needRemove(view);
        }
    }
    [_needAddViews removeAllObjects];
    [_needRemoveViews removeAllObjects];
    [_oldViews removeAllObjects];
}



@end
