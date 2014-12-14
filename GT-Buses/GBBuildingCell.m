//
//  GBBuildingCell.m
//  GT-Buses
//
//  Created by Alex Perez on 11/26/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBuildingCell.h"

#import "GBConstants.h"
#import "UIDevice+Hardware.h"

@implementation GBBuildingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:GBFontDefault size:16];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateTintColor {
    self.textLabel.textColor = [UIColor appTintColor];
    
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [[UIColor appTintColor] colorWithAlphaComponent:.5];
    self.selectedBackgroundView = selectedView;
}

- (BOOL)canBecomeFirstResponder {
    // Allows for UIMenuController to become visible over a cell
    return YES;
}

@end
