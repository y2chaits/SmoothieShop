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
@property (nonatomic, strong) NSString *environment;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *accountId;

@property (nonatomic, assign) double amount;

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *buyButton;
@property (nonatomic, weak) IBOutlet UISegmentedControl *amountSelector;


@end

static NSString * const WEPAY_API_VERSION = @"2015-09-09";

#define SETTINGS_CLIENT_ID_KEY @"settingClientId"
#define SETTINGS_ENVIRONMENT_KEY @"settingEnvironment"
#define SETTINGS_ACCESS_TOKEN_KEY @"settingAccessToken"
#define SETTINGS_ACCOUNT_ID_KEY @"settingAccountId"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchSettings];

    // Initialize WePay Config with your clientId and environment
    WPConfig *config = [[WPConfig alloc] initWithClientId:self.clientId
                                              environment:self.environment];

    // Allow WePay to use location services
    config.useLocation = YES;

    // always keep swiper on
    config.restartCardReaderAfterGeneralError = YES;
    config.restartCardReaderAfterOtherErrors = NO;
    config.restartCardReaderAfterSuccess = NO;

    // Initialize WePay
    self.wepay = [[WePay alloc] initWithConfig:config];

    // Do any additional setup after loading the view, typically from a nib.
    [self setupUserInterface];
}

- (void) fetchSettings
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    // fetch client id
    self.clientId = [[NSUserDefaults standardUserDefaults] stringForKey:SETTINGS_CLIENT_ID_KEY];
    if (self.clientId == nil || [self.clientId isEqualToString:@""]) {
        self.clientId = @"171482";
        [[NSUserDefaults standardUserDefaults] setObject:self.clientId forKey:SETTINGS_CLIENT_ID_KEY];
    }

    // fetch environment
    self.environment = [[NSUserDefaults standardUserDefaults] stringForKey:SETTINGS_ENVIRONMENT_KEY];
    if (self.environment == nil || [self.environment isEqualToString:@""]) {
        self.environment = kWPEnvironmentStage;
        [[NSUserDefaults standardUserDefaults] setObject:self.environment forKey:SETTINGS_ENVIRONMENT_KEY];
    }

    // fetch account id
    self.accountId = [[NSUserDefaults standardUserDefaults] stringForKey:SETTINGS_ACCOUNT_ID_KEY];
    if (self.accountId == nil || [self.accountId isEqualToString:@""]) {
        self.accountId = @"";
        [[NSUserDefaults standardUserDefaults] setObject:self.accountId forKey:SETTINGS_ACCOUNT_ID_KEY];
    }

    // fetch access token
    self.accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:SETTINGS_ACCESS_TOKEN_KEY];
    if (self.accessToken == nil || [self.accessToken isEqualToString:@""]) {
        self.accessToken = @"";
        [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:SETTINGS_ACCESS_TOKEN_KEY];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) setupUserInterface
{
    self.containerView.layer.borderWidth = 1.0;
    self.containerView.layer.cornerRadius = 8;

    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.cornerRadius = 8;

    self.statusLabel.layer.borderWidth = 1.0;
    self.statusLabel.layer.cornerRadius = 8;

    self.statusLabel.layer.borderWidth = 1.0;
    self.statusLabel.layer.cornerRadius = 8;

    [self showStatus:@"Ready"];
    [self enableBuyButton:YES];
    self.amount = 5;
}

- (void) showStatus:(NSString *)message
{
    self.statusLabel.text = message;
}

-(IBAction) segmentedControlIndexChanged{
    switch (self.amountSelector.selectedSegmentIndex) {
        case 0:
            self.amount = 5;
            [self enableBuyButton:YES];
            break;
        case 1:
            self.amount = 10;
            [self enableBuyButton:YES];
            break;
        case 2:
            self.amount = 15;
            [self enableBuyButton:YES];
            break;
        case 3:
            self.amount = 20;
            [self enableBuyButton:YES];
            break;

        default:
            self.amount = 0;
            [self enableBuyButton:NO];
            break;
    }
}

- (void) enableBuyButton:(BOOL)shouldEnable
{
    self.buyButton.enabled = shouldEnable;
}

- (void) enableAmountSelector:(BOOL)shouldEnable
{
    self.amountSelector.enabled = shouldEnable;
}


