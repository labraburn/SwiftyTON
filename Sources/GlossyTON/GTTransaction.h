//
//  GTTransaction.h
//  
//
//  Created by Anton Spivak on 02.02.2022.
//

#import <Foundation/Foundation.h>

@class GTEncryptedData;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - GTTransactionID

@interface GTTransactionID : NSObject

@property (nonatomic, readonly) int64_t logicalTime;
@property (nonatomic, copy, readonly) NSData *transactionHash;

- (instancetype)initWithLogicalTime:(int64_t)logicalTime
                   transactionHash:(NSData *)transactionHash;

@end

#pragma mark - GTTransactionMessageContents

@protocol GTTransactionMessageContents <NSObject>

@end

@interface GTTransactionMessageContentsRawData : NSObject <GTTransactionMessageContents>

@property (nonatomic, copy, readonly) NSData *data;

- (instancetype)initWithData:(NSData *)data;

@end

@interface GTTransactionMessageContentsPlainText : NSObject <GTTransactionMessageContents>

@property (nonatomic, copy, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end

@interface GTTransactionMessageContentsEncryptedText : NSObject <GTTransactionMessageContents>

@property (nonatomic, strong, readonly) GTEncryptedData *encryptedData;

- (instancetype)initWithEncryptedData:(GTEncryptedData *)encryptedData;

@end

#pragma mark - GTTransactionMessage

@interface GTTransactionMessage : NSObject

@property (nonatomic, readonly) int64_t value;
@property (nonatomic, readonly) int64_t fwdFee;
@property (nonatomic, readonly) int64_t ihrFee;
@property (nonatomic, copy, readonly) NSString *source;
@property (nonatomic, copy, readonly) NSString *destination;
@property (nonatomic, strong, readonly) id<GTTransactionMessageContents> contents;
@property (nonatomic, copy, readonly) NSData *bodyHash;

- (instancetype)initWithValue:(int64_t)value
                       fwdFee:(int64_t)fwdFee
                       ihrFee:(int64_t)ihrFee
                       source:(NSString * _Nonnull)source
                  destination:(NSString * _Nonnull)destination
                     contents:(id<GTTransactionMessageContents>)contents
                     bodyHash:(NSData * _Nonnull)bodyHash;

@end

#pragma mark - GTTransaction

@interface GTTransaction : NSObject

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) GTTransactionID *transactionID;
@property (nonatomic, readonly) int64_t timestamp;
@property (nonatomic, readonly) int64_t storageFee;
@property (nonatomic, readonly) int64_t otherFee;
@property (nonatomic, strong, readonly) GTTransactionMessage * _Nullable inMessage;
@property (nonatomic, strong, readonly) NSArray<GTTransactionMessage *> *outMessages;
@property (nonatomic, readonly) bool isInitialization;

- (instancetype)initWithData:(NSData *)data
               transactionID:(GTTransactionID *)transactionID
                   timestamp:(int64_t)timestamp
                  storageFee:(int64_t)storageFee
                    otherFee:(int64_t)otherFee
                   inMessage:(GTTransactionMessage * _Nullable)inMessage
                 outMessages:(NSArray<GTTransactionMessage *> * _Nonnull)outMessages
            isInitialization:(bool)isInitialization;

@end

NS_ASSUME_NONNULL_END
