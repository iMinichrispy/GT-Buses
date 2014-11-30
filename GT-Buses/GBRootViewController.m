//
//  GBViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 1/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRootViewController.h"

@import MapKit;

#import "GBMapViewController.h"
#import "GBConstants.h"
#import "GBColors.h"
#import "GBUserInterface.h"
#import "GBBuildingsViewController.h"
#import "GBBuilding.h"
#import "GBBuildingAnnotation.h"
#import "GBSettingsViewController.h"
#import "GBWindow.h"

@interface GBRootViewController () <UISearchBarDelegate, GBBuidlingsDelegate> {
    NSString *_currentQuery;
}

@property (nonatomic, strong) GBMapViewController *mapViewController;
@property (nonatomic, strong) GBBuildingsViewController *buildingsController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIVisualEffectView *overlayView;
@property (nonatomic, strong) GBSettingsViewController *settingsController;

@end

@implementation GBRootViewController

float const kAboutViewAnimationSpeed = .2;

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
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = NSLocalizedString(@"SEARCH_PLACEHOLDER", @"Placeholder text for search bar");
    _searchBar.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reduceTransparencyDidChange:) name:UIAccessibilityReduceTransparencyStatusDidChangeNotification object:nil];
    
    self.navigationItem.rightBarButtonItem = [self settingsButton];
    
#if !DEFAULT_IMAGE
    self.title = NSLocalizedString(@"TITLE", @"Main Title");
#endif
}

- (void)setSearchEnaled:(BOOL)searchEnaled {
    if (_searchEnaled != searchEnaled) {
        _searchEnaled = searchEnaled;
        self.navigationItem.leftBarButtonItem = (searchEnaled) ? [self searchButton] : nil;
    }
}

- (void)updateTintColor:(NSNotification *)notification {
    [(GBNavigationController *)self.navigationController updateTintColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor controlTintColor];
}

- (void)settingsPressed {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    _settingsController = [[GBSettingsViewController alloc] init];
    _settingsController.view.frame = screenSize;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(effectViewTap:)];
    [_settingsController.view addGestureRecognizer:tapGesture];
    
    GBWindow *window = (GBWindow *)[[UIApplication sharedApplication] keyWindow];
    UIView *rootView = [window.subviews firstObject];
    [UIView animateWithDuration:kAboutViewAnimationSpeed animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
    [UIView animateWithDuration:kAboutViewAnimationSpeed animations:^{
        rootView.transform = CGAffineTransformIdentity;
        [_settingsController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        window.settingsVisible = NO;
        _settingsController = nil;
    }];
}

- (UIBarButtonItem *)settingsButton {
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsPressed)];
    settingsButton.tintColor = [UIColor controlTintColor];
    return settingsButton;
}

- (UIBarButtonItem *)searchButton {
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchBar)];
    searchButton.tintColor = [UIColor controlTintColor];
    return searchButton;
}

- (UIBarButtonItem *)cancelButton {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideSearchBar)];
    cancelButton.tintColor = [UIColor controlTintColor];
    return cancelButton;
}

#pragma mark - Search

- (void)showSearchBar {
    self.navigationItem.prompt = NSLocalizedString(@"SEARCH_PROMPT", @"Displayed above search bar");
    self.navigationItem.titleView = _searchBar;
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:[self cancelButton] animated:YES];
    
    [_searchBar becomeFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _searchBar.text = (_currentQuery) ? _currentQuery : @"";
    _buildingsController.view.hidden = NO;
    
    if (!_buildingsController) {
        _buildingsController = [[GBBuildingsViewController alloc] init];
        _buildingsController.delegate = self;
        
        [_mapViewController.view addSubview:_buildingsController.view];
        
        UIView *buildingsView = _buildingsController.view;
        CGSize size = [self buildingSearchMaxViewSize];
        
        // Constraints that ensure search doesn't take up the whole screen on devices with larger displays
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
            _buildingsController.view.layer.cornerRadius = 5;
            
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
    }
}

- (CGSize)buildingSearchMaxViewSize {
    if (IS_IPHONE_6_PLUS) {
        return CGSizeMake(394.0, 394.0);
    }
    return CGSizeMake(540.0, 620.0);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText; {
    [_buildingsController setupForQuery:searchText];
    _currentQuery = searchText;
}

- (void)hideSearchBar {
    _buildingsController.view.hidden = YES;
    
    self.navigationItem.prompt = nil;
    self.navigationItem.titleView = nil;
    
    [self.navigationItem setRightBarButtonItem:[self settingsButton] animated:YES];
    [self.navigationItem setLeftBarButtonItem:[self searchButton] animated:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [GBBuildingAnnotation class]];
    NSArray *buildingAnnotations = [_mapViewController.mapView.annotations filteredArrayUsingPredicate:predicate];
    [_mapViewController.mapView removeAnnotations:buildingAnnotations];
    
    _searchBar.text = @"";
    _currentQuery = @"";
    [_buildingsController setupForQuery:@""];
}

- (void)didSelectBuilding:(GBBuilding *)building {
    _buildingsController.view.hidden = YES;
    [_searchBar resignFirstResponder];
    _searchBar.text = building.name;
    
    GBBuildingAnnotation *annotation = [[GBBuildingAnnotation alloc] initWithBuilding:building];
    [_mapViewController.mapView addAnnotation:annotation];
    [_mapViewController.mapView selectAnnotation:annotation animated:YES];
}

- (void)reduceTransparencyDidChange:(NSNotification *)notification {
    // Since buildings controller uses a blur effect, set it to nil so that it is re-initialized the next time the search button is pressed. (The buildings controller initializer accounts for the reduce transparency accessibility setting).
    [self hideSearchBar];
    _buildingsController = nil;
}

@end
