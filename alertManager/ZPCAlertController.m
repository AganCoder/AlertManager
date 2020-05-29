//
//  ZPCAlertController.m
//  alertManager
//
//  Created by Noah on 2020/5/27.
//  Copyright © 2020 Noah Gao. All rights reserved.
//

#import "ZPCAlertController.h"

@interface ZPCAlertController ()

@property(strong, nonatomic) UIActivityIndicatorView *spinnerView;

@end

@implementation ZPCAlertController
{
    ZPCAlertPriority _priority;
}

@synthesize delegate;


+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    NSLog(@"init");

    ZPCAlertController *alert = [super alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    alert.priority = ZPCAlertPriorityNormal;
    return( alert );
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

- (void)setPriority:(ZPCAlertPriority)priority
{
    _priority = priority;
}

- (ZPCAlertPriority)priority
{
    return _priority;
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.delegate alertDidDisappear:self];
}

- (UIView *)findMessageLabel:(UIView *)view
{
    for( UIView *subview in view.subviews )
    {
        if( [subview isMemberOfClass:UILabel.class] )
        {
            UILabel *label = (UILabel *)subview;
            if( [label.text isEqualToString:self.message] )
                return( label );
        }
        else if( subview.subviews.count > 0 )
        {
            UIView *contentView = [self findMessageLabel:subview];
            if( contentView != nil )
                return( contentView );
        }
    }

    return( nil );
}

- (void)addSpinnerView
{
    if( self.spinnerView )  // already added
        return;

    self.message = @"\n";   // indicate message label

    self.spinnerView = [[UIActivityIndicatorView alloc] init];
    self.spinnerView.activityIndicatorViewStyle                = UIActivityIndicatorViewStyleGray;
    self.spinnerView.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *view = [self findMessageLabel:self.view];
    if( view )
    {
        view.isAccessibilityElement = NO;
        [view addSubview:self.spinnerView];

        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.spinnerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        centerXConstraint.active              = YES;

        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.spinnerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        centerYConstraint.active              = YES;

        [self.spinnerView startAnimating];
    }
}


@end
