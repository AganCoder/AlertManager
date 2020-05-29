//
//  ZPCAlertWithLinkViewController.m
//  alertManager
//
//  Created by Noah on 2020/5/27.
//  Copyright © 2020 Noah Gao. All rights reserved.
//

#import "ZPCAlertWithLinkViewController.h"
#import <SafariServices/SafariServices.h>

#pragma mark - ZPCAlertWithLinkViewController

@interface ZPCAlertAction : NSObject

@property( copy, nonatomic )   NSString *title;
@property( assign, nonatomic ) UIAlertActionStyle style;
@property( copy, nonatomic )   void (^handler)();

@end

@implementation ZPCAlertAction

@end


@protocol ZPCAlertWithLinkViewDelegate <NSObject>

- (void)onClickURL:(NSString *)url;
- (void)onActionButtonTapped:(UIButton *)button;

@end

@interface ZPCAlertWithLinkView : UIView<UITextViewDelegate>

@property(strong, nonatomic) UIVisualEffectView *maskView;

@property(strong, nonatomic) UILabel    *titleLabel;
@property(strong, nonatomic) UITextView *messageTextView;
@property(strong, nonatomic) NSMutableArray<UIButton *> *buttons;
@property(strong, nonatomic) NSMutableArray<UIView *>   *buttonSeperators;
@property(strong, nonatomic) ZPCAlertAction *preferredAction;
@property(assign, nonatomic) CGFloat         width;
@property(assign, nonatomic) BOOL            alwaysShowButtonsVertically;
@property(weak, nonatomic)   id<ZPCAlertWithLinkViewDelegate> delegate;

- (void)createButtonsAndSeperators:(NSArray<ZPCAlertAction *> *)actions;
- (CGSize)viewContentSize;

@end

#define LinkAlertDefaultWidth        270
#define LinkAlertMaxHeight           688
#define LinkAlertTitleLeftPadding    16
#define LinkAlertTitleTopPadding     20
#define LinkAlertTitleMessagePadding 3
#define LinkAlertSeperatorLineWidth ( 1.0 / [UIScreen mainScreen].scale )
#define LinkAlertButtonHeight        44
#define LinkAlertButtonLeftPadding   12

@implementation ZPCAlertWithLinkView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
    {
        NSLog( @"++ " );

        self.backgroundColor = UIColorFromARGB( 204, 242, 242, 242 );

        _maskView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [self addSubview:_maskView];

        _titleLabel = [[UILabel alloc] init];
        {
            _titleLabel.font          = ZPC_FONT_BOLD_OF_SIZE( 17 );
            _titleLabel.textColor     = [UIColor blackColor];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.numberOfLines = 0;
        }
        [self addSubview:_titleLabel];

        _messageTextView = [[UITextView alloc] init];
        {
            _messageTextView.backgroundColor    = [UIColor clearColor];
            _messageTextView.textContainerInset = UIEdgeInsetsZero;
            _messageTextView.textContainer.lineFragmentPadding = 0;
            _messageTextView.delegate          = self;
            _messageTextView.selectable        = NO;
            _messageTextView.editable          = NO;
            _messageTextView.scrollEnabled     = NO;
            _messageTextView.dataDetectorTypes = UIDataDetectorTypeNone;
            if( @available(iOS 13.0, *) )
            {

            }
            else
            {
                _messageTextView.isAccessibilityElement = NO;
            }

            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( onTextViewTapped: )];
            [_messageTextView addGestureRecognizer:tapGesture];
        }
        [self addSubview:_messageTextView];
    }
    return( self );
}

- (void)dealloc
{
    NSLog( @"-- " );
}

