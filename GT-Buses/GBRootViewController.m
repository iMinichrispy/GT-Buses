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
#import "MFSideMenu.h"
#import "GBConstants.h"
#import "GBColors.h"
#import "GBUserInterface.h"
#import "GBBuildingsViewController.h"
#import "GBBuilding.h"
#import "GBBuildingAnnotation.h"

#if DEBUG
#import "GBMapViewController+Private.h"
#endif

@interface GBRootViewController () <UISearchBarDelegate, GBBuidlingsDelegate> {
    NSString *_currentQuery;
}

@property (nonatomic, strong) GBMapViewController *mapViewController;
@property (nonatomic, strong) GBBuildingsViewController *buildingsController;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation GBRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapViewController = [[GBMapViewController alloc] init];
    _mapViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_mapViewController.view];
    
    NSMutableArray *constraints = [NSMutableArray new];
    UIView *mapViewControllerView = _mapViewController.view;
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapViewControllerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mapViewControllerView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapViewControllerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mapViewControllerView)]];
    [self.view addConstraints:constraints];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = NSLocalizedString(@"SEARCH_PLACEHOLDER", @"Placeholder text for search bar");
    _searchBar.delegate = self;
    
    self.menuContainerViewController.menuWidth = IS_IPAD ? kSideWidthiPad : kSideWidth;
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuStateEventOccurred:) name:MFSideMenuStateNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    
    self.navigationItem.leftBarButtonItem = [self aboutButton];
    self.navigationItem.rightBarButtonItem = [self searchButton];
    
#if DEFAULT_IMAGE
    self.title = @"";
#else
    self.title = NSLocalizedString(@"TITLE", @"Main Title");
#endif
    
#if DEBUG
    self.navigationController.toolbarHidden = NO;
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:_mapViewController action:@selector(resetBackend)];
    UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *partyItem = [[UIBarButtonItem alloc] initWithTitle:@"Party" style:UIBarButtonItemStylePlain target:_mapViewController action:@selector(toggleParty)];
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *updateStopsItem = [[UIBarButtonItem alloc] initWithTitle:@"Stops" style:UIBarButtonItemStylePlain target:_mapViewController action:@selector(updateStops)];
    self.toolbarItems = @[resetItem, flexibleSpace1, partyItem, flexibleSpace2, updateStopsItem];
    [self updateTintColor:nil];
#endif
}

- (void)updateTintColor:(NSNotification *)notification {
    [(GBNavigationController *)self.navigationController updateTintColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor controlTintColor];
#if DEBUG
    UIColor *tintColor = [UIColor appTintColor];
    if ([self.navigationController.toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.toolbar.barTintColor = tintColor;
        self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationController.toolbar.tintColor = tintColor;
    }
#endif
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuPanMode panMode = self.menuContainerViewController.menuState == MFSideMenuStateClosed ?  MFSideMenuPanModeNone: MFSideMenuPanModeCenterViewController;
    self.menuContainerViewController.panMode = panMode;
}

- (void)aboutPressed {
    MFSideMenuState state = self.menuContainerViewController.menuState == MFSideMenuStateClosed ? MFSideMenuStateLeftMenuOpen : MFSideMenuStateClosed;
    [self.menuContainerViewController setMenuState:state completion:NULL];
}

- (void)showSearchBar {
    self.navigationItem.prompt = NSLocalizedString(@"SEARCH_PROMPT", @"Displayed above search bar");
    self.navigationItem.titleView = _searchBar;
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:[self cancelButton] animated:YES];
    
    [_searchBar becomeFirstResponder];
}

- (UIBarButtonItem *)aboutButton {
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ABOUT_BUTTON", @"Button to open About screen") style:UIBarButtonItemStyleBordered target:self action:@selector(aboutPressed)];
    aboutButton.tintColor = [UIColor controlTintColor];
    return aboutButton;
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

#warning UIAccessibilityReduceTransparencyStatusDidChangeNotification

#pragma mark - Search

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
    
    [self.navigationItem setLeftBarButtonItem:[self aboutButton] animated:YES];
    [self.navigationItem setRightBarButtonItem:[self searchButton] animated:YES];
    
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

@end
