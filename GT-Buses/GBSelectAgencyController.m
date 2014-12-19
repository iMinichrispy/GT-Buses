//
//  GBSelectAgencyController.m
//  GT-Buses
//
//  Created by Alex Perez on 12/17/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSelectAgencyController.h"

#import "GBAgency.h"
#import "GBColors.h"
#import "GBConfig.h"
#import "GBAgencyCell.h"
#import "XMLReader.h"
#import "GBRequestHandler.h"

static NSString *const GBAgencyCellIdentifier = @"GBAgencyCellIdentifier";

@interface GBSelectAgencyController () <RequestHandlerDelegate>

@property (nonatomic, strong) NSArray *agencies;

@end

@implementation GBSelectAgencyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SELECT_AGENCY", @"Select agency");
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    
    [self.tableView setTintColor:[UIColor appTintColor]];
    [self.tableView registerClass:[GBAgencyCell class] forCellReuseIdentifier:GBAgencyCellIdentifier];
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBRequestAgencyTask delegate:self];
    [requestHandler agencyList];
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    if (!error && dictionary) {
        NSArray *agencies = dictionary[@"body"][@"agency"];
        if (![agencies isKindOfClass:[NSArray class]]) agencies = @[agencies];
        
        NSMutableArray *newAgencies = [NSMutableArray new];
        for (NSDictionary *dictionary in agencies) {
            GBAgency *agency = [dictionary xmlToAgency];
            agency.selected = ([agency.tag isEqualToString:[GBConfig sharedInstance].agency]);
            [newAgencies addObject:agency];
        }
        _agencies = newAgencies;
        [self.tableView reloadData];
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_agencies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GBAgencyCellIdentifier forIndexPath:indexPath];
    
    GBAgency *agency = _agencies[indexPath.row];
    cell.textLabel.text = agency.title;
    cell.detailTextLabel.text = agency.regionTitle;
    cell.accessoryType = (agency.selected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
