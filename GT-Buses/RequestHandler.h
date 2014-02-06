//
//  RequestHandler.h
//  HousePoints
//
//  Created by Alex Perez on 1/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class RequestHandler;
@protocol RequestHandlerDelegate <NSObject>

@required
- (void)handleResponse:(RequestHandler *)handler data:(id)data;

@optional
- (void)handleError:(RequestHandler *)handler code:(int)code message:(NSString *)message;

@end

@interface RequestHandler : NSObject <NSURLConnectionDelegate> {
    NSMutableData *responseData;
}

@property (nonatomic, weak) id <RequestHandlerDelegate> delegate;
@property (nonatomic, strong) NSString *task;

- (id)initWithDelegate:(id)requestDelegate task:(NSString *)newTask;
- (void)postRequestWithPath:(NSString *)path postData:(NSData *)postData;
- (void)getRequestWithURL:(NSString *)url;
- (void)handleErrorCode:(int)code message:(NSString *)message;
- (void)routeConfig;
- (void)positionForBus:(NSString *)tag;
- (void)predictionsForBus:(NSString *)tag;

@end
