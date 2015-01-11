//
//  GBRootViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 1/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRootViewController.h"

@import MapKit;
@import iAd;

#import "GBMapViewController.h"
#import "GBConstants.h"
#import "GBColors.h"
#import "GBUserInterface.h"
#import "GBBuildingsViewController.h"
#import "GBBuilding.h"
#import "GBBuildingAnnotation.h"
#import "GBSettingsViewController.h"
#import "GBWindow.h"
#import "GBConfig.h"
#import "GBAgency.h"
#import "GBIAPHelper.h"

@interface GBRootViewController () <GBBuidlingsDelegate, ADBannerViewDelegate> {
    NSLayoutConstraint *_mapViewBottomContraint;
}

@property (nonatomic, strong) GBMapViewController *mapViewController;
@property (nonatomic, strong) UIVisualEffectView *overlayView;
@property (nonatomic, strong) GBSettingsViewController *settingsController;
@property (nonatomic, strong) ADBannerView *adBannerView;

@end

@implementation GBRootViewController

float const kSettingsViewAnimationSpeed = .2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapViewController = [[GBMapViewController alloc] init];
    _mapViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_mapViewController.view];
    [self addChildViewController:_mapViewController];
    
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *mapViewControllerView = _mapViewController.view;
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapViewControllerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mapViewControllerView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapViewControllerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mapViewControllerView)]];
    [self.view addConstraints:constraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agencyDidChange:) name:GBNotificationAgencyDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adsVisibleDidChange:) name:GBNotificationAdsVisibleDidChange object:nil];
    
    [self agencyDidChange:nil];
    [self adsVisibleDidChange:nil];
}

- (void)agencyDidChange:(NSNotification *)notifications {
    GBAgency *agency = [GBConfig sharedInstance].agency;
    [self dismissSearchBar];
    
    if (agency.searchEnabled) {
        self.navigationItem.rightBarButtonItem = [self settingsButton];
        self.navigationItem.leftBarButtonItem =  [self searchButton];
    } else {
        self.navigationItem.rightBarButtonItem = [self settingsButton];
        self.navigationItem.leftBarButtonItem =  nil;
    }
}

- (void)updateTintColor:(NSNotification *)notification {
    [(GBNavigationController *)self.navigationController updateTintColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor controlTintColor];
}

#pragma mark - Settings

- (void)settingsPressed {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    _settingsController = [[GBSettingsViewController alloc] init];
    _settingsController.view.frame = screenSize;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(effectViewTap:)];
    [_settingsController.view addGestureRecognizer:tapGesture];
    
    GBWindow *window = (GBWindow *)[[UIApplication sharedApplication] keyWindow];
    UIView *rootView = [window.subviews firstObject];
    [UIView animateWithDuration:kSettingsViewAnimationSpeed animations:^{
        rootView.transform = CGAffineTransformMakeScale(.9, .9);
        [window addSubview:_settingsController.view];
    } completion:^(BOOL finished) {
        window.settingsVisible = YES;
    }];
}

- (void)effectViewTap:(UITapGestureRecognizer *)recognizer {
    GBWindow *window = (GBWindow *)[[UIApplication sharedApplication] keyWindow];
    UIView *rootView = [window.subviews firstObject];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView animateWithDuration:kSettingsViewAnimationSpeed animations:^{
        rootView.transform = CGAffineTransformIdentity;
        [_settingsController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        window.settingsVisible = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:_settingsController];
        _settingsController = nil;
    }];
}

#pragma mark - Bar Buttons

- (UIBarButtonItem *)settingsButton {
    UIImage *settingsImage = [UIImage imageNamed:@"Settings"];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        settingsImage = [settingsImage imageWithColor:[UIColor whiteColor]];
    }
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:settingsImage style:UIBarButtonItemStylePlain target:self action:@selector(settingsPressed)];
    settingsButton.tintColor = [UIColor controlTintColor];
    return settingsButton;
}

- (UIBarButtonItem *)searchButton {
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchBar)];
    searchButton.tintColor = [UIColor controlTintColor];
    return searchButton;
}

- (UIBarButtonItem *)cancelButton {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissSearchBar)];
    cancelButton.tintColor = [UIColor controlTintColor];
    return cancelButton;
}

#pragma mark - Search

