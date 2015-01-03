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
#import "GBAgencyCell.h"
#import "GBConstants.h"
#import "UITableViewController+StatusLabel.h"

static NSString *const GBAgencyCellIdentifier = @"GBAgencyCellIdentifier";

@interface GBSelectAgencyController () <RequestHandlerDelegate> {
    NSIndexPath *_selectedPath;
    BOOL _didChangeAgency;
}

@property (nonatomic, strong) NSArray *agencies;

@end

@implementation GBSelectAgencyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SELECT_AGENCY", @"Select agency");
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    doneButton.enabled = [[GBConfig sharedInstance].agency length];
    self.navigationItem.leftBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    
    [self.tableView setTintColor:[UIColor appTintColor]];
    [self.tableView registerClass:[GBAgencyCell class] forCellReuseIdentifier:GBAgencyCellIdentifier];
    
    [self setStatus:@"Loading..."];
}

- (void)dismiss:(id)sender {
    GBAgency *agency = _agencies[_selectedPath.row];
    [GBConfig sharedInstance].agency = agency.tag;
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
        [self setStatus:nil];
        [self.tableView reloadData];
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    [self setStatus:FORMAT(@"%@%@", NSLocalizedString(@"AGENCY_LIST_ERROR", @"Failed to retrieve agency list"), [GBRequestHandler errorMessageForCode:[error code]])];
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
    
    if (agency.selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [(GBAgencyCell *)cell updateTintColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:_selectedPath];
    GBAgency *selectedAgency = _agencies[_selectedPath.row];
    selectedAgency.selected = NO;
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GBAgency *agency = _agencies[indexPath.row];
    agency.selected = YES;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    _selectedPath = indexPath;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
