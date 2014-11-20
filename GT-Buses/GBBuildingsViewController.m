//
//  GBBuildingsViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBuildingsViewController.h"

#import "GBRequestHandler.h"
#import "GBConstants.h"
#import "GBBuilding.h"

@interface GBBuildingsViewController () <RequestHandlerDelegate>

@end

@implementation GBBuildingsViewController

static NSString * const GBBuildingCellIdentifier = @"GBBuildingCellIdentifier";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:GBBuildingCellIdentifier];
    
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBRequestBuildingsTask delegate:self];
    [requestHandler buildings];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GBBuildingCellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = @"Jump";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Request Handler

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSArray *buildings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (buildings && !error) {
        for (NSDictionary *dictinary in buildings) {
            GBBuilding *building = [dictinary toBuilding];
            NSLog(@"%@",building);
        }
    }
}

- (void)handleError:(RequestHandler *)handler code:(NSInteger)code message:(NSString *)message {
    NSLog(@"error: %@",message);
}

@end
