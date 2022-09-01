//
//  GTQueue.m
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import "GTQueue.h"

static const void *GTQueueSpecificKey = &GTQueueSpecificKey;

@interface GTQueue ()

@property (nonatomic, strong) dispatch_queue_t _queue;
@property (nonatomic, assign) void * _specific;
@property (nonatomic, assign) BOOL _isMainQueue;

@end

@implementation GTQueue

+ (GTQueue *)main {
    static GTQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[GTQueue alloc] initWithDispatchQueue:dispatch_get_main_queue()
                                              specific:NULL];
        queue._isMainQueue = YES;
    });
    return queue;
}

+ (GTQueue *)concurrentDefaultQueue {
    static GTQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[GTQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                              specific:NULL];
    });
    return queue;
}

+ (GTQueue *)concurrentBackgroundQueue {
    static GTQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[GTQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
                                              specific:NULL];
    });
    return queue;
}

+ (GTQueue *)queueWithDispatchQueue:(dispatch_queue_t)dispatchQueue {
    return [[GTQueue alloc] initWithDispatchQueue:dispatchQueue
                                         specific:NULL];
}

- (instancetype)init {
    void * specific = (__bridge void *)self;
    
    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
    dispatch_queue_set_specific(queue, GTQueueSpecificKey, specific, NULL);
    
    return [self initWithDispatchQueue:queue
                              specific:specific];
}

- (instancetype)initWithDispatchQueue:(dispatch_queue_t)queue specific:(void *)specific {
    self = [super init];
    if (self != nil) {
        __queue = queue;
        __specific = specific;
    }
    return self;
}

- (void)async:(dispatch_block_t)block {
    if ([self isCurrentQueue]) {
        block();
    } else {
        dispatch_async(__queue, block);
    }
}

- (void)sync:(dispatch_block_t)block {
    if ([self isCurrentQueue]) {
        block();
    } else {
        dispatch_sync(__queue, block);
    }
}

- (void)dispatch:(dispatch_block_t)block synchronous:(bool)synchronous {
    if (synchronous) {
        [self sync:block];
    } else {
        [self async:block];
    }
}

#pragma mark - Setters & Getters

- (dispatch_queue_t)dispatchQueue {
    return __queue;
}

- (BOOL)isMainQueue {
    return __isMainQueue && [NSThread isMainThread];
}

- (BOOL)isCurrentQueue {
    if (__specific != NULL && dispatch_get_specific(GTQueueSpecificKey) == __specific) {
        return true;
    } else if ([self isMainQueue]) {
        return true;
    } else {
        return false;
    }
}

@end