- (void)createButtonsAndSeperators:(NSArray<ZPCAlertAction *> *)actions
{
    self.buttons = [[NSMutableArray alloc] init];
    self.buttonSeperators = [[NSMutableArray alloc] init];

    for( ZPCAlertAction *action in actions )
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = action.style;
        [button setTitle:action.title forState:UIControlStateNormal];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor        = 0.5;
        if( self.preferredAction )
        {
            button.titleLabel.font = ( action == self.preferredAction ) ? ZPC_FONT_BOLD_OF_SIZE( 17 ) : ZPC_FONT_OF_SIZE( 17 );
        }
        else
        {
            button.titleLabel.font = ( UIAlertActionStyleCancel == action.style ) ? ZPC_FONT_BOLD_OF_SIZE( 17 ) : ZPC_FONT_OF_SIZE( 17 );
        }
        UIColor *titleColor = ( UIAlertActionStyleDestructive == action.style ) ? UIColorFromRGB( 222, 40, 40 ) : UIColorFromRGB( 0, 122.4, 255 );
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector( onButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttons addObject:button];

        UIView *seperator = [[UIView alloc] init];
        seperator.backgroundColor = UIColorFromARGB(74, 60, 60, 67);
        [self addSubview:seperator];
        [self.buttonSeperators addObject:seperator];
    }
}

