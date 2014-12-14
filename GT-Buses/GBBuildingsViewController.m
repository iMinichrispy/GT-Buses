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

// TODO: This class's fail-safe mechainisms should be redone to be made more clear (Loading from saved, retrieving from server, updating when buildings version changes)

static NSString *const GBBuildingCellIdentifier = @"GBBuildingCellIdentifier";
static NSString *const GBBuildingsPlistFileName = @"Buildings.plist";

@interface GBBuildingsViewController () <RequestHandlerDelegate> {
    NSArray             *_partitionedBuildings;
    NSArray             *_sectionIndexTitles;
    NSMutableIndexSet   *_populatedIndexSet;
    UILabel             *_statusLabel;
    GBBuilding          *_selectedBuilding;
}

@property (nonatomic, strong) NSArray *buildings;
@property (nonatomic, strong) NSArray *allBuildings;

@end

@implementation GBBuildingsViewController

float const UITableDefaultRowHeight = 44.0;

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
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionHeaderHeight = 22;
    self.view = tableView;
    [self reduceTransparencyDidChange:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GBBuildingCell class] forCellReuseIdentifier:GBBuildingCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBuildings:) name:GBNotificationBuildingsVersionDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    if (UIAccessibilityReduceTransparencyStatusDidChangeNotification != NULL) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reduceTransparencyDidChange:) name:UIAccessibilityReduceTransparencyStatusDidChangeNotification object:nil];
    }
    
    [self updateTintColor:nil];
    
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    
    NSArray *buildings = [self savedBuildings];
    [self setupForBuildings:buildings];
}

- (void)reduceTransparencyDidChange:(NSNotification *)notification {
    if ([[UIDevice currentDevice] supportsVisualEffects]) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.tableView.backgroundView = effectView;
        self.tableView.separatorEffect = blurEffect;
        self.tableView.backgroundColor = [UIColor clearColor];
    } else {
        self.tableView.backgroundView = nil;
        self.tableView.separatorEffect = nil;
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
}

- (NSArray *)savedBuildings {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:GBBuildingsPlistFileName];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![_allBuildings count]) {
        [self updateBuildings:nil];
    }
}

- (void)setupForBuildings:(NSArray *)buildings {
    if ([buildings count]) {
        NSMutableArray *newBuildings = [NSMutableArray new];
        
        for (NSDictionary *dictinary in buildings) {
            GBBuilding *building = [dictinary toBuilding];
            [newBuildings addObject:building];
        }
        _allBuildings = newBuildings;
        _buildings = _allBuildings;
        [self showAllBuildings];
    }
}

- (void)updateBuildings:(NSNotification *)notification {
    [self showStatusLabel:YES status:@"Loading..."];
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBRequestBuildingsTask delegate:self];
    [requestHandler buildings];
}

- (void)updateTintColor:(NSNotification *)notification {
    self.tableView.sectionIndexColor = [UIColor appTintColor];
    [self.tableView reloadData];
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
    if (buildings && !error) {
        [self showStatusLabel:NO status:nil];
        if ([buildings count]) {
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:GBBuildingsPlistFileName];
            [buildings writeToFile:path atomically:YES];
            // Update the stored buildings version
            [[NSUserDefaults standardUserDefaults] setInteger:[[GBConfig sharedInstance] buildingsVersion] forKey:GBUserDefaultsBuildingsVersionKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setupForBuildings:buildings];
        } else {
            [self revertToSavedBuildings];
        }
    } else {
        NSError *error = [NSError errorWithDomain:GBRequestErrorDomain code:GBRequestParseError userInfo:nil];
        [self handleError:handler error:error];
    }
}

- (void)revertToSavedBuildings {
    NSArray *buildings = [self savedBuildings];
    if ([buildings count]) {
        [self showStatusLabel:NO status:nil];
        [self setupForBuildings:buildings];
    } else {
        [self showStatusLabel:YES status:NSLocalizedString(@"NO_BUILDINGS_DATA", @"Buildings data is empty")];
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    // Fall back on stored buildings (if available) if fails to retrieve udpated buildings
    [self revertToSavedBuildings];
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
    
    if ([_allBuildings count]) {
        // Show the No Results label if the user has entered text but didn't find anything
        [self showStatusLabel:( [query length] && [_buildings count] == 0 && ![query isEqualToString:@"\n"] ) status:NSLocalizedString(@"NO_RESULTS_FOUND", @"Search returned no results")];
    } else {
        [self revertToSavedBuildings];
    }
}

- (void)showStatusLabel:(BOOL)show status:(NSString *)status {
    if(show && !_statusLabel) {
        // Show the Error label
        CGRect errorLabelFrame = [self.tableView bounds];
        errorLabelFrame.origin.y += (IS_IPAD) ? UITableDefaultRowHeight * 3 : UITableDefaultRowHeight;
        errorLabelFrame.size.height = UITableDefaultRowHeight; // Height should be one row
        
        _statusLabel = [[UILabel alloc] initWithFrame:errorLabelFrame];
        
        [_statusLabel setOpaque:NO];
        [_statusLabel setBackgroundColor:nil];
        [_statusLabel setTextAlignment:NSTextAlignmentCenter];
        
        [_statusLabel setText:status];
        [_statusLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
        [_statusLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        
        [self.view addSubview:_statusLabel];
    } else if (show && _statusLabel) {
        _statusLabel.text = status;
    } else if (!show && _statusLabel) {
        // Hide the Error label
        [_statusLabel removeFromSuperview];
        _statusLabel = nil;
    }
}

- (void)reset {
    
}

#pragma mark - Menu controller

- (BOOL)canBecomeFirstResponder {
    // Allows for UIMenuController to become visible over a cell
    return YES;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // TODO: Allow Menu controller to become visible without changing the first responder (e.g. without dismissing the search keyboard)
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

@end
