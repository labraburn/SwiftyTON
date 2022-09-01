//
//  GTExecutionResult.h
//  
//
//  Created by Anton Spivak on 16.02.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GTExecutionStackValue <NSObject>
@end

@interface GTExecutionResult : NSObject

@property (nonatomic, assign) int32_t code;
@property (nonatomic, copy) NSArray<GTExecutionStackValue> *stack;

- (instancetype)initWithCode:(int32_t)code
                       stack:(NSArray<GTExecutionStackValue> *)stack;

@end

#pragma mark - GTExecutionResultDecimal

@interface GTExecutionResultDecimal : NSObject <GTExecutionStackValue>

@property (nonatomic, copy) NSString *value;

- (instancetype)initWithValue:(NSString *)value;

@end

#pragma mark - GTExecutionResultSlice

@interface GTExecutionResultSlice : NSObject <GTExecutionStackValue>

@property (nonatomic, copy) NSData *hex;

- (instancetype)initWithHEX:(NSData *)hex;

@end

#pragma mark - GTExecutionResultCell

@interface GTExecutionResultCell : NSObject <GTExecutionStackValue>

@property (nonatomic, copy) NSData *hex;

- (instancetype)initWithHEX:(NSData *)hex;

@end

#pragma mark - GTExecutionResultEnumeration

@interface GTExecutionResultEnumeration : NSObject <GTExecutionStackValue>

@property (nonatomic, copy) NSArray<GTExecutionStackValue> *enumeration;

- (instancetype)initWithEnumeration:(NSArray<GTExecutionStackValue> *)enumeration;

@end

NS_ASSUME_NONNULL_END