- (IBAction) buyButtonPressed:(id)sender
{
    // disable selector and buy button
    [self enableAmountSelector:NO];
    [self enableBuyButton:NO];

    // Change status label
    [self showStatus:@"Please wait..."];

    // Make WePay API call
    [self.wepay startCardReaderForTokenizingWithCardReaderDelegate:self
                                              tokenizationDelegate:self];
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

    // Change status label
    [self showStatus:@"Got payment info"];
}

- (void) didFailToReadPaymentInfoWithError:(NSError *)error
{
    NSString *str = [NSString stringWithFormat:@"error: %@", [error localizedDescription]];
    [self showStatus:str];

    if (error.code == -10016 || error.code == 10016) {
        // do nothing, will restart
    } else {
        // wont restart, so enable buttons
        [self enableAmountSelector:YES];
        [self enableBuyButton:YES];
    }
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
        // dont show this message
        //[self showStatus:@"Card Reader Stopped"];
    } else {
        [self showStatus:[status description]];
    }
}

#pragma mark - WPTokenizationDelegate methods

- (void) paymentInfo:(WPPaymentInfo *)paymentInfo
         didTokenize:(WPPaymentToken *)paymentToken
{
    [self showStatus:[NSString stringWithFormat:@"Tokenized, charging $%d", (int)self.amount]];

    [self checkoutWithToken:paymentToken];
}

- (void) paymentInfo:(WPPaymentInfo *)paymentInfo
 didFailTokenization:(NSError *)error
{
    NSString *str = [NSString stringWithFormat:@"error: %@", [error localizedDescription]];
    [self showStatus:str];

    [self enableAmountSelector:YES];
    [self enableBuyButton:YES];
}

- (void) checkoutWithToken:(WPPaymentToken *)paymentToken
{
    [self checkoutCreate:[self createCheckoutRequestParamsForToken:paymentToken]
            successBlock:^(NSDictionary * returnData) {
                [self showStatus:@"Checkout completed!"];
                [self enableAmountSelector:YES];
                [self enableBuyButton:YES];
            }
            errorHandler:^(NSError * error) {
                NSString *str = [NSString stringWithFormat:@"error: %@", [error localizedDescription]];
                [self showStatus:str];
                [self enableAmountSelector:YES];
                [self enableBuyButton:YES];
            }
     ];
}

- (NSDictionary *) createCheckoutRequestParamsForToken:(WPPaymentToken *)paymentToken
{
    NSDictionary *requestParams = @{
                                    @"account_id":self.accountId,
                                    @"short_description":@"Smoothie Shop",
                                    @"type":@"goods",
                                    @"amount":@(self.amount),
                                    @"currency":@"USD",
                                    @"fee": @{
                                                @"app_fee": @0,
                                                @"fee_payer": @"payee"
                                            },
                                    @"payment_method": @{
                                            @"type":@"credit_card",
                                            @"credit_card": @{
                                                    @"id": paymentToken.tokenId
                                                    }
                                            }
                                    };

    return requestParams;


}



- (void) checkoutCreate:(NSDictionary *) params
           successBlock:(void (^)(NSDictionary * returnData)) successHandler
           errorHandler:(void (^)(NSError * error)) errorHandler
{
    [self makeRequestToEndPoint:[self apiUrlWithEndpoint:@"checkout/create"]
                             values:params
                        accessToken:self.accessToken
                       successBlock:successHandler
                       errorHandler:errorHandler
     ];
}


#pragma mark API URL helper

