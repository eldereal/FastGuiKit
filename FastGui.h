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

/**
 * get current gui context
 */
+ (id<FGContext>) context;

/**
 * call onGui callback with given context
 */
+ (void) callWithContext: (id<FGContext>) context block: (FGOnGuiBlock) block;

/**
 * present a custom view controller if possible.
 */
+ (void) customViewControllerWithReuseId: (NSString *) reuseId initBlock: (FGInitCustomViewControllerBlock) initBlock;

/**
 * display a custom view with context's layout.
 */
+ (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock: (FGGetCustomViewResultBlock) resultBlock;






+ (void) navigationController: (FGOnGuiBlock) onGui;

+ (void) alert: (NSString *) content;

+ (BOOL) confirm: (NSString *) content;

+ (NSString *) prompt: (NSString *) content;


@end
