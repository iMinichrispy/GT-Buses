//
//  GBViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 1/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRootViewController.h"

@import MapKit;

#import "GBMapView.h"
#import "MFSideMenu.h"
#import "GBConstants.h"
#import "GBColors.h"
#import "GBUserInterface.h"
#import "GBBuildingsViewController.h"
#import "GBBuilding.h"
#import "GBBuildingAnnotation.h"

#warning posibly add in debug, do something w/ update tint color
#import "GBMapView+Private.h"

@interface GBRootViewController () <UISearchBarDelegate, GBBuidlingsDelegate>

@property (nonatomic, strong) GBMapView *mapView;
@property (nonatomic, strong) GBBuildingsViewController *buildingsController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *overlayButton;

@end

@implementation GBRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView = [[GBMapView alloc] init];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_mapView];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_mapView]|"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_mapView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_mapView]|"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_mapView)]];
    [self.view addConstraints:constraints];
    
    _buildingsController = [[GBBuildingsViewController alloc] init];
    _buildingsController.delegate = self;
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = @"Search";
    _searchBar.delegate = self;
    
    self.menuContainerViewController.menuWidth = IS_IPAD ? kSideWidthiPad : kSideWidth;
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuStateEventOccurred:) name:MFSideMenuStateNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.navigationItem.leftBarButtonItem = [self aboutButton];
    self.navigationItem.rightBarButtonItem = [self searchButton];
    
    
#if DEFAULT_IMAGE
    self.title = @"";
#else
    self.title = @"GT Buses";
#endif
    
#if DEBUG
    self.navigationController.toolbarHidden = NO;
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:_mapView action:@selector(resetBackend)];
    UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *partyItem = [[UIBarButtonItem alloc] initWithTitle:@"Party" style:UIBarButtonItemStylePlain target:_mapView action:@selector(toggleParty)];
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *updateStopsItem = [[UIBarButtonItem alloc] initWithTitle:@"Stops" style:UIBarButtonItemStylePlain target:_mapView action:@selector(updateStops)];
    self.toolbarItems = @[resetItem, flexibleSpace1, partyItem, flexibleSpace2, updateStopsItem];
    [self updateTintColor:nil];
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IS_IPAD) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    [_mapView performSelector:@selector(fixRegion) withObject:nil afterDelay:1];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [_mapView showUserLocation];
    [_mapView requestUpdate];
    [_mapView resetRefreshTimer];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [_mapView invalidateRefreshTimer];
    [_mapView hideUserLocation];
}

- (void)updateTintColor:(NSNotification *)notification {
    [(GBNavigationController *)self.navigationController updateTintColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor controlTintColor];
    [_mapView updateTintColor];
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
    self.navigationItem.prompt = @"Search for Building:";
    self.navigationItem.titleView = _searchBar;
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:[self cancelButton] animated:YES];
    
    [_searchBar becomeFirstResponder];
}

- (void)hideSearchBar {
    self.navigationItem.prompt = nil;
    self.navigationItem.titleView = nil;
    
    [self.navigationItem setLeftBarButtonItem:[self aboutButton] animated:YES];
    [self.navigationItem setRightBarButtonItem:[self searchButton] animated:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [GBBuildingAnnotation class]];
    NSArray *buildingAnnotations = [_mapView.mapView.annotations filteredArrayUsingPredicate:predicate];
    [_mapView.mapView removeAnnotations:buildingAnnotations];
    
    [self hideSearchResults];
}

- (UIBarButtonItem *)aboutButton {
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutPressed)];
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

#pragma mark - Search

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_mapView addSubview:_buildingsController.view];
    
    UIView *buildingsView = _buildingsController.view;
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[buildingsView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buildingsView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buildingsView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buildingsView)]];
    [self.view addConstraints:constraints];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText; {
    [_buildingsController setupForQuery:searchText];
}

- (void)hideSearchResults {
    [_buildingsController.view removeFromSuperview];
}

- (void)didSelectBuilding:(GBBuilding *)building {
    [_buildingsController.view removeFromSuperview];
    [_searchBar resignFirstResponder];
    
    GBBuildingAnnotation *annotation = [[GBBuildingAnnotation alloc] initWithBuilding:building];
    [_mapView.mapView addAnnotation:annotation];
    [_mapView.mapView selectAnnotation:annotation animated:YES];
}

@end
