//
//  GTRequestHandler.h
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import <Foundation/Foundation.h>
#import "GlossyTON.h"

@class GTURLRequest;
@class GTRequestHandler;

NS_ASSUME_NONNULL_BEGIN

typedef void (^GTRequestHandlerCompletionBlock)(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object);

#pragma mark - GTRequestHandler

@interface GTRequestHandler : NSObject

@property (nonatomic, copy, readonly) GTRequestHandlerCompletionBlock completionBlock;
@property (nonatomic, assign, readonly) BOOL isCancelled;

- (instancetype)initWithCompletionBlock:(GTRequestHandlerCompletionBlock)completionBlock;

@end

#pragma mark - GTRequestHandlerStorage

@interface GTRequestHandlerStorage : NSObject

- (NSNumber *)generateRequestID;
- (void)setRequestHandler:(GTRequestHandler *)requestHandler withRequestID:(NSNumber *)requestID;
- (GTRequestHandler * _Nullable)requestHandlerForRequestID:(NSNumber *)requestID;
- (void)removeRequestHandlerForRequestID:(NSNumber *)requestID;
- (void)markRequestHandlerCancelledForRequestID:(NSNumber *)requestID;

@end

NS_ASSUME_NONNULL_END
