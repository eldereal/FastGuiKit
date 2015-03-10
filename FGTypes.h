//
//  FGTypes.h
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/3.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ FGVoidBlock)();

typedef id(^ FGIdBlock)();

typedef FGVoidBlock FGOnGuiBlock;

typedef UIViewController * (^FGInitCustomViewControllerBlock) (UIViewController * reuseViewController);

typedef void( ^ FGNotifyCustomViewResultBlock) ();

typedef UIView * (^FGInitCustomViewBlock) (UIView * reuseView, FGNotifyCustomViewResultBlock notifyResult);

typedef id( ^ FGGetCustomViewResultBlock) (UIView *view);


@interface FGVoidBlockHolder : NSObject

+ (FGVoidBlockHolder *) holderWithBlock: (FGVoidBlock) block;

@property (copy) FGVoidBlock block;

- (void) notify;

@end

@interface FGNotifyCustomViewResultHolder: NSObject

+ (FGNotifyCustomViewResultHolder *) holderWithBlock: (FGNotifyCustomViewResultBlock) block;

@property (copy) FGNotifyCustomViewResultBlock block;

- (void) notify;

@end


@interface UIView (FastGui)

@property (nonatomic, copy) NSString *reuseId;

@property (nonatomic, strong) FGNotifyCustomViewResultHolder * notifyHolder;

@end


