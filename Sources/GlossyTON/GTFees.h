//
//  GTFees.h
//  
//
//  Created by Anton Spivak on 17.02.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTFees : NSObject

@property (nonatomic, readonly) int64_t inFwdFee;
@property (nonatomic, readonly) int64_t storageFee;
@property (nonatomic, readonly) int64_t gasFee;
@property (nonatomic, readonly) int64_t fwdFee;

- (instancetype)initWithInFwdFee:(int64_t)inFwdFee
                      storageFee:(int64_t)storageFee
                          gasFee:(int64_t)gasFee
                          fwdFee:(int64_t)fwdFee;

@end

@interface GTFeesQuery : NSObject

@property (nonatomic, strong, readonly) GTFees * sourceFees;
@property (nonatomic, copy, readonly) NSArray<GTFees *> *destinationFees;

- (instancetype)initWithSourceFees:(GTFees *)sourceFees
                   destinationFees:(NSArray<GTFees *> *)destinationFees;

@end

NS_ASSUME_NONNULL_END
