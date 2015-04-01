//
//  FastGUI.h
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//

#import "FGContext.h"
#import "FGTypes.h"


@interface FastGui : NSObject

+ (void) pushContext: (id<FGContext>) context;

+ (void) popContext;

/**
 * display a custom view with context's layout.
 */
+ (id) customViewWithClass:(NSString *)styleClass reuseId: (NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock: (FGGetCustomViewResultBlock) resultBlock;

+ (id) customData:(void*) key data:(NSDictionary *)data;

+ (void) styleOfClass: (NSString *) styleClass block: (FGStyleBlock) block;

+ (void) styleOfType: (Class) type block: (void(^)(UIView *view, NSString *styleClass)) block;

+ (void) styleOfAll: (void(^)(UIView *view, NSString *styleClass)) block;

+ (void) reloadGui;

+ (void) reloadGuiSyncWithContext: (id<FGContext>) context;

+ (void) reloadGuiWithBeforeBlock: (FGVoidBlock) before withAfterBlock: (FGVoidBlock) after;

+ (void) reloadGuiAfterTimeInterval: (NSTimeInterval) after;

/**
 * present a custom view controller if possible.
 */
+ (void) customViewControllerWithReuseId: (NSString *) reuseId initBlock: (FGInitCustomViewControllerBlock) initBlock;

+ (void) dismissViewController;


@end
