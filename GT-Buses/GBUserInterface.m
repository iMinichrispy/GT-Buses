//
//  GBUserInterface.m
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBUserInterface.h"

#import "GBColors.h"
#import "GBConstants.h"
#import "GBSideBarItem.h"

@implementation GBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self updateTintColor];
}

- (void)updateTintColor {
    UIColor *color = [UIColor appTintColor];
    if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationBar.barTintColor = color;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        self.navigationBar.tintColor = color;
    }
}

@end


@implementation GBLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor]; // Default background color is white on <=iOS6
        self.textColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.font = [UIFont fontWithName:GBFontDefault size:14];
    }
    return self;
}

@end


@implementation GBButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [[UIColor appTintColor] darkerColor:0.2];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:GBFontDefault size:16];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    float colorFactor = highlighted ? 0.26f : 0.2f;
    self.backgroundColor = [[UIColor appTintColor] darkerColor:colorFactor];
}

- (void)updateTintColor {
    [self setHighlighted:NO];
}

@end


@implementation GBSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.segmentedControlStyle = UISegmentedControlStyleBar;
        self.apportionsSegmentWidthsByContent = NO;
    }
    return self;
}

@end


@implementation GBErrorLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end


@interface GBAboutView () {
    NSLayoutConstraint *_topPaddingConstraint;
}

@end

@implementation GBAboutView

float const kItemViewSpacing = 14.0f;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [[UIColor appTintColor] darkerColor:0.05];
        
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [NSString stringWithFormat:@"%@ (%@)", info[@"CFBundleShortVersionString"], info[@"CFBundleVersion"]];
        
        GBSideBarItem *versionItem = [[GBSideBarItem alloc] initWithTitle:NSLocalizedString(@"VERSION", @"Version side item title") value:version];
        GBSideBarItem *developerItem = [[GBSideBarItem alloc] initWithTitle:NSLocalizedString(@"DEVELOPER", @"Developer side item title") value:@"Alex Perez"];
        GBSideBarItem *designItem = [[GBSideBarItem alloc] initWithTitle:NSLocalizedString(@"DESIGN", @"Design side item title") value:@"Felipe Salazar"];
        
        GBSideBarItemView *versionItemView = [[GBSideBarItemView alloc] initWithSiderBarItem:versionItem];
        [self addSubview:versionItemView];
        GBSideBarItemView *developerItemView = [[GBSideBarItemView alloc] initWithSiderBarItem:developerItem];
        [self addSubview:developerItemView];
        GBSideBarItemView *designItemView = [[GBSideBarItemView alloc] initWithSiderBarItem:designItem];
        [self addSubview:designItemView];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[versionItemView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(versionItemView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[developerItemView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(developerItemView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[designItemView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(designItemView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[versionItemView]-spacing-[developerItemView]-spacing-[designItemView]" options:0 metrics:@{@"spacing":@(kItemViewSpacing)} views:NSDictionaryOfVariableBindings(versionItemView, developerItemView, designItemView)]];
        _topPaddingConstraint = [NSLayoutConstraint
                                 constraintWithItem:versionItemView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeTop
                                 multiplier:1
                                 constant:[[self class] topPadding]];
        [constraints addObject:_topPaddingConstraint];
        [self addConstraints:constraints];
    }
    return self;
}

- (void)updateTintColor {
    self.backgroundColor = [[UIColor appTintColor] darkerColor:0.05];
    for (UIView *view in self.subviews) {
        if ([view conformsToProtocol:@protocol(GBTintColorDelegate)])
            [((id<GBTintColorDelegate>)view) updateTintColor];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    // iPhone 6 Plus is the only device that both supports orientation changes and where status bar is hidden in landscape
    _topPaddingConstraint.constant = [[self class] topPadding];
}

+ (float)topPadding {
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    return statusBarFrame.origin.y + statusBarFrame.size.height + 10;
}

@end


@implementation GBSideBarView

- (void)updateTintColor {
    self.backgroundColor = [[UIColor appTintColor] darkerColor:0.15];
}

@end


@implementation GBSideBarItemView

float const kSideBarItemLabelHeight = 20.0f;
float const kSideBarItemViewHeight = 40.0f;

- (instancetype)initWithSiderBarItem:(GBSideBarItem *)sideBarItem {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        GBSideBarView *view = [[GBSideBarView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view updateTintColor];
        [self addSubview:view];
        
        UILabel *titleLabel = [[GBLabel alloc] init];
        titleLabel.text = sideBarItem.title;
        [self addSubview:titleLabel];
        
        UILabel *valueLabel = [[GBLabel alloc] init];
        valueLabel.font = [UIFont fontWithName:GBFontDefault size:16];
        valueLabel.text = sideBarItem.value;
        [view addSubview:valueLabel];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[titleLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[valueLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(valueLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel(labelHeight)]-5-[view(viewHeight)]|" options:0 metrics:@{@"viewHeight":@(kSideBarItemViewHeight), @"labelHeight":@(kSideBarItemLabelHeight)} views:NSDictionaryOfVariableBindings(view, titleLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[valueLabel(labelHeight)]-10-|" options:0 metrics:@{@"labelHeight":@(kSideBarItemLabelHeight)} views:NSDictionaryOfVariableBindings(valueLabel)]];
        [self addConstraints:constraints];
    }
    return self;
}

- (void)updateTintColor {
    for (UIView *view in self.subviews) {
        if ([view conformsToProtocol:@protocol(GBTintColorDelegate)])
            [((id<GBTintColorDelegate>)view) updateTintColor];
    }
}

@end
