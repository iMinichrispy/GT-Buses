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

static NSString * const GBBuildingCellIdentifier = @"GBBuildingCellIdentifier";
static NSString * const GBBuildingsPlistFileName = @"Buildings.plist";

@interface GBBuildingsViewController () <RequestHandlerDelegate> {
    NSArray             *_partitionedBuildings;
    NSArray             *_sectionIndexTitles;
    NSMutableIndexSet   *_populatedIndexSet;
    UILabel             *_errorLabel;
    GBBuilding          *_selectedBuilding;
}

@property (nonatomic, strong) NSArray *buildings;
@property (nonatomic, strong) NSArray *allBuildings;

@end

@implementation GBBuildingsViewController

const float UITableDefaultRowHeight = 44.0;

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
    
    if ([[UIDevice currentDevice] supportsVisualEffects]) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        tableView.backgroundView = effectView;
        tableView.separatorEffect = blurEffect;
        tableView.backgroundColor = [UIColor clearColor];
    }
    
    self.view = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GBBuildingCell class] forCellReuseIdentifier:GBBuildingCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBuildings:) name:GBNotificationBuildingsVersionDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    [self updateTintColor:nil];
    
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:GBBuildingsPlistFileName];
    NSArray *buildings = [[NSArray alloc] initWithContentsOfFile:path];
    [self setupForBuildings:buildings];
}

- (void)setupForBuildings:(NSArray *)buildings {
    if (buildings) {
        NSMutableArray *newBuildings = [NSMutableArray new];
        
        for (NSDictionary *dictinary in buildings) {
            GBBuilding *building = [dictinary toBuilding];
            [newBuildings addObject:building];
        }
        _allBuildings = newBuildings;
        _buildings = _allBuildings;
        [self showAllBuildings];
    } else {
        [self updateBuildings:nil];
    }
}

- (void)updateBuildings:(NSNotification *)notification {
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
        [self showErrorLabel:NO error:nil];
        if ([buildings count]) {
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:GBBuildingsPlistFileName];
            [buildings writeToFile:path atomically:YES];
            [self setupForBuildings:buildings];
        } else {
            [self showErrorLabel:YES error:NSLocalizedString(@"NO_BUILDINGS_DATA", @"Buildings data is empty")];
        }
    } else {
        NSError *error = [NSError errorWithDomain:GBRequestErrorDomain code:GBRequestParseError userInfo:nil];
        [self handleError:handler error:error];
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    [self showErrorLabel:YES error:[GBRequestHandler errorStringForCode:[error code]]];
}

- (void)setAllBuildings:(NSArray *)allBuildings {
    if (_allBuildings != allBuildings) {
        _allBuildings = allBuildings;
    }
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
    
    // Show the No Results label if the user has entered text but didn't find anything
    [self showErrorLabel:( [query length] && [_buildings count] == 0 && ![query isEqualToString:@"\n"] ) error:NSLocalizedString(@"NO_RESULTS_FOUND", @"Search returned no results")];
}

- (void)showErrorLabel:(BOOL)show error:(NSString *)error {
    if(show && !_errorLabel) {
        // Show the Error label
        CGRect errorLabelFrame = [self.tableView bounds];
        errorLabelFrame.origin.y += (IS_IPAD) ? UITableDefaultRowHeight * 3 : UITableDefaultRowHeight;
        errorLabelFrame.size.height = UITableDefaultRowHeight; // Height should be one row
        
        _errorLabel = [[UILabel alloc] initWithFrame:errorLabelFrame];
        
        [_errorLabel setOpaque:NO];
        [_errorLabel setBackgroundColor:nil];
        [_errorLabel setTextAlignment:NSTextAlignmentCenter];
        
        [_errorLabel setText:error];
        [_errorLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
        [_errorLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
        
        [self.view addSubview:_errorLabel];
    } else if (show && _errorLabel) {
        _errorLabel.text = error;
    } else if (!show && _errorLabel) {
        // Hide the Error label
        [_errorLabel removeFromSuperview];
        _errorLabel = nil;
    }
}

#pragma mark - Menu controller

- (BOOL)canBecomeFirstResponder {
    // Allows for UIMenuController to become visible over a cell
    return YES;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
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
