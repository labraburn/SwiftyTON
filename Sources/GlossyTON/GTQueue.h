//
//  GTQueue.h
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTQueue : NSObject

+ (GTQueue *)main;
+ (GTQueue *)concurrentDefaultQueue;
+ (GTQueue *)concurrentBackgroundQueue;

+ (GTQueue *)queueWithDispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)async:(dispatch_block_t)block;
- (void)sync:(dispatch_block_t)block;
- (void)dispatch:(dispatch_block_t)block synchronous:(bool)synchronous;

- (dispatch_queue_t)dispatchQueue;

- (BOOL)isMainQueue;
- (BOOL)isCurrentQueue;

@end

NS_ASSUME_NONNULL_END