- (void)setPreferredAction:(ZPCAlertAction *)preferredAction
{
    _preferredAction = preferredAction;
    for( UIButton *button in self.buttons )
    {
        if( preferredAction )
        {
            button.titleLabel.font = ( [button.titleLabel.text isEqualToString:preferredAction.title] ) ? ZPC_FONT_BOLD_OF_SIZE( 17 ) : ZPC_FONT_OF_SIZE( 17 );
        }
        else
        {
            button.titleLabel.font = ( UIAlertActionStyleCancel == button.tag ) ? ZPC_FONT_BOLD_OF_SIZE( 17 ) : ZPC_FONT_OF_SIZE( 17 );
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize viewSize         = self.bounds.size;

    self.maskView.frame     = self.bounds;

    CGFloat titleLabelWidth = viewSize.width - LinkAlertTitleLeftPadding * 2;
    CGSize titleSize        = [self.titleLabel sizeThatFits:CGSizeMake( titleLabelWidth, CGFLOAT_MAX )];
    self.titleLabel.frame   = CGRectMake( LinkAlertTitleLeftPadding, LinkAlertTitleTopPadding, titleLabelWidth, titleSize.height );

    CGFloat buttonsHeight   = LinkAlertSeperatorLineWidth + LinkAlertButtonHeight;

    BOOL needShowButtonsVertically = [self needShowButtonsVertically];
    if( needShowButtonsVertically )
    {
        buttonsHeight = self.buttons.count * ( LinkAlertSeperatorLineWidth + LinkAlertButtonHeight );
    }
    CGFloat messageHeight = viewSize.height - CGRectGetMaxY( self.titleLabel.frame ) - LinkAlertTitleMessagePadding - LinkAlertTitleTopPadding - buttonsHeight;
    CGSize messageContentSize  = [self.messageTextView sizeThatFits:CGSizeMake( titleLabelWidth, CGFLOAT_MAX )];
    self.messageTextView.frame = CGRectMake( LinkAlertTitleLeftPadding, CGRectGetMaxY( self.titleLabel.frame ) + LinkAlertTitleMessagePadding, titleLabelWidth, messageHeight);
    self.messageTextView.scrollEnabled = ( messageContentSize.height > messageHeight );
    if( @available(iOS 13.0, *) )
    {
        ; // use system default behavior
    }
    else
    {
        self.messageTextView.accessibilityElements = [self buildMessageAccessibilityElements];
    }

    UIButton *cancelButton = nil;
    for( UIButton *button in self.buttons )
    {
        if( UIAlertActionStyleCancel == button.tag )
        {
            cancelButton = button;
            break;
        }
    }
    if( cancelButton )
    {
        [self.buttons removeObject:cancelButton];
        if( needShowButtonsVertically )
        {
            [self.buttons addObject:cancelButton];
        }
        else
        {
            [self.buttons insertObject:cancelButton atIndex:0];
        }
    }

    CGFloat fitsrtSeperatorTop = CGRectGetMaxY( self.messageTextView.frame ) + LinkAlertTitleTopPadding;
    if( needShowButtonsVertically )
    {
        for( NSInteger i = 0; i < (NSInteger)self.buttons.count; ++i )
        {
            UIView *seperator = self.buttonSeperators[i];
            seperator.frame   = CGRectMake( 0, fitsrtSeperatorTop + i * ( LinkAlertSeperatorLineWidth + LinkAlertButtonHeight ), viewSize.width, LinkAlertSeperatorLineWidth );
            UIButton *button  = self.buttons[i];
            button.frame      = CGRectMake( 0 , CGRectGetMaxY( seperator.frame ), viewSize.width, LinkAlertButtonHeight );
        }
    }
    else
    {
        if( self.buttons.count < 2 )
            return;

        UIView *firstSeperator = self.buttonSeperators[0];
        firstSeperator.frame = CGRectMake( 0, fitsrtSeperatorTop, viewSize.width, LinkAlertSeperatorLineWidth );
        UIButton *firstButton = self.buttons[0];
        firstButton.frame = CGRectMake( 0, CGRectGetMaxY( firstSeperator.frame ), ( viewSize.width - LinkAlertSeperatorLineWidth ) / 2.0, LinkAlertButtonHeight );

        UIView *secondSeperator = self.buttonSeperators[1];
        secondSeperator.frame = CGRectMake( CGRectGetMaxX( firstButton.frame ), CGRectGetMaxY( firstSeperator.frame ), LinkAlertSeperatorLineWidth, LinkAlertButtonHeight );
        UIButton *secondButton = self.buttons[1];
        secondButton.frame = CGRectMake( CGRectGetMaxX( secondSeperator.frame ), CGRectGetMaxY( firstSeperator.frame ), viewSize.width - CGRectGetMaxX( secondSeperator.frame ), LinkAlertButtonHeight );
    }
}

- (NSArray *)buildMessageAccessibilityElements
{
    NSMutableArray *elements = [[NSMutableArray alloc] init];

    UIAccessibilityElement *text = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self.messageTextView];
    {
        text.isAccessibilityElement = YES;
        text.accessibilityLabel     = self.messageTextView.attributedText.string;
        text.accessibilityFrame     = [self convertRect:self.messageTextView.frame toView:nil];
    }
    [elements addObject:text];

    __weak ZPCAlertWithLinkView *weakSelf = self;
    [self.messageTextView.attributedText enumerateAttribute:NSLinkAttributeName
                                                    inRange:NSMakeRange(0, self.messageTextView.attributedText.length)
                                                    options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                                 usingBlock:^(id value, NSRange range, BOOL *stop)
    {
        if( !value )
            return;

        NSAttributedString *attributedString = [weakSelf.messageTextView.attributedText attributedSubstringFromRange:range];

        UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:weakSelf.messageTextView];
        element.isAccessibilityElement  = YES;
        element.accessibilityLabel      = attributedString.string;
        element.accessibilityTraits     = UIAccessibilityTraitLink;

        NSRange glyphRange = [weakSelf.messageTextView.layoutManager glyphRangeForCharacterRange:range
                                                                            actualCharacterRange:nil];

        [weakSelf.messageTextView.layoutManager enumerateEnclosingRectsForGlyphRange:glyphRange
                                                            withinSelectedGlyphRange:glyphRange
                                                                     inTextContainer:weakSelf.messageTextView.textContainer
                                                                          usingBlock:^(CGRect rect, BOOL *stop)
        {
            element.accessibilityFrame = [weakSelf.messageTextView convertRect:rect toView:nil];
            *stop = YES;
        }];

        [elements addObject:element];
    }];

    return( elements );
}

- (BOOL)needShowButtonsVertically
{
    if( self.alwaysShowButtonsVertically )
        return( YES );

    if( 2 == self.buttons.count )
    {
        UIButton *firstButton   = self.buttons[0];
        UIButton *secondButton  = self.buttons[1];
        CGSize firstButtonSize  = [firstButton sizeThatFits:CGSizeMake( CGFLOAT_MAX, LinkAlertButtonHeight )];
        CGSize secondButtonSize = [secondButton sizeThatFits:CGSizeMake( CGFLOAT_MAX, LinkAlertButtonHeight )];
        CGFloat maxButtonWidth = MAX( firstButtonSize.width, secondButtonSize.width );
        return( maxButtonWidth > ( ( self.width - LinkAlertSeperatorLineWidth ) / 2.0 - 2 * LinkAlertButtonLeftPadding ) );
    }

    return( YES ); // 1 or 3+ buttons
}

