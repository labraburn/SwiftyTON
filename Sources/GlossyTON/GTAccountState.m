//
//  GTAccountState.m
//  
//
//  Created by Anton Spivak on 16.02.2022.
//

#import "GTAccountState.h"

@implementation GTAccountState

- (instancetype)initWithCode:(NSData *)code
                        data:(NSData *)data
           lastTransactionID:(GTTransactionID *)lastTransactionID
                     balance:(int64_t)balance
                    synctime:(int64_t)synctime
{
    self = [super init];
    if (self != nil) {
        _code = [code copy];
        _data = [data copy];
        _lastTransactionID = lastTransactionID;
        _balance = balance;
        _synctime = synctime;
    }
    return self;
}

@end
