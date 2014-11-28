//
//  RequestHandler.h
//  RequestHandler
//
//  Created by Alex Perez on 1/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class RequestHandler;
@protocol RequestHandlerDelegate <NSObject>

@required
- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data;

@optional
- (void)handleError:(RequestHandler *)handler error:(NSError *)error;

@end

@interface RequestHandler : NSObject <NSURLConnectionDelegate>

@property (nonatomic, weak) NSString *task;
@property (nonatomic, weak) id <RequestHandlerDelegate> delegate;
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;

- (instancetype)initWithTask:(NSString *)task delegate:(id<RequestHandlerDelegate>)delegate;
- (void)getRequestWithURL:(NSString *)url;
- (void)postRequestWithURL:(NSString *)url postData:(NSData *)postData;
- (void)handleError:(NSError *)error;

@end
