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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshAgencies) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    doneButton.enabled = [GBConfig sharedInstance].agency != nil;
    self.navigationItem.leftBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    
    if ([self.tableView respondsToSelector:@selector(setTintColor:)]) {
        [self.tableView setTintColor:[UIColor appTintColor]];
    }
    [self.tableView registerClass:[GBAgencyCell class] forCellReuseIdentifier:GBAgencyCellIdentifier];
    
    [self setStatus:NSLocalizedString(@"LOADING", @"Loading...")];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agencyDidChange:) name:GBNotificationAgencyDidChange object:nil];
    
}

- (void)agencyDidChange:(NSNotification *)notification {
    GBAgency *newAgency = [GBConfig sharedInstance].agency;
    
    GBAgency *selectedAgency = _agencies[_selectedPath.row];
    selectedAgency.selected = NO;
    _selectedPath = nil;
    
    for (int x = 0; x < [_agencies count]; x++) {
        GBAgency *agency = _agencies[x];
        if ([agency isEqual:newAgency]) {
            agency.selected = YES;
            _selectedPath = [NSIndexPath indexPathForRow:x inSection:0];
            break;
        }
    }
    
    self.navigationItem.leftBarButtonItem.enabled = ([newAgency.tag length]);
    [self.tableView reloadData];
}

- (void)dismiss:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_selectedPath) {
        GBAgency *agency = _agencies[_selectedPath.row];
        [GBConfig sharedInstance].agency = agency;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshAgencies];
}

- (void)refreshAgencies {
    [self.refreshControl beginRefreshing];
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBRequestAgencyTask delegate:self];
    [requestHandler agencyList];
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    [self.refreshControl endRefreshing];
    if (!error && dictionary) {
        NSArray *agencies = dictionary[@"body"][@"agency"];
        if (![agencies isKindOfClass:[NSArray class]]) agencies = @[agencies];
        
        NSMutableDictionary *agenciesDictionary = [NSMutableDictionary new];
        NSMutableArray *newAgencies = [NSMutableArray new];
        for (int x = 0; x < [agencies count]; x++) {
            NSDictionary *dictionary = agencies[x];
            GBAgency *agency = [dictionary xmlToAgency];
            agency.selected = ([agency isEqual:[GBConfig sharedInstance].agency]);
            if (agency.selected) {
                _selectedPath = [NSIndexPath indexPathForRow:x inSection:0];
            }
            [newAgencies addObject:agency];
            
            agenciesDictionary[agency.tag] = dictionary;
        }
        _agencies = newAgencies;
        
        [[NSUserDefaults standardUserDefaults] setObject:agenciesDictionary forKey:GBUserDefaultsAgenciesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self setStatus:nil];
        [self.tableView reloadData];
    } else {
        NSError *error = [NSError errorWithDomain:GBRequestErrorDomain code:GBRequestParseError userInfo:nil];
        [self handleError:handler error:error];
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    [self.refreshControl endRefreshing];
    if (![_agencies count]) {
        [self setStatus:FORMAT(@"%@%@.", NSLocalizedString(@"AGENCY_LIST_ERROR", @"Failed to retrieve agency list"), [GBRequestHandler errorMessageForCode:[error code]])];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_agencies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GBAgencyCellIdentifier forIndexPath:indexPath];
    
    GBAgency *agency = _agencies[indexPath.row];
    cell.textLabel.text = agency.title;
#if DEBUG
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", agency.regionTitle, agency.tag];
#else
    cell.detailTextLabel.text = agency.regionTitle;
#endif
    
    cell.accessoryType = (agency.selected) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
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
