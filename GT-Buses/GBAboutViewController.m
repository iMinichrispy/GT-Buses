//
//  GBAboutViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 11/23/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBAboutViewController.h"

@interface GBAboutViewController ()

@end

@implementation GBAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillLayoutSubviews {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.view.bounds];
    
    // Label for vibrant text
//    UILabel *vibrantLabel = [[UILabel alloc] init];
//    [vibrantLabel setText:@"GT Buses"];
//    [vibrantLabel setFont:[UIFont systemFontOfSize:36.0f]];
//    [vibrantLabel sizeToFit];
//    [vibrantLabel setCenter: self.view.center];
//    
//    // Add label to the vibrancy view
//    [[vibrancyEffectView contentView] addSubview:vibrantLabel];
    
    
//    SBNotificationControlColorSettings *colorSettings = [SBNotificationControlColorSettings editButtonSettingsWithGraphicsQuality];
//    
//    SBNotificationVibrantButton *vibrantButton = [[SBNotificationVibrantButton alloc] initWithColorSettings:colorSettings];
//    [vibrantButton setTitle:@"Review App" forState:UIControlStateNormal];
//    vibrantButton.frame = CGRectMake(0, 0, 140, 35);
//    vibrantButton.center = self.view.center;
//    [[vibrancyEffectView contentView] addSubview:vibrantButton];
    
    UIButton *vibrantButton1 = [[UIButton alloc] init];
    [vibrantButton1 setTitle:@"Support" forState:UIControlStateNormal];
    vibrantButton1.backgroundColor = [UIColor redColor];
    vibrantButton1.layer.cornerRadius = 5;
    vibrantButton1.frame = CGRectMake(0, 0, 200, 50);
    vibrantButton1.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    [[vibrancyEffectView contentView] addSubview:vibrantButton1];
    
    // Add the vibrancy view to the blur view
    [[((UIVisualEffectView *)self.view) contentView] addSubview:vibrancyEffectView];
}

- (void)loadView {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    
    
    self.view = blurEffectView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
