//
//  FastGUI.m
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//
#import <BlocksKit/BlocksKit.h>
#import <objc/runtime.h>
#import "FastGUI.h"
#import "FGInternal.h"
#import "FGStyle.h"

static void * ParentContextPropertyKey = &ParentContextPropertyKey;

@implementation FastGui

static id<FGContext> _context = nil;
static id<FGContext> _nextContext = nil;

+ (void) setContext: (id<FGContext>) context
{
    _context = context;
}

+ (id<FGContext>) context
{
    return _context;
}

static __weak UIView *_styleTarget;

+ (UIView *) styleTarget
{
    return _styleTarget;
}

+ (void) setStyleTarget: (UIView *) styleTarget
{
    _styleTarget = styleTarget;
}



static NSArray *_styleClass;

+ (NSArray *) styleClass
{
    return _styleClass;
}

+ (void) setStyleClass: (NSArray *) styleClass
{
    _styleClass = [styleClass copy];
}

static NSString *_styleClassRaw;


+ (void) pushContext:(id<FGContext>)context
{
//    NSArray *stack = [NSThread callStackSymbols];
//    printf("push context %s\n    %s\n    %s\n", [NSStringFromClass([context class]) UTF8String], [(NSString *) stack[1] UTF8String], [(NSString *) stack[2] UTF8String]);
    id<FGContext> ctx = self.context;
    while (ctx != nil) {
        if (ctx == context) {
            [[NSException exceptionWithName:@"Redundant context" reason:@"You have pushed a context that is already in the context tree" userInfo:nil] raise];
        }
        ctx = ctx.parentContext;
    }
    context.parentContext = self.context;
    self.context = context;
}

+ (void) popContext
{
//    printf("pop context %s\n", [NSStringFromClass([self.context class]) UTF8String]);
    if (self.context != nil) {
        self.context = self.context.parentContext;
    }
}

+ (void)setRootContext:(id<FGContext>)context
{
    _nextContext = context;
}

+ (void) customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [self.context customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

+ (void)dismissViewController
{
    [self.context dismissViewController];
}

+ (id) customViewWithClass:(NSString *)styleClass reuseId: (NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock: (FGGetCustomViewResultBlock) resultBlock
{
    return [self.context customViewWithReuseId:reuseId initBlock:initBlock resultBlock:resultBlock applyStyleBlock:^(UIView *view) {
        [FGStyle updateStyleOfView:view withBlock:^(UIView *view) {
            _styleClassRaw = styleClass;
            self.styleClass = [styleClass componentsSeparatedByString:@" "];
            self.styleTarget = view;
            [self.context styleSheet];
        }];
    }];
}

+ (void) styleOfClass:(NSString *)styleClass block:(FGStyleBlock)block
{
    if ([self.styleClass bk_any:^BOOL(NSString *viewStyleClass) {
        return [styleClass isEqualToString:viewStyleClass];
    }]) {
        block(self.styleTarget);
    }
}

+ (void)styleOfType:(Class)type block:(void(^)(UIView *view, NSString *styleClass))block
{
    if ([self.styleTarget isKindOfClass:type]) {
        block(self.styleTarget, _styleClassRaw);
    }
}

+ (void) styleOfAll:(void(^)(UIView *view, NSString *styleClass))block
{
    block(self.styleTarget, _styleClassRaw);
}

+ (id) customData:(void*) key data:(NSDictionary *)data
{
    return [self.context customData:key data:data];
}

+ (void) reloadGuiProtectContext
{
    NSLog(@"Reload gui");
    id ctx = self.context;
    [self.context reloadGui];
    if (self.context != ctx) {
        [[NSException exceptionWithName:@"Unbalanced push/pop gui context" reason:@"You may have called less/more/unmatched EndXXX with BeginXXX" userInfo:nil] raise];
    }
}

+ (void) reloadGui
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_nextContext != nil) {
            _context = _nextContext;
            _nextContext = nil;
        }
        [self reloadGuiProtectContext];
    });
}

+ (void)reloadGuiSyncWithContext:(id<FGContext>)context
{
    if ([NSThread isMainThread]) {
        [self pushContext:context];
        [self reloadGuiProtectContext];
        [self popContext];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self pushContext:context];
            [self reloadGuiProtectContext];
            [self popContext];
        });
    }
}

+ (void)reloadGuiWithBeforeBlock:(FGVoidBlock)before withAfterBlock:(FGVoidBlock)after
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_nextContext != nil) {
            _context = _nextContext;
            _nextContext = nil;
        }
        if (before != nil) {
            before();
        }
        [self reloadGuiProtectContext];
        if (after != nil) {
            after();
        }
    });
}

+ (void)reloadGuiAfterTimeInterval:(NSTimeInterval)after
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_nextContext != nil) {
            _context = _nextContext;
            _nextContext = nil;
        }
        [self reloadGuiProtectContext];
    });
}

@end
