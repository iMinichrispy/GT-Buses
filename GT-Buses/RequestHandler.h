//
//  RequestHandler.h
//  HousePoints
//
//  Created by Alex Perez on 1/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class RequestHandler;
@protocol RequestHandlerDelegate <NSObject>

@required
- (void)handleResponse:(RequestHandler *)handler data:(id)data;

@optional
- (void)handleError:(RequestHandler *)handler code:(NSInteger)code message:(NSString *)message;

@end

@interface RequestHandler : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) NSString *task;
@property (nonatomic, weak) id <RequestHandlerDelegate> delegate;

- (instancetype)initWithTask:(NSString *)task delegate:(id<RequestHandlerDelegate>)delegate;
- (void)getRequestWithURL:(NSString *)url;
- (void)postRequestWithURL:(NSString *)url postData:(NSData *)postData;
- (void)handleErrorCode:(NSInteger)code message:(NSString *)message;

@end
