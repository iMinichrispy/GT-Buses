//
//  GBAgencyCell.m
//  GT-Buses
//
//  Created by Alex Perez on 12/17/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBAgencyCell.h"

#import "GBColors.h"
#import "GBConstants.h"

@implementation GBAgencyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:GBFontDefault size:17];
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [[UIColor appTintColor] colorWithAlphaComponent:.5];
        self.selectedBackgroundView = selectedView;
    }
    return self;
}

@end
