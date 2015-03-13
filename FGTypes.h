//
//  FGTypes.h
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/3.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void( ^ FGVoidBlock) ();

typedef id(^ FGIdBlock)();

typedef FGVoidBlock FGOnGuiBlock;
typedef void (^FGStyleBlock )(UIView *view);

typedef UIViewController * (^FGInitCustomViewControllerBlock) (UIViewController * reuseViewController);



typedef UIView * (^FGInitCustomViewBlock) (UIView * reuseView, FGVoidBlock notifyResult);

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

+ (FGNotifyCustomViewResultHolder *) holderWithBlock: (FGVoidBlock) block;

@property (copy) FGVoidBlock block;

- (void) notify;

@end


@protocol FGWithReuseId <NSObject>

@property (nonatomic, copy) NSString *reuseId;

@end

@interface UIView (FastGui) <FGWithReuseId>

@property (nonatomic, strong) FGNotifyCustomViewResultHolder * notifyHolder;

@end


