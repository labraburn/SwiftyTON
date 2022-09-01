//
//  GTFees.m
//  
//
//  Created by Anton Spivak on 17.02.2022.
//

#import "GTFees.h"

@implementation GTFees

- (instancetype)initWithInFwdFee:(int64_t)inFwdFee
                      storageFee:(int64_t)storageFee
                          gasFee:(int64_t)gasFee
                          fwdFee:(int64_t)fwdFee
{
    self = [super init];
    if (self != nil) {
        _inFwdFee = inFwdFee;
        _storageFee = storageFee;
        _gasFee = gasFee;
        _fwdFee = fwdFee;
    }
    return self;
}

@end

@implementation GTFeesQuery

- (instancetype)initWithSourceFees:(GTFees *)sourceFees
                   destinationFees:(NSArray<GTFees *> *)destinationFees
{
    self = [super init];
    if (self != nil) {
        _sourceFees = sourceFees;
        _destinationFees = [destinationFees copy];
    }
    return self;
}

@end
