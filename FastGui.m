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

+ (void) setContext: (id<FGContext>) context
{
    _context = context;
}

+ (id<FGContext>) context
{
    return _context;
}

static NSMutableArray *_styleArray;

+ (NSMutableArray *) styleArray
{
    return _styleArray;
}

+ (void) setStyleArray: (NSMutableArray *) styleArray
{
    _styleArray = styleArray;
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

+ (void) pushContext:(id<FGContext>)context
{
    context.parentContext = self.context;
    self.context = context;
}

+ (void) popContext
{
    if (self.context != nil) {
        self.context = self.context.parentContext;
    }
}

+ (void) callOnGui: (FGOnGuiBlock) onGui withContext: (id<FGContext>) context
{
    //dispatch_async(dispatch_get_main_queue(), ^{
        assert(self.context == nil);
        [self pushContext:context];
        //@try {
            onGui();
        //}@finally {
            [self popContext];
        //}
        assert(self.context == nil);
    //});
}

+ (void) customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [self.context customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

+ (id) customViewWithClass:(NSString *)styleClass reuseId: (NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock: (FGGetCustomViewResultBlock) resultBlock
{
    NSMutableArray *array = nil;
    if (styleClass != nil) {
        self.styleClass = [styleClass componentsSeparatedByString:@" "];
        self.styleArray = [NSMutableArray array];
        [self.context styleSheet];
        array = self.styleArray;
    }
    
    self.styleArray = nil;
    return [self.context customViewWithReuseId:reuseId initBlock:initBlock resultBlock:resultBlock applyStyleBlock:^(UIView *view) {
        [FGStyle updateStyleOfView:view withBlock:^(UIView *view) {
            for (FGStyleBlockHolder *holder in array) {
                [holder notify: view];
            }
        }];
    }];
}

+ (void)styleOfClass:(NSString *)styleClass block:(FGStyleBlock)block
{
    if ([self.styleClass bk_any:^BOOL(NSString *viewStyleClass) {
        return [styleClass isEqualToString:viewStyleClass];
    }]) {
        [self.styleArray addObject:[FGStyleBlockHolder holderWithBlock:block]];
    }
}

+ (id) customData:(void*) key data:(NSDictionary *)data
{
    return [self.context customData:key data:data];
}

+ (void) reloadGui
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.context reloadGui];
    });
}

@end
