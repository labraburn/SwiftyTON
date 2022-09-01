//
//  GTTransaction.m
//  
//
//  Created by Anton Spivak on 02.02.2022.
//

#import "GTTransaction.h"

#pragma mark - GTTransactionID

@implementation GTTransactionID

- (instancetype)initWithLogicalTime:(int64_t)logicalTime
                   transactionHash:(NSData *)transactionHash
{
    self = [super init];
    if (self != nil) {
        _logicalTime = logicalTime;
        _transactionHash = transactionHash;
    }
    return self;
}

@end

#pragma mark - GTTransactionMessageContents

@implementation GTTransactionMessageContentsRawData

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self != nil) {
        _data = [data copy];
    }
    return self;
}

@end

@implementation GTTransactionMessageContentsPlainText

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self != nil) {
        _text = [text copy];
    }
    return self;
}

@end

@implementation GTTransactionMessageContentsEncryptedText

- (instancetype)initWithEncryptedData:(GTEncryptedData *)encryptedData {
    self = [super init];
    if (self != nil) {
        _encryptedData = encryptedData;
    }
    return self;
}

@end

#pragma mark - GTTransactionMessage

@implementation GTTransactionMessage

- (instancetype)initWithValue:(int64_t)value
                       fwdFee:(int64_t)fwdFee
                       ihrFee:(int64_t)ihrFee
                       source:(NSString *)source
                  destination:(NSString *)destination
                     contents:(id<GTTransactionMessageContents>)contents
                     bodyHash:(NSData *)bodyHash {
    self = [super init];
    if (self != nil) {
        _value = value;
        _fwdFee = fwdFee;
        _ihrFee = ihrFee;
        _source = [source copy];
        _destination = [destination copy];
        _contents = contents;
        _bodyHash = bodyHash;
    }
    return self;
}

@end

#pragma mark - GTTransaction

@implementation GTTransaction

- (instancetype)initWithData:(NSData *)data
               transactionID:(GTTransactionID *)transactionID
                   timestamp:(int64_t)timestamp
                  storageFee:(int64_t)storageFee
                    otherFee:(int64_t)otherFee
                   inMessage:(GTTransactionMessage * _Nullable)inMessage
                 outMessages:(NSArray<GTTransactionMessage *> *)outMessages
            isInitialization:(bool)isInitialization
{
    self = [super init];
    if (self != nil) {
        _data = [data copy];
        _transactionID = transactionID;
        _timestamp = timestamp;
        _storageFee = storageFee;
        _otherFee = otherFee;
        _inMessage = inMessage;
        _outMessages = outMessages;
        _isInitialization = isInitialization;
    }
    return self;
}

@end
