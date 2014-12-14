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

static NSString *const GBRouteCellIdentifier = @"GBRouteCellIdentifier";

@interface GBToggleRoutesController ()

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSMutableArray *disabledRoutes;

@end

@implementation GBToggleRoutesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"TOGGLE_ROUTES", @"Toggle routes");
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    
    [self.tableView setTintColor:[UIColor appTintColor]];
    [self.tableView registerClass:[GBRouteCell class] forCellReuseIdentifier:GBRouteCellIdentifier];
    
    NSUserDefaults *sharedDefaults = [NSUserDefaults sharedDefaults];
    _disabledRoutes = [[sharedDefaults objectForKey:GBSharedDefaultsDisabledRoutesKey] mutableCopy];
    if (!_disabledRoutes) {
        _disabledRoutes = [NSMutableArray new];
    }
    
    NSArray *savedRoutes = [sharedDefaults objectForKey:GBSharedDefaultsRoutesKey];
    NSMutableArray *newRoutes = [NSMutableArray new];
    for (NSDictionary *dictionary in savedRoutes) {
        GBRoute *route = [dictionary toRoute];
        route.enabled = ![self routeDisabled:route];
        [newRoutes addObject:route];
    }
    _routes = newRoutes;
}

- (BOOL)routeDisabled:(GBRoute *)route {
    for (NSDictionary *dictionary in _disabledRoutes) {
        if ([dictionary[@"tag"] isEqualToString:route.tag]) {
            return YES;
        }
    }
    return NO;
}

- (void)dismiss:(id)sender {
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
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    GBRoute *route = _routes[indexPath.row];
    NSDictionary *routeDic = [route toDictionary];
    
    if (route.enabled && [self canDisableRoute]) {
        route.enabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_disabledRoutes addObject:routeDic];
        [self updateDisabledRoutes];
    } else if (!route.enabled && [self canEnableRoute]) {
        route.enabled = YES;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_disabledRoutes removeObject:routeDic];
        [self updateDisabledRoutes];
    }
}

- (void)updateDisabledRoutes {
    NSUserDefaults *sharedDefaults = [NSUserDefaults sharedDefaults];
    [sharedDefaults setObject:_disabledRoutes forKey:GBSharedDefaultsDisabledRoutesKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationDisabledRoutesDidChange object:nil];
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
    // Calculate a reasonable maximum number of routes based on the device's smallest side
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float smallestLength = MIN(screenSize.width, screenSize.height);
    return roundf(.02107 * smallestLength + .21);
}

@end
