//
//  GBToggleRoutesController.m
//  GT-Buses
//
//  Created by Alex Perez on 12/13/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBToggleRoutesController.h"

#import "GBConstants.h"
#import "GBRoute.h"
#import "GBColors.h"
#import "GBRouteCell.h"
#import "GBImage.h"
#import "NSUserDefaults+SharedDefaults.h"
#import "UITableViewController+StatusLabel.h"

static NSString *const GBRouteCellIdentifier = @"GBRouteCellIdentifier";

@interface GBToggleRoutesController () {
    BOOL _didToggleRoutes;
}

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSMutableDictionary *disabledRoutes;

@end

@implementation GBToggleRoutesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"TOGGLE_ROUTES", @"Toggle routes");
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    
    if ([self.tableView respondsToSelector:@selector(setTintColor:)]) {
        [self.tableView setTintColor:[UIColor appTintColor]];
    }
    [self.tableView registerClass:[GBRouteCell class] forCellReuseIdentifier:GBRouteCellIdentifier];
    
    NSUserDefaults *sharedDefaults = [NSUserDefaults sharedDefaults];
    _disabledRoutes = [[sharedDefaults objectForKey:GBSharedDefaultsDisabledRoutesKey] mutableCopy];
    if (!_disabledRoutes) {
        // TODO: This shouldn't ever be necessary
        _disabledRoutes = [NSMutableDictionary new];
    }
    
    NSArray *savedRoutes = [sharedDefaults objectForKey:GBSharedDefaultsRoutesKey];
    NSMutableArray *newRoutes = [NSMutableArray new];
    for (NSDictionary *dictionary in savedRoutes) {
        GBRoute *route = [dictionary toRoute];
        route.enabled = ![self routeDisabled:route];
        [newRoutes addObject:route];
    }
    _routes = newRoutes;
    
    if (![savedRoutes count]) {
        [self setStatus:NSLocalizedString(@"NO_SAVED_ROUTES", @"No saved routes")];
    }
}

- (BOOL)routeDisabled:(GBRoute *)route {
    return _disabledRoutes[route.tag] != nil;
}

- (void)dismiss:(id)sender {
    if (_didToggleRoutes) {
        [[NSUserDefaults sharedDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationDisabledRoutesDidChange object:nil];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_routes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GBRouteCell *cell = [tableView dequeueReusableCellWithIdentifier:GBRouteCellIdentifier forIndexPath:indexPath];
    
    GBRoute *route = _routes[indexPath.row];
    cell.titleLabel.text = route.title;
    cell.circleImageView.image = [UIImage circleRouteImageWithRoute:route];
    cell.accessoryType = (route.enabled) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GBRoute *route = _routes[indexPath.row];
    NSDictionary *routeDic = [route toDictionary];
    NSString *tag = routeDic[@"tag"];
    
    if (route.enabled && [self canDisableRoute]) {
        route.enabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        _disabledRoutes[tag] = routeDic;
        [self updateDisabledRoutes];
    } else if (!route.enabled && [self canEnableRoute]) {
        route.enabled = YES;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_disabledRoutes removeObjectForKey:tag];
        [self updateDisabledRoutes];
    }
}

- (void)updateDisabledRoutes {
    NSUserDefaults *sharedDefaults = [NSUserDefaults sharedDefaults];
    [sharedDefaults setObject:_disabledRoutes forKey:GBSharedDefaultsDisabledRoutesKey];
    _didToggleRoutes = YES;
}

- (BOOL)canDisableRoute {
    // Ensures at least one route remains selected
    return [_routes count] - ([_disabledRoutes count] + 1);
}

- (BOOL)canEnableRoute {
    // Limit the number of routes that can be enabled
    return ([_routes count] - [_disabledRoutes count]) < [[self class] maxNumRoutes];
}

+ (NSInteger)maxNumRoutes {
    // Calculate a reasonable maximum number of routes based on the device's smallest screen side
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float smallestLength = MIN(screenSize.width, screenSize.height);
    return roundf(.02107 * smallestLength + .21);
}

@end