- (CGSize)viewContentSize
{
    CGFloat totalHeight = 0;

    CGFloat titleLabelWidth = self.width - LinkAlertTitleLeftPadding * 2;
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake( titleLabelWidth, CGFLOAT_MAX )];
    totalHeight += ( LinkAlertTitleTopPadding + titleSize.height );

    CGSize messageSize = [self.messageTextView sizeThatFits:CGSizeMake( titleLabelWidth, CGFLOAT_MAX )];
    totalHeight += ( LinkAlertTitleMessagePadding + messageSize.height );

    totalHeight += LinkAlertTitleTopPadding;

    if( self.buttons.count > 0 )
    {
        if( [self needShowButtonsVertically] )
        {
            totalHeight += ( LinkAlertSeperatorLineWidth + LinkAlertButtonHeight ) * self.buttons.count;
        }
        else
        {
            totalHeight += ( LinkAlertSeperatorLineWidth + LinkAlertButtonHeight );
        }
    }

    totalHeight = MIN( totalHeight, LinkAlertMaxHeight );
    return( CGSizeMake( self.width, totalHeight ) );
}

- (void)onButtonTapped:(UIButton *)button
{
    [self.delegate onActionButtonTapped:button];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0))
{
    if( UIAccessibilityIsVoiceOverRunning() ) // for iOS 13
    {
        [self.delegate onClickURL:URL.absoluteString];
    }
    return( NO ); // disable system open safari
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if( UIAccessibilityIsVoiceOverRunning() ) // for iOS 13
    {
        [self.delegate onClickURL:URL.absoluteString];
    }
    return( NO ); // disable system open safari
}

// handle user tap gesture;
// for VoiceOver under iOS 13, shouldInteractWithURL will not callback, only callback onTextViewTapped;
// for VoiceOver on iOS 13+, usually will callback shouldInteractWithURL, then callback onTextViewTapped,
// but we presented view controller in shouldInteractWithURL, caused onTextViewTapped not callback;
- (void)onTextViewTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.messageTextView];

    __weak ZPCAlertWithLinkView *weakSelf = self;
    [self.messageTextView.attributedText enumerateAttribute:NSLinkAttributeName
                                                    inRange:NSMakeRange(0, self.messageTextView.attributedText.length)
                                                    options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                                 usingBlock:^(id value, NSRange range, BOOL *stop)
    {
        if( !value )
            return;

        NSRange glyphRange = [weakSelf.messageTextView.layoutManager glyphRangeForCharacterRange:range
                                                                            actualCharacterRange:nil];

        [weakSelf.messageTextView.layoutManager enumerateEnclosingRectsForGlyphRange:glyphRange
                                                            withinSelectedGlyphRange:glyphRange
                                                                     inTextContainer:weakSelf.messageTextView.textContainer
                                                                          usingBlock:^(CGRect rect, BOOL *stop)
        {
            if( CGRectContainsPoint( rect, point ) )
            {
                *stop = YES;
                [weakSelf.delegate onClickURL:value];
            }
        }];
    }];
}

@end

@interface ZPCAlertWithLinkViewController()<ZPCAlertWithLinkViewDelegate, SFSafariViewControllerDelegate>

@property(nonatomic, strong) NSMutableArray<ZPCAlertAction *> *actions;

@end

@implementation ZPCAlertWithLinkViewController
{
    ZPCAlertPriority _priority;
}

@synthesize delegate;

- (void)setPriority:(ZPCAlertPriority)priority
{
    _priority = priority;
}

