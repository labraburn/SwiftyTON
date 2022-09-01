//
//  GTRequestHandler.m
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import "GTRequestHandler.h"

#pragma mark - GTRequestHandler

@implementation GTRequestHandler

- (instancetype)initWithCompletionBlock:(GTRequestHandlerCompletionBlock)completionBlock {
    self = [super init];
    if (self != nil) {
        _completionBlock = [completionBlock copy];
        _isCancelled = NO;
    }
    return self;
}

- (void)cancel {
    _isCancelled = YES;
}

@end

#pragma mark - GTRequestHandlerStorage

@interface GTRequestHandlerStorage ()

@property (nonatomic, assign) uint64_t pendingRequestID;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GTRequestHandler *> *storage;
@property (nonatomic, strong) NSObject *lock;

@end

@implementation GTRequestHandlerStorage

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _pendingRequestID = 1;
        _storage = [[NSMutableDictionary alloc] init];
        _lock = [[NSObject alloc] init];
    }
    return self;
}

- (NSNumber *)generateRequestID {
    __block NSNumber *requestID = nil;
    @synchronized (self.lock) {
        requestID = @(self.pendingRequestID);
        self.pendingRequestID += 1;
    }
    return requestID;
}

- (void)setRequestHandler:(GTRequestHandler *)requestHandler withRequestID:(NSNumber *)requestID {
    @synchronized (self.lock) {
        [self.storage setObject:requestHandler forKey:requestID];
    }
}

- (GTRequestHandler * _Nullable)requestHandlerForRequestID:(NSNumber *)requestID {
    __block GTRequestHandler *handler = nil;
    @synchronized (self.lock) {
        handler = [self.storage objectForKey:requestID];
    }
    return handler;
}

- (void)removeRequestHandlerForRequestID:(NSNumber *)requestID {
    @synchronized (self.lock) {
        [self.storage removeObjectForKey:requestID];
    }
}

- (void)markRequestHandlerCancelledForRequestID:(NSNumber *)requestID {
    @synchronized (self.lock) {
        [[self.storage objectForKey:requestID] cancel];
    }
}

@end
