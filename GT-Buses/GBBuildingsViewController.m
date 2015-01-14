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
#import "GBColors.h"
#import "UIDevice+Hardware.h"
#import "GBBuildingCell.h"
#import "GBConfig.h"
#import "UITableViewController+StatusLabel.h"
#import "GBAgency.h"
#import "GBBuildingsHelper.h"

// TODO: Add ability to search for stops

static NSString *const GBBuildingCellIdentifier = @"GBBuildingCellIdentifier";

@interface GBBuildingsViewController () <RequestHandlerDelegate> {
    NSArray             *_partitionedBuildings;
    NSArray             *_sectionIndexTitles;
    NSMutableIndexSet   *_populatedIndexSet;
    GBBuilding          *_selectedBuilding;
    NSString            *_currentQuery;
}

@property (nonatomic, strong) NSArray *buildings;
@property (nonatomic, strong) NSArray *allBuildings;

@end

@implementation GBBuildingsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _buildings = [NSMutableArray new];
    }
    return self;
}

- (void)loadView {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionHeaderHeight = 22;
    if ([tableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)]) {
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    self.view = tableView;
    [self reduceTransparencyDidChange:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GBBuildingCell class] forCellReuseIdentifier:GBBuildingCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reduceTransparencyDidChange:) name:UIAccessibilityReduceTransparencyStatusDidChangeNotification object:nil];
    }
    
    [self updateTintColor:nil];
    
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    
    [self setupBuildings];
}

- (void)updateTintColor:(NSNotification *)notification {
    self.tableView.sectionIndexColor = [UIColor appTintColor];
    [self.tableView reloadData];
}

- (void)reduceTransparencyDidChange:(NSNotification *)notification {
    UIVisualEffect *visualEffect;
    UIView *backgroundView;
    UIColor *backgroundColor;
    if ([[UIDevice currentDevice] supportsVisualEffects]) {
        visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        backgroundView = [[UIVisualEffectView alloc] initWithEffect:visualEffect];
        backgroundColor = [UIColor clearColor];
    } else {
        visualEffect = nil;
        backgroundView = nil;
        backgroundColor = [UIColor whiteColor];
    }
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorEffect:)]) {
        self.tableView.separatorEffect = nil;
    }
    self.tableView.backgroundView = backgroundView;
    self.tableView.backgroundColor = backgroundColor;
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

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
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

- (GBBuilding *)buildingForIndexPath:(NSIndexPath *)indexPath {
    if (_partitionedBuildings)
        return _partitionedBuildings[indexPath.section][indexPath.row];
    return _buildings[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GBBuildingCellIdentifier forIndexPath:indexPath];
    
    GBBuilding *building = [self buildingForIndexPath:indexPath];
    
    cell.textLabel.text = building.name;
    cell.detailTextLabel.text = building.address;
    
    [(GBBuildingCell *)cell updateTintColor];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:recognizer];
    
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor appTintColor];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}

#pragma mark - Request Handler

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSPropertyListFormat format;
    NSArray *buildings = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:&error];
    if ([buildings count] && !error) {
        [self setStatus:nil];
        NSString *agency = [[GBConfig sharedInstance] agency].tag;
        [GBBuildingsHelper setBuildings:buildings forAgency:agency];
        [self setupForBuildings:buildings];
    } else {
        NSError *error = [NSError errorWithDomain:GBRequestErrorDomain code:GBRequestParseError userInfo:nil];
        [self handleError:handler error:error];
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    // Fall back on stored buildings (if available) if fails to retrieve udpated buildings
    [self revertToSavedBuildings];
}

- (void)setupBuildings {
    NSArray *buildings = [GBBuildingsHelper savedBuildingsForAgency:[[GBConfig sharedInstance] agency].tag ignoreExpired:YES];
    if ([buildings count]) {
        [self setupForBuildings:buildings];
    } else {
        [self updateBuildings];
    }
}

- (void)setupForBuildings:(NSArray *)buildings {
    NSMutableArray *newBuildings = [NSMutableArray new];
    
    for (NSDictionary *dictinary in buildings) {
        GBBuilding *building = [dictinary toBuilding];
        [newBuildings addObject:building];
    }
    _allBuildings = newBuildings;
    _buildings = _allBuildings;
    [self showAllBuildings];
}

- (void)updateBuildings {
    [self setStatus:NSLocalizedString(@"LOADING", @"Loading...")];
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBRequestBuildingsTask delegate:self];
    [requestHandler buildings];
}

- (void)revertToSavedBuildings {
    NSArray *buildings = [GBBuildingsHelper savedBuildingsForAgency:[[GBConfig sharedInstance] agency].tag ignoreExpired:NO];
    if ([buildings count]) {
        [self setStatus:nil];
        [self setupForBuildings:buildings];
    } else {
        [self setStatus:NSLocalizedString(@"NO_BUILDINGS_DATA", @"Buildings data is empty")];
    }
}

- (void)showAllBuildings {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSUInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    NSUInteger i;
    // Create a row for each section
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

#pragma mark - Menu controller

- (BOOL)becomeFirstResponder {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return [super resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    // Allows for UIMenuController to become visible over a cell
    return YES;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // TODO: Allow menu controller to become visible without changing the first responder (e.g. without dismissing the search keyboard)
        [self becomeFirstResponder];
        
        UITableViewCell *cell = (UITableViewCell *)recognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        _selectedBuilding = [self buildingForIndexPath:indexPath];
        
        NSMutableArray *menuItems = [NSMutableArray new];
        if ([_selectedBuilding hasPhoneNumer]) {
            UIMenuItem *call = [[UIMenuItem alloc] initWithTitle:_selectedBuilding.phone action:@selector(call:)];
            [menuItems addObject:call];
        }
        
        if ([_selectedBuilding hasAddress]) {
            UIMenuItem *copyAddress = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_ADDRESS", @"Copy the address") action:@selector(copyAddress:)];
            [menuItems addObject:copyAddress];
        }
        
        if (![menuItems count]) {
            UIMenuItem *noItems = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"NO_ADDRESS_OR_PHONE", @"Building has no address or phone number") action:@selector(doNothing:)];
            [menuItems addObject:noItems];
        }
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuItems];
        [menu setTargetRect:cell.frame inView:cell.superview];
        [menu setMenuVisible:YES animated:YES];
        
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)call:(UIMenuController *)sender {
    if ([_selectedBuilding hasPhoneNumer]) {
        NSString *dialableNumber = [_selectedBuilding dialablePhoneNumber];
        NSString *phoneURL = [NSString stringWithFormat:@"tel:%@", dialableNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
    }
}

- (void)copyAddress:(UIMenuController *)sender {
    if ([_selectedBuilding hasAddress]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _selectedBuilding.address;
    }
}

- (void)doNothing:(UIMenuController *)sender {
    
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText; {
    _partitionedBuildings = nil;
    
    if ([searchText length]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ OR address contains[c] %@", searchText, searchText];
        _buildings = [_allBuildings filteredArrayUsingPredicate:predicate];
    } else {
        _buildings = _allBuildings;
        
        // There is no entered text, show all buildings.
        [self showAllBuildings];
    }
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero];
    
    if ([_allBuildings count]) {
        // Show the No Results label if the user has entered text but didn't find anything
        [self setStatus:([searchText length] && [_buildings count] == 0 && ![searchText isEqualToString:@"\n"]) ? NSLocalizedString(@"NO_RESULTS_FOUND", @"Search returned no results") : nil];
    } else {
        [self revertToSavedBuildings];
    }
    _currentQuery = searchText;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.text = (_currentQuery) ? _currentQuery : @"";
    self.view.hidden = NO;
}

@end
