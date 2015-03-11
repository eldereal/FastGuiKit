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
typedef void (^FGStyleBlock )(UIView *view);

typedef UIViewController * (^FGInitCustomViewControllerBlock) (UIViewController * reuseViewController);

typedef void( ^ FGNotifyCustomViewResultBlock) ();

typedef UIView * (^FGInitCustomViewBlock) (UIView * reuseView, FGNotifyCustomViewResultBlock notifyResult, FGStyleBlock applyStyleBlock);

typedef id( ^ FGGetCustomViewResultBlock) (UIView *view);


@interface FGVoidBlockHolder : NSObject

+ (FGVoidBlockHolder *) holderWithBlock: (FGVoidBlock) block;

@property (copy) FGVoidBlock block;

- (void) notify;

@end

@interface FGStyleBlockHolder : NSObject

+ (FGStyleBlockHolder *) holderWithBlock: (FGStyleBlock) block;

@property (copy) FGStyleBlock block;

-(void)notify: (UIView *) view;

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