- (void)showSearchBar {
    self.navigationItem.prompt = NSLocalizedString(@"SEARCH_PROMPT", @"Displayed above search bar");
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:[self cancelButton] animated:YES];
    
    GBBuildingsViewController *buildingsController = [[GBBuildingsViewController alloc] init];
    buildingsController.delegate = self;
    
    // TODO: [Bug] After searchbar keyboard disappears on <iOS 7, it can't be selected again
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = NSLocalizedString(@"SEARCH_PLACEHOLDER", @"Placeholder text for search bar");
    searchBar.delegate = buildingsController;
    self.navigationItem.titleView = searchBar;
    
    if (ROTATION_ENABLED) {
        buildingsController.view.layer.cornerRadius = 5;
    }
    
    [_mapViewController.view addSubview:buildingsController.view];
    [_mapViewController addChildViewController:buildingsController];
    
    UIView *buildingsView = buildingsController.view;
    CGSize size = [self buildingSearchMaxViewSize];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[NSLayoutConstraint
                            constraintWithItem:buildingsView
                            attribute:NSLayoutAttributeWidth
                            relatedBy:NSLayoutRelationLessThanOrEqual
                            toItem:nil
                            attribute:0
                            multiplier:1
                            constant:size.width]];
    [constraints addObject:[NSLayoutConstraint
                            constraintWithItem:buildingsView
                            attribute:NSLayoutAttributeCenterX
                            relatedBy:NSLayoutRelationEqual
                            toItem:self.view
                            attribute:NSLayoutAttributeCenterX
                            multiplier:1
                            constant:0]];
    NSLayoutConstraint *leftHug = [NSLayoutConstraint
                                   constraintWithItem:buildingsView
                                   attribute:NSLayoutAttributeLeft
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeft
                                   multiplier:1
                                   constant:0];
    NSLayoutConstraint *rightHug = [NSLayoutConstraint
                                    constraintWithItem:buildingsView
                                    attribute:NSLayoutAttributeRight
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                    attribute:NSLayoutAttributeRight
                                    multiplier:1
                                    constant:0];
    NSLayoutConstraint *bottomHug = [NSLayoutConstraint
                                     constraintWithItem:buildingsView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                     constant:0];
    if (ROTATION_ENABLED) {
        leftHug.priority = UILayoutPriorityDefaultHigh;
        rightHug.priority = UILayoutPriorityDefaultHigh;
        
        if (IS_IPAD) {
            bottomHug.priority = UILayoutPriorityDefaultHigh;
            [constraints addObject:[NSLayoutConstraint
                                    constraintWithItem:buildingsView
                                    attribute:NSLayoutAttributeHeight
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                    attribute:0
                                    multiplier:1
                                    constant:size.height]];
        }
        
        if (IS_IPHONE_6_PLUS) {
            bottomHug.constant = -10;
        }
    }
    
    [constraints addObjectsFromArray:@[rightHug, leftHug, bottomHug]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buildingsView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buildingsView)]];
    [self.view addConstraints:constraints];
    
    [searchBar becomeFirstResponder];
}

- (CGSize)buildingSearchMaxViewSize {
    if (IS_IPHONE_6_PLUS) {
        return CGSizeMake(394.0, 394.0);
    }
    return CGSizeMake(540.0, 620.0);
}

- (void)dismissSearchBar {
    UIViewController *buildingsViewController = [_mapViewController.childViewControllers firstObject];
    if (buildingsViewController) {
        [buildingsViewController removeFromParentViewController];
        [buildingsViewController.view removeFromSuperview];
        self.navigationItem.prompt = nil;
        self.navigationItem.titleView = nil;
        
        [self.navigationItem setRightBarButtonItem:[self settingsButton] animated:YES];
        [self.navigationItem setLeftBarButtonItem:[self searchButton] animated:YES];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [GBBuildingAnnotation class]];
        NSArray *buildingAnnotations = [_mapViewController.mapView.annotations filteredArrayUsingPredicate:predicate];
        [_mapViewController.mapView removeAnnotations:buildingAnnotations];
    }
}

- (void)didSelectBuilding:(GBBuilding *)building {
    UIViewController *buildingsViewController = [_mapViewController.childViewControllers firstObject];
    buildingsViewController.view.hidden = YES;
    
    UISearchBar *searchBar = (UISearchBar *)self.navigationItem.titleView;
    [searchBar resignFirstResponder];
    searchBar.text = building.name;
    
    GBBuildingAnnotation *annotation = [[GBBuildingAnnotation alloc] initWithBuilding:building];
    [_mapViewController.mapView addAnnotation:annotation];
    [_mapViewController.mapView selectAnnotation:annotation animated:YES];
}

#pragma mark - Ads

- (void)adsVisibleDidChange:(NSNotification *)notification {
    GBConfig *sharedConfig = [GBConfig sharedInstance];
    if (sharedConfig.adsEnabled) {
        if (sharedConfig.adsVisible) {
            _adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
            _adBannerView.delegate = self;
            _adBannerView.hidden = YES;
            _adBannerView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:_adBannerView];
            
            NSMutableArray *constraints = [NSMutableArray new];
            double constant = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? 0.0 : 50.0; // No idea why this is necessary
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_adBannerView]-constant-|" options:0 metrics:@{@"constant":@(constant)} views:NSDictionaryOfVariableBindings(_adBannerView)]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_adBannerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_adBannerView)]];
            [self.view addConstraints:constraints];
        } else {
            [_adBannerView removeFromSuperview];
            _adBannerView = nil;
        }
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    banner.hidden = NO;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    banner.hidden = YES;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    [_mapViewController invalidateRefreshTimer];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    [_mapViewController resetRefreshTimer];
}

@end
