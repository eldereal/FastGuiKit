//
//  FastGUI.m
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//

#import "FastGUI.h"
#import "FGInternal.h"

@interface FastGui ()

@property (nonatomic, strong) id<FGContext> context;

@end

@implementation FastGui

@synthesize context;

static FastGui *instance;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        instance = [[FastGui alloc] init];
    }
}

+ (id<FGContext>)context
{
    return instance.context;
}

+ (void) callWithContext:(id<FGContext>)context block:(FGOnGuiBlock)block
{
    id<FGContext> old = instance.context;
    @try {
        instance.context = context;
        block();
    }
    @finally {
        instance.context = old;
    }
}

+ (void) customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [instance.context customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

+ (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock: (FGGetCustomViewResultBlock) resultBlock
{
    return [instance.context customViewWithReuseId:reuseId initBlock:initBlock resultBlock:resultBlock];
}




+ (void) viewController: (FGOnGuiBlock) onGui
{
    
}

+ (void) navigationController: (FGOnGuiBlock) onGui
{

}

+ (void) tableViewController: (FGOnGuiBlock) onGui
{
    
}

+ (BOOL) tableCellSection: (NSString *) title
{
    return false;
}

+ (BOOL) tableCell: (NSString *) title
{
    return false;
}

+ (void) alert: (NSString *) content
{
    
}

+ (BOOL) confirm: (NSString *) content
{
    return false;
}

+ (NSString *) prompt: (NSString *) content
{
    return nil;
}

@end
