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

@interface GBBuildingsViewController () <RequestHandlerDelegate> {
    NSArray             *_allBuildings;
    NSArray             *_partitionedBuildings;
    NSArray             *_sectionIndexTitles;
    NSMutableIndexSet   *_populatedIndexSet;
    UILabel             *_errorLabel;
}

@property (nonatomic, strong) NSArray *buildings;

@end

@implementation GBBuildingsViewController


const float UITableDefaultRowHeight = 44.0;


static NSString * const GBBuildingCellIdentifier = @"GBBuildingCellIdentifier";

- (instancetype)init {
    self = [super init];
    if (self) {
        _buildings = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:GBBuildingCellIdentifier];
    
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_allBuildings) {
        GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBRequestBuildingsTask delegate:self];
#warning restore cache policy
//        requestHandler.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        [requestHandler buildings];
    }
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return (_partitionedBuildings ? _sectionIndexTitles : nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Don't show empty sections titles.
    BOOL showSection = [_partitionedBuildings[section] count] != 0;
    return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRowsInSection = [_buildings count];
    
    if (_partitionedBuildings)
        numberOfRowsInSection = [_partitionedBuildings[section] count];
    
    return numberOfRowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 1;
    
    if (_partitionedBuildings)
        numberOfSections = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger section = NSNotFound;
    NSInteger check = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    
    // Move to the touched index or the next nearest.
    NSInteger greaterOrEqual = [_populatedIndexSet indexGreaterThanOrEqualToIndex:check];
    NSInteger lessThan = [_populatedIndexSet indexLessThanIndex:check];
    
    if (greaterOrEqual != NSNotFound)
        section = greaterOrEqual;
    else if (lessThan != NSNotFound)
        section = lessThan;
    return section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GBBuildingCellIdentifier forIndexPath:indexPath];
    
    GBBuilding *building = _buildings[indexPath.row];
    if (_partitionedBuildings)
        building = _partitionedBuildings[indexPath.section][indexPath.row];
    
    cell.textLabel.text = building.name;
    cell.detailTextLabel.text = building.address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GBBuilding *building = _buildings[indexPath.row];
    if (_partitionedBuildings)
        building = _partitionedBuildings[indexPath.section][indexPath.row];
    if ([_delegate respondsToSelector:@selector(didSelectBuilding:)]) {
        [_delegate didSelectBuilding:building];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Request Handler

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSArray *buildings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (buildings && !error) {
        [self showErrorLabel:NO error:nil];
        NSMutableArray *newBuildings = [NSMutableArray new];
        for (NSDictionary *dictinary in buildings) {
            GBBuilding *building = [dictinary toBuilding];
            [newBuildings addObject:building];
        }
        _allBuildings = newBuildings;
        _buildings = _allBuildings;
        
        [self showAllBuildings];
    } else {
        [self handleError:handler code:PARSE_ERROR_CODE message:@"Parsing Error"];
    }
}

- (void)handleError:(RequestHandler *)handler code:(NSInteger)code message:(NSString *)message {
    [self showErrorLabel:YES error:[GBRequestHandler errorStringForCode:code]];
}

- (void)showAllBuildings {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSUInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    NSUInteger i;
    // Create a row for each section.
    for (i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    // Place each building into the correct section
    for (id object in _allBuildings) {
        NSInteger index = [collation sectionForObject:object collationStringSelector:@selector(name)];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:sectionCount];
    
    i = 0;
    
    _populatedIndexSet = [[NSMutableIndexSet alloc] init];
    
    for (NSMutableArray *section in unsortedSections) {
        NSArray *collatedSection = [collation sortedArrayFromArray:section collationStringSelector:@selector(name)];
        [sections addObject:collatedSection];
        
        if (collatedSection.count)
            [_populatedIndexSet addIndex:i];
        
        i++;
    }
    
    _sectionIndexTitles = [collation sectionIndexTitles];
    _partitionedBuildings = sections;
    [self.tableView reloadData];
}

- (void)setupForQuery:(NSString *)query {
    _partitionedBuildings = nil;
    
    if ([query length]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ OR address contains[c] %@", query, query];
        _buildings = [_allBuildings filteredArrayUsingPredicate:predicate];
    } else {
        _buildings = _allBuildings;
        
        // There is no entered text, show all buildings.
        [self showAllBuildings];
    }
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero];
    
    // Show the No Results Found label if the user has entered text but didn't find anything.
    // keyboard for right-aligned languages will send a "\n" text change notification when they become active, or after all text is deleted from an input started in left layout. Don't take this as user text input.
    [self showErrorLabel:( [query length] && [_buildings count] == 0 && ![query isEqualToString:@"\n"] ) error:@"No Results Found"];
}

- (void)showErrorLabel:(BOOL)show error:(NSString *)error {
#warning !_errorLabel is potentially problematic
    if(show && !_errorLabel) {
        // Show the Error label
        CGRect errorLabelFrame = [self.tableView frame];
        errorLabelFrame.origin.y += (IS_IPAD) ? UITableDefaultRowHeight * 3 : UITableDefaultRowHeight;
        errorLabelFrame.size.height = UITableDefaultRowHeight; // Height should be one row
        
        _errorLabel = [[UILabel alloc] initWithFrame:errorLabelFrame];
        
        [_errorLabel setOpaque:NO];
        [_errorLabel setBackgroundColor:nil];
        [_errorLabel setTextAlignment:NSTextAlignmentCenter];
        
        [_errorLabel setText:error];
        [_errorLabel setTextColor:[UIColor blackColor]];
        [_errorLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        
        [self.view addSubview:_errorLabel];
    } else if (!show && _errorLabel) {
        // Hide the Error Found label
        [_errorLabel removeFromSuperview];
        _errorLabel = nil;
    }
}

@end
