//
//  GBAgency.h
//  GT-Buses
//
//  Created by Alex Perez on 12/17/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@class GBAgency;
@interface NSDictionary (GBAgency)

- (GBAgency *)xmlToAgency;

@end

@interface GBAgency : NSObject

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag regionTitle:(NSString *)regionTitle;

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *regionTitle;
@property (nonatomic) BOOL selected;

@end
