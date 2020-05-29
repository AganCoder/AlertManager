//
//  ViewController.m
//  alertManager
//
//  Created by Noah on 2020/5/27.
//  Copyright © 2020 Noah Gao. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "ZPCAlertController.h"
#import "ZPCAlertControllerManager.h"
#import "ZPCAlertWithLinkViewController.h"

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

@end

@implementation Person

@end

@interface ViewController ()

@property (nonatomic, weak) UIAlertController *alert;

@property (nonatomic, strong) Person *p;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    Person *p = [[Person alloc] init];
    p.name = @"1111";

    self.p = p;
    [p addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];

    // Do any additional setup after loading the view.
}
- (IBAction)presente:(id)sender {

//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Title" message:@"Message" preferredStyle:UIAlertControllerStyleAlert];
//
//    [alert addObserver:self forKeyPath:@"isBeingDismissed" options:NSKeyValueObservingOptionNew context:NULL];
//    [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
//
//    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
//    ;

    [self addObserver:self forKeyPath:@"presentedViewController" options:NSKeyValueObservingOptionNew context:NULL];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SecondViewController *alert = [sb instantiateViewControllerWithIdentifier:@"SecondViewController"];
    [alert addObserver:self forKeyPath:@"beingDismissed" options:NSKeyValueObservingOptionNew context:NULL];

    [self presentViewController:alert animated:true completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@", change);

    if ([keyPath isEqualToString: @"isBeingDismissed"]) {
        NSLog(@"%@", change);
    }
}

- (IBAction)dismiss:(id)sender {
}

- (IBAction)test:(UIButton *)sender {
    int type = [sender.titleLabel.text intValue];

    NSLog(@"%zd", type);

    [self onUnitTestAlertControllerManager:type];
}



- (void)onUnitTestAlertControllerManager:(int)type
{
    ZPCAlertController *normalAlert_0 = [ZPCAlertController alertControllerWithTitle:@"normalAlert_0" message:@"N_000" preferredStyle:UIAlertControllerStyleAlert];
    [normalAlert_0 addAction:[UIAlertAction actionWithTitle:@"N_000" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"normalAlert_0 clicked");
    }]];

    ZPCAlertController *normalAlert_1 = [ZPCAlertController alertControllerWithTitle:@"normalAlert_1" message:@"N_111" preferredStyle:UIAlertControllerStyleAlert];
    [normalAlert_1 addAction:[UIAlertAction actionWithTitle:@"N_111" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"normalAlert_1 clicked");
    }]];

    ZPCAlertController *normalAlert_2 = [ZPCAlertController alertControllerWithTitle:@"normalAlert_2" message:@"N_222" preferredStyle:UIAlertControllerStyleAlert];
    [normalAlert_2 addAction:[UIAlertAction actionWithTitle:@"N_222" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"normalAlert_2 clicked");
    }]];

    ZPCAlertController *highAlert_1 = [ZPCAlertController alertControllerWithTitle:@"recordingConsent_1" message:@"H_111" preferredStyle:UIAlertControllerStyleAlert];
    highAlert_1.priority = ZPCAlertPriorityHigh;
    [highAlert_1 addAction:[UIAlertAction actionWithTitle:@"H_111" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"highAlert_1 clicked");
    }]];

    ZPCAlertController *highAlert_2 = [ZPCAlertController alertControllerWithTitle:@"recordingConsent_2" message:@"H_222" preferredStyle:UIAlertControllerStyleAlert];
    highAlert_2.priority = ZPCAlertPriorityHigh;
    [highAlert_2 addAction:[UIAlertAction actionWithTitle:@"H_222" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"highAlert_2 clicked");
    }]];

    // linkAlert
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:@"By continuing to be in the meeting, you are consenting to be recorded.By continuing to be in the meeting, you are consenting to be recorded.\n"];
    NSAttributedString *attributeLink = [[NSAttributedString alloc] initWithString:@"Recording Policy"
                                                                        attributes:@{NSLinkAttributeName : @"https://zoom.us"}];
    [message appendAttributedString:attributeLink];
    [message addAttribute:NSFontAttributeName value:ZPC_FONT_OF_SIZE( 13 ) range:NSMakeRange(0, message.length)];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing         = 10;
    paragraphStyle.lineHeightMultiple       = 1.03;
    [message addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, message.length)];

    ZPCAlertWithLinkViewController *linkAlert = [[ZPCAlertWithLinkViewController alloc] init];
    linkAlert.alertTitle = @"This meeting is being recorded";;
    linkAlert.alertMessage = message;
    linkAlert.urlTitles = @[ @{ @"url": @"https://zoom.us", @"title" : @"Zoom" } ];
    linkAlert.preferredWidth = 378;
    linkAlert.alwaysShowButtonsVertically = YES;

    ZPCAlertAction *defaultAction = [linkAlert addActionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^
    {
        NSLog( @"Default is tapped" );
    }];
    ZPCAlertAction *cancelAction = [linkAlert addActionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^
    {
        NSLog( @"Cancel is tapped" );
    }];
    ZPCAlertAction *destructiveAction = [linkAlert addActionWithTitle:@"Destructive" style:UIAlertActionStyleDestructive handler:^
    {
        NSLog( @"Destructive is tapped" );
    }];
    linkAlert.preferredAction = defaultAction;
//    linkAlert.preferredAction = cancelAction;
//    linkAlert.preferredAction = destructiveAction;

    switch( type )
    {
        case 0: // present multiple normal alert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_1];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_2];
        }
        break;

        case 1: // present normal alert then high-priority alert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_1];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_2];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:highAlert_1];
        }
        break;

        case 2: // present high-priority alert then normal alert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:highAlert_1];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_1];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_2];
        }
        break;

        case 3: // mix present normal and high-priority alert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:highAlert_1];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_1];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:highAlert_2];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_2];
        }
        break;

        case 4: // presnet one alert then dismiss it
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:normalAlert_0];
            });
        }
        break;

        case 5: // present some alert then dismiss the showing one
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_1];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_2];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:normalAlert_2];
            });
        }
        break;

        case 6: // present some alerts then dismiss the not-showing one
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_1];
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_2];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:normalAlert_1];
            });
        }
        break;

        case 7: // present - dismiss - present same alert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:normalAlert_0];
                [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            });
        }
        break;

                // 这个 case 不会自动的去dismiss
    
        case 8: // present - dismiss - present - dismiss same alert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:normalAlert_0];
                [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:normalAlert_0];
            });
        }
        break;

        case 9: // present - dismiss - present another alert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:normalAlert_0];
                [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_1];
            });
        }
        break;

        case 10: // dismiss one not be presented
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:normalAlert_1];
            });
        }
        break;

        case 11: // present - dismiss LinkAlert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:linkAlert];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] dismissAlertController:linkAlert];
            });
        }
        break;

        case 12: // mix present linkAlert and common alert
        {
            [[ZPCAlertControllerManager sharedInstance] presentAlertController:linkAlert];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
            {
                [[ZPCAlertControllerManager sharedInstance] presentAlertController:normalAlert_2];
            });
        }
        break;
    }
}



//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.p.name = [NSString stringWithFormat:@"%d", arc4random() % 10];
//}
@end