- (ZPCAlertPriority)priority
{
    return _priority;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        NSLog( @"++ " );

        _preferredWidth = LinkAlertDefaultWidth;
        _actions        = [[NSMutableArray alloc] init];
        self.modalPresentationStyle = UIModalPresentationFormSheet;
#ifdef __IPHONE_13_0
        if( @available(iOS 13.0, *) )
            self.modalInPresentation  = YES;
#endif
    }
    return( self );
}

- (void)dealloc
{
    NSLog( @"-- " );
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.delegate alertDidDisappear:self];
}

- (ZPCAlertAction *)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)())handler
{
    if( 0 == title.length )
        return( nil );

    for( ZPCAlertAction *savedAction in self.actions )
    {
        if( [savedAction.title isEqualToString:title] ) // same action title
            return( nil );
    }

    ZPCAlertAction *action = [[ZPCAlertAction alloc] init];
    action.title   = title;
    action.style   = style;
    action.handler = handler;
    [self.actions addObject:action];

    return( action );
}

- (void)loadView
{
    ZPCAlertWithLinkView *view          = [[ZPCAlertWithLinkView alloc] init];
    view.titleLabel.text                = self.alertTitle;
    view.messageTextView.attributedText = self.alertMessage;
    view.width                          = self.preferredWidth;
    view.alwaysShowButtonsVertically    = self.alwaysShowButtonsVertically;
    [view createButtonsAndSeperators:self.actions];
    view.preferredAction = self.preferredAction;
    view.delegate        = self;
    self.view            = view;
}

- (CGSize)preferredContentSize
{
    ZPCAlertWithLinkView *view = (ZPCAlertWithLinkView *)self.view;
    return( [view viewContentSize] );
}

#pragma mark - ZPCAlertWithLinkViewDelegate

- (void)onClickURL:(NSString *)url
{
    if( url.length == 0 )
    {
        NSLog( @"clicked url is empty" );
        return;
    }

    if( self.presentedViewController ) // for case VoiceOver, click event will be triggered twice
        return;

    if( self.isBeingDismissed ) // for case click while alert is dismissing
        return;

    NSLog( @"user click hyperlink" );

    if( self.preferUseSafariViewController && [SFSafariViewController class] )
    {
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]
                                                                           entersReaderIfAvailable:NO];
        safariViewController.delegate                = self;
        safariViewController.modalPresentationStyle  = UIModalPresentationPageSheet;

        [self presentViewController:safariViewController animated:YES completion:^
        {
            NSLog( @"safari view controller is presented" );
        }];
    }
    else
    {
//        ZPCSimpleWebViewController *webViewController = [[ZPCSimpleWebViewController alloc] init];
//        NSString *title = nil;
//        for( NSDictionary *urlTitle in self.urlTitles )
//        {
//            if( [url isEqualToString:urlTitle[@"url"]] )
//            {
//                title = urlTitle[@"title"];
//                break;
//            }
//        }
//        webViewController.title          = title;
//        webViewController.url            = url;
//        webViewController.allowHyperlink = NO;
//        webViewController.delegate       = self;
//
//        UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:webViewController];
//        naviController.modalPresentationStyle  = UIModalPresentationPageSheet;
//        [self presentViewController:naviController animated:YES completion:^
//        {
//            NSLog( @"web view is presented" );
//        }];
    }
}

- (void)onActionButtonTapped:(UIButton *)button
{
    for( ZPCAlertAction *action in self.actions )
    {
        if( [action.title isEqualToString:button.titleLabel.text] )
        {
            if( !self.isBeingDismissed )
            {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:^
                {
                    NSLog( @"ZPCLinkAlert is dismissed" );
                }];
            }

            if( action.handler )
            {
                action.handler();
            }

            break;
        }
    }
}

#pragma mark - ZPCSimpleWebViewControllerDelegate

- (void)onSimpleWebViewControllerDone
{
    if( self.presentedViewController.isBeingDismissed )
        return;

    [self dismissViewControllerAnimated:YES completion:^
    {
        NSLog( @"web view is dismissed" );
    }];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    NSLog( @"safari view controller is dismissed" );
}

@end
