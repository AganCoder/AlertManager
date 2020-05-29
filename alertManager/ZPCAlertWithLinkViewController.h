//
//  ZPCAlertWithLinkViewController.h
//  alertManager
//
//  Created by Noah on 2020/5/27.
//  Copyright © 2020 Noah Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPCAlertControllerManager.h"

@class ZPCAlertAction;
@interface ZPCAlertWithLinkViewController : UIViewController <ZPCAlertManageable>

@property( strong, nonatomic ) id tag;
@property( copy, nonatomic )   NSString *alertTitle;
@property( copy, nonatomic )   NSAttributedString *alertMessage;
@property( strong, nonatomic ) NSArray<NSDictionary *> *urlTitles; // [@{ @"url" : @"https://zoom.us", @"title" : @"Zoom" }]
@property( assign, nonatomic ) BOOL preferUseSafariViewController;
@property( assign, nonatomic ) CGFloat preferredWidth;
@property( assign, nonatomic ) BOOL alwaysShowButtonsVertically;

- (ZPCAlertAction *)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)())handler;
@property( strong, nonatomic ) ZPCAlertAction *preferredAction;

@end

