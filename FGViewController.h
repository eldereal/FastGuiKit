//
//  FGViewController.h
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//

#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGContext.h"
#import "FGTypes.h"

@interface FastGui (FGViewController)

+ (void) viewController: (FGOnGuiBlock) onGui;

+ (void) withFrame: (CGRect) rect;

+ (void) withFrame: (CGRect) rect animated: (BOOL) animated;

@end

@interface FGViewController : UIViewController<FGContext>

- (void) onGui;

@end
