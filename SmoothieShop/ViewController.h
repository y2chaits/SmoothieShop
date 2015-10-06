//
//  ViewController.h
//  SmoothieShop
//
//  Created by Chaitanya Bagaria on 10/3/15.
//  Copyright © 2015 Bugs Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WePay/WePay.h"

@interface ViewController : UIViewController <WPCardReaderDelegate, WPTokenizationDelegate>

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *buyButton;


@end

