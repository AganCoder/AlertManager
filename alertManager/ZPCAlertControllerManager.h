//
//  ZPCAlertControllerManager.h
//  alertManager
//
//  Created by Noah on 2020/5/27.
//  Copyright © 2020 Noah Gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ZPC_FONT_BOLD_OF_SIZE( fontsize ) [UIFont boldSystemFontOfSize:fontsize] 
#define UIColorFromARGB( A, R, G, B ) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A/255.0]
#define ZPC_FONT_OF_SIZE( fontsize ) [UIFont systemFontOfSize:fontsize]
#define UIColorFromRGB( R, G, B ) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

typedef NS_ENUM(NSUInteger, ZPCAlertPriority) {
    ZPCAlertPriorityLow,
    ZPCAlertPriorityNormal,
    ZPCAlertPriorityHigh,
};

@protocol ZPCAlertDelegate <NSObject>

- (void)alertDidDisappear:(UIViewController *)alert;

@end

@protocol ZPCAlertManageable <NSObject>

@property(nonatomic, assign) ZPCAlertPriority priority;

@property(nonatomic, weak) id<ZPCAlertDelegate> delegate;

@end


@interface ZPCAlertControllerManager : NSObject

+ (instancetype)sharedInstance;

- (void)presentAlertController:(UIViewController<ZPCAlertManageable> *)controller;

- (void)dismissAlertController:(UIViewController<ZPCAlertManageable> *)controller;

@end

