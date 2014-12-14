//
//  GBRouteCell.m
//  GT-Buses
//
//  Created by Alex Perez on 12/13/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRouteCell.h"

#import "GBColors.h"
#import "GBConstants.h"
#import "GBConstraintHelper.h"

@implementation GBRouteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        _checkboxView = [[UIView alloc] init];
//        _checkboxView.translatesAutoresizingMaskIntoConstraints = NO;
//        _checkboxView.backgroundColor = [UIColor redColor];
//        [self addSubview:_checkboxView];
//        
//        NSMutableArray *constraints = [NSMutableArray new];
//        [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_checkboxView horizontal:NO]];
//        [constraints addObject:[GBConstraintHelper widthConstraint:_checkboxView width:50]];
//        [self addConstraints:constraints];
        self.textLabel.font = [UIFont fontWithName:GBFontDefault size:17];
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [[UIColor appTintColor] colorWithAlphaComponent:.5];
        self.selectedBackgroundView = selectedView;
    }
    return self;
}

@end
