//
//  ZPCAlertControllerManager.m
//  alertManager
//
//  Created by Noah on 2020/5/27.
//  Copyright © 2020 Noah Gao. All rights reserved.
//

#import "ZPCAlertControllerManager.h"

#pragma mark - ZPCAlertRootViewController

@interface ZPCAlertRootViewController : UIViewController

@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

@end

@implementation ZPCAlertRootViewController

- (instancetype)init
{
    self = [super init];
    if( self )
    {
        NSLog( @"++ " );
    }
    return( self );
}

- (void)dealloc
{
    NSLog( @"-- " );
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return( self.supportedOrientations );
}

@end


@interface ZPCAlertControllerManager() <ZPCAlertDelegate>

@property(nonatomic, weak) UIWindow *originalKeyWindow;
@property(nonatomic, strong) UIWindow *alertWindow;

@property(nonatomic, strong) NSMutableArray<UIViewController<ZPCAlertManageable> *> *alertQueue;

@end

@implementation ZPCAlertControllerManager

+ (instancetype)sharedInstance
{
    static ZPCAlertControllerManager *instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZPCAlertControllerManager alloc] init];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _alertQueue = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)presentAlertWindow
{
    if( !self.alertWindow )
    {
        self.originalKeyWindow = [UIApplication sharedApplication].keyWindow;

        self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.alertWindow.backgroundColor = [UIColor clearColor];
        self.alertWindow.windowLevel = UIWindowLevelAlert;
        self.alertWindow.accessibilityViewIsModal = YES;

        ZPCAlertRootViewController *rootVC = [[ZPCAlertRootViewController alloc] init];
        rootVC.supportedOrientations = [self.originalKeyWindow.rootViewController supportedInterfaceOrientations];
        self.alertWindow.rootViewController = rootVC;

        [self.alertWindow makeKeyAndVisible];
    }
}

- (void)dismissAlertWindow
{
    if( self.alertWindow )
    {
        self.alertWindow.hidden = YES;
        self.alertWindow = nil;

        [self.originalKeyWindow makeKeyAndVisible];
    }
}


- (void)presentAlertController:(UIViewController<ZPCAlertManageable> *)controller
{
    if (controller == nil || ![controller conformsToProtocol:@protocol(ZPCAlertManageable)]) {
        return;
    }

    controller.delegate = self;

    [self.alertQueue removeObject:controller];
    [self presentAlertWindow];

    UIViewController<ZPCAlertManageable> *presentedController = (UIViewController<ZPCAlertManageable> *)self.alertWindow.rootViewController.presentedViewController;

    if( (presentedController && presentedController.priority > controller.priority)  || presentedController.isBeingDismissed || presentedController.isBeingPresented ) {

        [self.alertQueue addObject:controller];

    } else {
        if( presentedController != nil) {
            // if presentedController priority < controller priority, it should dismiss presentedController and display controller
            // due to using delegate, so we need to add object to alertQueue
            // in delegate alertDidDisappear auto choose which should display first
            [self.alertQueue addObject:controller];
            [self.alertQueue addObject:presentedController];
            [presentedController.presentingViewController dismissViewControllerAnimated:true completion:^{

            }];
        } else {
            [self.alertWindow.rootViewController presentViewController:controller animated:true completion:nil];
        }
    }
}

- (void)dismissAlertController:(UIViewController<ZPCAlertManageable> *)controller
{
    if (controller == nil) {
        return;
    }

    UIViewController<ZPCAlertManageable> *presentedController = (UIViewController<ZPCAlertManageable> *)self.alertWindow.rootViewController.presentedViewController;

    if (presentedController == controller) {
        if ( !presentedController.isBeingDismissed ) {
            [presentedController.presentingViewController dismissViewControllerAnimated:true completion:^{

            }];
        }
    } else {
        [self.alertQueue removeObject:controller];
    }
}


- (void)alertDidDisappear:(UIViewController *)alert
{
    UIViewController<ZPCAlertManageable> *high = nil;
    UIViewController<ZPCAlertManageable> *normal = nil;
    UIViewController<ZPCAlertManageable> *low  = nil;

    for (UIViewController<ZPCAlertManageable> *vc in self.alertQueue) {
        if (vc.priority == ZPCAlertPriorityHigh && high == nil) {
            high = vc;
        } else if (vc.priority == ZPCAlertPriorityNormal  && normal == nil) {
            normal = vc;
        } else if (vc.priority == ZPCAlertPriorityLow  && low == nil) {
            low = vc;
        }
    }

    if(high != nil) {
        [self.alertQueue removeObject:high];
        [self.alertWindow.rootViewController presentViewController:high animated:true completion:nil];
    } else if (normal != nil) {
        [self.alertQueue removeObject:normal];
        [self.alertWindow.rootViewController presentViewController:normal animated:true completion:nil];
    } else if (low != nil) {
        [self.alertQueue removeObject:low];
        [self.alertWindow.rootViewController presentViewController:low animated:true completion:nil];
    } else {
        [self dismissAlertWindow];
    }
}

@end
