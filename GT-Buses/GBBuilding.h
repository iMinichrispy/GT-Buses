//
//  GBBuilding.h
//  GT-Buses
//
//  Created by Alex Perez on 11/20/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@class GBBuilding;
@interface NSDictionary (GBBuilding)

- (GBBuilding *)toBuilding;

@end

@interface GBBuilding : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *buildingID;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic) double lat;
@property (nonatomic) double lon;

- (instancetype)initWithName:(NSString *)name buildingID:(NSString *)buildingID;
- (NSDictionary *)toDictionary;

@end