// Returns an NSURL for API Call Endpoint
- (NSURL *) apiUrlWithEndpoint: (NSString *) endpoint
{
    NSString *serverUrl = nil;
    // Use environment config to set the endpoint
    if ([kWPEnvironmentStage compare:self.environment options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        serverUrl = @"https://stage.wepayapi.com/v2/";
    } else if ([kWPEnvironmentProduction compare:self.environment options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        serverUrl = @"https://wepayapi.com/v2/";
    } else {
        // Use @"https://vm.wepay.com/v2/" for vm
        serverUrl = self.environment;
    }


    return [[NSURL URLWithString: [NSString stringWithFormat: @"%@", serverUrl]] URLByAppendingPathComponent: endpoint];
}

#pragma mark HTTP Call handlers

- (void) makeRequestToEndPoint: (NSURL *) endpoint
                        values: (NSDictionary *) params
                   accessToken: (NSString *) accessToken
                  successBlock: (void (^)(NSDictionary * returnData)) successHandler
                  errorHandler: (void (^)(NSError * error)) errorHandler
{

    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL: endpoint];

    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"charset" forHTTPHeaderField:@"utf-8"];
    [request setValue:WEPAY_API_VERSION forHTTPHeaderField:@"Api-Version"];

    [request setValue: [NSString stringWithFormat: @"Smoothie Shop iOS"] forHTTPHeaderField:@"User-Agent"];

    // Set access token
    if(accessToken != nil) {
        [request setValue: [NSString stringWithFormat: @"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    }

    NSError *parseError = nil;

    // Get json from nsdictionary parameter
    NSData *requestData = [NSJSONSerialization dataWithJSONObject: params options: kNilOptions error: &parseError];
    [request setHTTPBody: requestData];

    if (parseError) {
        errorHandler(parseError);
    } else {
        NSOperationQueue *queue = [NSOperationQueue mainQueue];

        [NSURLConnection sendAsynchronousRequest: request
                                           queue: queue
                               completionHandler:^(NSURLResponse *response, NSData  *data, NSError * requestError) {
                                   // Process response from server.
                                   [self processResponse:response data: data error: requestError successBlock:successHandler errorHandler: errorHandler];

                               }];
    }
}

/**
 *  Processes Request Response
 *
 *  @param response     The NSURLResponse for the http request
 *  @param data         The NSData returned by the request
 *  @param error        The NSError returned by the request
 *  @param successBlock The success block to be called if the request succeeded
 *  @param errorHandler The error block to be called if the request failed
 */
- (void) processResponse: (NSURLResponse *) response
                    data: (NSData *) data
                   error: (NSError *) error
            successBlock: (void (^)(NSDictionary * returnData)) successHandler
            errorHandler: (void (^)(NSError * error))  errorHandler
{
    // extract dictionary from raw data
    NSDictionary * dictionary = nil;
    if([data length] >= 1) {
        dictionary = [NSJSONSerialization JSONObjectWithData: data options: kNilOptions error: nil];
    }

#ifdef DEBUG
    // Log response only when in debug builds
    NSLog(@"[WPClient] error: %@, response: %@, data: %@",error,response, dictionary);
#endif

    if (dictionary != nil && error == nil) {
        // no error reported by api

        // get status code
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

        // if status code is 200, return success, else return error
        if (statusCode == 200) {
            successHandler(dictionary);
        } else {
            errorHandler([self errorWithApiResponseData:dictionary]);
        }
    } else if (dictionary != nil && error != nil) {
        // api returned error, extract and send it
        errorHandler([self errorWithApiResponseData:dictionary]);
    } else if (dictionary == nil && error == nil) {
        // if no response, return error
        errorHandler([self errorWithApiResponseData:dictionary]);
    } else if (error != nil) {
        // if the request returned an error, pass it on
        errorHandler(error);
    }
}



- (NSError *) errorWithApiResponseData:(NSDictionary *)data;
{
    NSInteger errorCode;
    NSString * errorText;
    NSString * errorCategory;

    // get error code
    if ([data objectForKey: @"error_code"] != (id)[NSNull null]) {
        errorCode = [[data objectForKey: @"error_code"] intValue];
    } else if (data == nil) {
        // This should not happen, but we handle it gracefully
        errorCode = 1;
    }  else {
        // This should not happen
        errorCode = -1;

        // Log unknown error only when in debug builds
        NSLog(@"[Smoothie Shop] unknown api error: %@", data);
    }

    // get error text
    if ([data objectForKey: @"error_description"] != (id)[NSNull null] &&
        [[data objectForKey: @"error_description"] length]) {
        errorText = [data objectForKey: @"error_description"];
    } else if (data == nil) {
        // This should not happen, but we handle it gracefully
        errorText = @"No data returned";
    } else {
        // This should really not happen
        errorText = @"Unexpected error";
    }

    // get error category
    if ([data objectForKey: @"error"] != (id)[NSNull null] &&
        [[data objectForKey: @"error"] length]) {
        errorCategory = [data objectForKey: @"error"];
    } else {
        // This should not happen, but we handle it gracefully
        errorCategory = @"WPErrorCategoryNone";
    }

    NSMutableDictionary * details = [NSMutableDictionary dictionary];
    [details setValue: errorText forKey: NSLocalizedDescriptionKey];
    [details setValue: errorCategory forKey: @"WPErrorCategoryKey"];

    return [NSError errorWithDomain:@"smoothie" code:errorCode userInfo:details];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
