//
//  ZPCAlertController.h
//  alertManager
//
//  Created by Noah on 2020/5/27.
//  Copyright © 2020 Noah Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPCAlertControllerManager.h"

@interface ZPCAlertController : UIAlertController <ZPCAlertManageable>

@property( strong, nonatomic ) id tag;

- (void)addSpinnerView; // replaces message

@end

