//
//  ViewController.m
//  SmoothieShop
//
//  Created by Chaitanya Bagaria on 10/3/15.
//  Copyright © 2015 Bugs Labs. All rights reserved.
//

#import "ViewController.h"
#import <WePay/WePay.h>


@interface ViewController ()

@property (nonatomic, strong) WePay *wepay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize WePay Config with your clientId and environment
    NSString *clientId = @"171482";
    NSString *environment = kWPEnvironmentStage;
    WPConfig *config = [[WPConfig alloc] initWithClientId:clientId environment:environment];

    // Allow WePay to use location services
    config.useLocation = YES;

    // Initialize WePay
    self.wepay = [[WePay alloc] initWithConfig:config];

    // Do any additional setup after loading the view, typically from a nib.
    [self setupUserInterface];



}

- (void) setupUserInterface
{
    self.containerView.layer.borderWidth = 1.0;
    self.containerView.layer.cornerRadius = 8;

//    self.buyButton.layer.borderWidth = 1.0;
//    self.buyButton.layer.cornerRadius = 8;

    self.statusLabel.layer.borderWidth = 1.0;
    self.statusLabel.layer.cornerRadius = 8;

    self.statusLabel.layer.borderWidth = 1.0;
    self.statusLabel.layer.cornerRadius = 8;

    [self showStatus:@"Ready"];
}

- (void) showStatus:(NSString *)message
{
    self.statusLabel.text = message;
}

#pragma mark - WPCardReaderDelegateMethods

- (void) didReadPaymentInfo:(WPPaymentInfo *)paymentInfo
{
    // Print message to screen
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"didReadPaymentInfo: \n"];
    NSAttributedString *info = [[NSAttributedString alloc] initWithString:[paymentInfo description]
                                                               attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:0 blue:1 alpha:1]}
                                ];

    [str appendAttributedString:info];
//    [self consoleLog:str];

    // Change status label
    [self showStatus:@"Got payment info!"];
}

- (void) didFailToReadPaymentInfoWithError:(NSError *)error
{
    // Print message to screen
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"didFailToReadPaymentInfoWithError: \n"];
    NSAttributedString *info = [[NSAttributedString alloc] initWithString:[error localizedDescription]
                                                               attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:1 green:0 blue:0 alpha:1]}
                                ];

    [str appendAttributedString:info];

//    [self consoleLog:str];

    // Change status label
    [self showStatus:@"Card Reader error"];
}

- (void) cardReaderDidChangeStatus:(id)status
{
    // Print message to screen
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"cardReaderDidChangeStatus: "];
    NSAttributedString *info = [[NSAttributedString alloc] initWithString:[status description]
                                                               attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:0 blue:1 alpha:1]}
                                ];

    [str appendAttributedString:info];

//    [self consoleLog:str];

    // Change status label
    if (status == kWPCardReaderStatusNotConnected) {
        [self showStatus:@"Connect Card Reader"];
    } else if (status == kWPCardReaderStatusWaitingForSwipe) {
        [self showStatus:@"Swipe Card"];
    } else if (status == kWPCardReaderStatusSwipeDetected) {
        [self showStatus:@"Swipe Detected..."];
    } else if (status == kWPCardReaderStatusTokenizing) {
        [self showStatus:@"Tokenizing..."];
    } else if (status == kWPCardReaderStatusStopped) {
        [self showStatus:@"Card Reader Stopped"];
    } else {
        [self showStatus:[status description]];
    }
}

- (void) shouldResetCardReaderWithCompletion:(void (^)(BOOL))completion
{
    // Change this to YES if you want to reset the card reader
    completion(NO);
}

#pragma mark - WPTokenizationDelegate methods

- (void) paymentInfo:(WPPaymentInfo *)paymentInfo
         didTokenize:(WPPaymentToken *)paymentToken
{
    [self showStatus:@"Tokenized!"];

    // Print message to console
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"paymentInfo:didTokenize: \n"];
    NSAttributedString *info = [[NSAttributedString alloc] initWithString:[paymentToken description]
                                                               attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:0 blue:1 alpha:1]}
                                ];

    [str appendAttributedString:info];

//    [self consoleLog:str];
}

- (void) paymentInfo:(WPPaymentInfo *)paymentInfo
 didFailTokenization:(NSError *)error
{
    [self showStatus:@"Tokenization error"];

    // Print message to console
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"paymentInfo:didFailTokenization: \n"];
    NSAttributedString *info = [[NSAttributedString alloc] initWithString:[error localizedDescription]
                                                               attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:1 green:0 blue:0 alpha:1]}
                                ];

    [str appendAttributedString:info];

//    [self consoleLog:str];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
