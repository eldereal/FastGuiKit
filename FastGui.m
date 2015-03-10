//
//  FastGUI.m
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//
#import <objc/runtime.h>
#import "FastGUI.h"
#import "FGInternal.h"

static void * ParentContextPropertyKey = &ParentContextPropertyKey;

@interface FastGui ()

+ (void) setContext: (id<FGContext>) context;

@end

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
        @try {
            onGui();
        }
        @finally {
            [self popContext];
        }
        assert(self.context == nil);
    //});
}

+ (void) customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [self.context customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

+ (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock: (FGGetCustomViewResultBlock) resultBlock
{
    return [self.context customViewWithReuseId:reuseId initBlock:initBlock resultBlock:resultBlock];
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
