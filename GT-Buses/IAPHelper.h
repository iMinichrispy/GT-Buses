//
//  IAPHelper.h
//  GT-Buses
//
//  Created by Alex Perez on 1/11/15.
//  Copyright (c) 2015 Alex Perez. All rights reserved.
//

@import Foundation;
@import StoreKit;

extern NSString *const IAPHelperTransactionFinishedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface IAPHelper : NSObject

- (instancetype)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)buyProduct:(SKProduct *)product;
- (void)restoreCompletedTransactions;

@end
