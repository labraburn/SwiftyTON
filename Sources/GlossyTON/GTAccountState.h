//
//  GTAccountState.h
//  
//
//  Created by Anton Spivak on 16.02.2022.
//

#import <Foundation/Foundation.h>

@class GTTransactionID;

NS_ASSUME_NONNULL_BEGIN

@interface GTAccountState : NSObject

@property (nonatomic, copy) NSData *code;
@property (nonatomic, copy) NSData *data;

@property (nonatomic, strong, readonly, nullable) GTTransactionID *lastTransactionID;

/// nano (10e-9)
@property (nonatomic, readonly) int64_t balance;

/// UTC
@property (nonatomic, readonly) int64_t synctime;

- (instancetype)initWithCode:(NSData *)code
                        data:(NSData *)data
           lastTransactionID:(GTTransactionID * _Nullable)lastTransactionID
                     balance:(int64_t)balance
                    synctime:(int64_t)synctime;

@end

NS_ASSUME_NONNULL_END
