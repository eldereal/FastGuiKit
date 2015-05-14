//
//  MBProgressHUD+FastGui.m
//  exibitour
//
//  Created by 易元 白 on 15/5/14.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "MBProgressHUD+FastGui.h"
#import "FastGuiKit.h"
#import "FGInternal.h"
#import <REKit/REKit.h>

@interface MBProgressHUDWithProgress : MBProgressHUD

@property (nonatomic, strong) NSProgress * progressNotifier;

@property (nonatomic, strong, readonly) NSObject * progressObserver;

@end

@implementation FastGui(MBProgressHUD)

+ (void)progressHUDWithProgress:(NSProgress *)progress label:(NSString *)label styleClass:(NSString *)styleClass
{
//    [FastGui beginGroupWithNextView];
//    UIView *view = [FastGui customViewWithClass:styleClass reuseId:[FGInternal callerPositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
//        if (reuseView == nil) {
//            reuseView = [[UIView alloc] init];
//        }
//        return reuseView;
//    } resultBlock:^id(UIView *view) {
//        return view;
//    }];
    [FastGui customViewWithClass:nil reuseId:[FGInternal callerPositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
        MBProgressHUDWithProgress *hud = (MBProgressHUDWithProgress *) reuseView;
        if (hud == nil) {
            hud = [[MBProgressHUDWithProgress alloc] init];
            hud.removeFromSuperViewOnHide = NO;
            hud.mode = MBProgressHUDModeDeterminate;
            hud.labelText = label;
            hud.progressNotifier = progress;
            if (progress.indeterminate) {
                hud.mode = MBProgressHUDModeIndeterminate;
            }else{
                hud.mode = MBProgressHUDModeDeterminate;
                hud.progress = progress.fractionCompleted;
            }
            [hud show:YES];
        }else{
            hud.mode = MBProgressHUDModeDeterminate;
            hud.labelText = label;
            hud.progressNotifier = progress;
            if (progress.indeterminate) {
                hud.mode = MBProgressHUDModeIndeterminate;
            }else{
                hud.mode = MBProgressHUDModeDeterminate;
                hud.progress = progress.fractionCompleted;
            }

        }
        return hud;
    } resultBlock: nil];
//    [FastGui endGroup];
}

@end

@implementation MBProgressHUDWithProgress

@synthesize progressNotifier = _progressNotifier;
@synthesize progressObserver = _progressObserver;

- (NSObject *)progressObserver
{
    if (_progressObserver == nil) {
        _progressObserver = [[NSObject alloc] init];
        [_progressObserver respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:) withKey:nil usingBlock:^{
            if(self.progressNotifier != nil) {
                if (self.progressNotifier.indeterminate) {
                    self.mode = MBProgressHUDModeIndeterminate;
                }else{
                    self.mode = MBProgressHUDModeDeterminate;
                    self.progress = self.progressNotifier.fractionCompleted;
                }
            }
        }];
    }
    return _progressObserver;
}

- (void)setProgressNotifier:(NSProgress *)progressNotifier
{
    if (_progressNotifier != nil) {
        [_progressNotifier removeObserver:self.progressObserver forKeyPath:@"indeterminate"];
        [_progressNotifier removeObserver:self.progressObserver forKeyPath:@"fractionCompleted"];
    }
    _progressNotifier = progressNotifier;
    [_progressNotifier addObserver:self.progressObserver forKeyPath:@"indeterminate" options:NSKeyValueObservingOptionNew context:nil];
    [_progressNotifier addObserver:self.progressObserver forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
}

@end
