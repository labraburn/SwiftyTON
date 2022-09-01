//
//  Created by Anton Spivak
//

#import <Foundation/Foundation.h>

@class GTTON;
@class GTURLRequest;
@class GTTONConfiguration;
@class GTTONKey;
@class GTAccountState;
@class GTExecutionResult;
@class GTPreparedQuery;
@class GTFeesQuery;
@class GTTransaction;
@class GTTransactionID;
@class GTEncryptedData;
@class GTRequestID;
@class GTDNS;

@protocol GTTransactionMessageContents;
@protocol GTExecutionStackValue;

NS_ASSUME_NONNULL_BEGIN

typedef void (^GTTONInitializationHandler)(NSError * _Nullable);

@protocol GTTONDelegate <NSObject>

@optional
- (void)ton:(GTTON *)ton didUpdateSynchronizationProgress:(double)progress;
- (void)ton:(GTTON *)ton didRequiredPerfromURLRequest:(GTURLRequest *)request;

@end

@interface GTTON : NSObject

@property (nonatomic, strong, readonly, nullable) GTTONConfiguration *configuration;
@property (nonatomic, weak, nullable) id<GTTONDelegate> delegate;

- (instancetype)init;

// Initializes with configuration and save it in memory
- (void)initializeWithConfiguration:(GTTONConfiguration *)configuration
                    completionBlock:(GTTONInitializationHandler)completionBlock;

- (GTRequestID *)generateRequestID;
- (void)cancelRequestID:(GTRequestID *)requestID;

@end

@interface GTTON (API)

#pragma mark - Confugarion methods

// Validates current configuration and returns prefixWalletID (initialWalletdID) from configuration
- (void)validateCurrentConfigurationWithCompletionBlock:(void(^ _Nonnull)(int64_t prefixWalletID, NSError * _Nullable error))completionBlock
                                              requestID:(GTRequestID * _Nullable)requestID;

// Updates configuration and initializes lite server
- (void)updateConfiguration:(GTTONConfiguration *)configuration
            completionBlock:(void (^)(NSError * _Nullable error))completionBlock
                  requestID:(GTRequestID * _Nullable)requestID;

#pragma mark - Keys methods

// Create and store key with `userPassword` and `mnemonicPassword`
// Returns encrypted version of GTTONKey
- (void)createKeyWithUserPassword:(NSData *)userPassword
                 mnemonicPassword:(NSData *)mnemonicPassword
                  completionBlock:(void(^ _Nonnull)(GTTONKey * _Nullable key, NSError * _Nullable error))completionBlock
                        requestID:(GTRequestID * _Nullable)requestID;

// Import and store  key with `userPassword` and `mnemonicPassword` and `words` (24 count)
- (void)importKeyWithUserPassword:(NSData *)userPassword
                 mnemonicPassword:(NSData *)mnemonicPassword
                            words:(NSArray<NSString *> *)words
                  completionBlock:(void(^ _Nonnull)(GTTONKey * _Nullable key, NSError * _Nullable error))completionBlock
                        requestID:(GTRequestID * _Nullable)requestID;

// Removes stored key
- (void)deleteKey:(GTTONKey *)key
  completionBlock:(void (^)(NSError * _Nullable error))completionBlock
        requestID:(GTRequestID * _Nullable)_requestID;

// Removes all stored keys
- (void)deleteAllKeysWithCompletionBlock:(void (^)(NSError * _Nullable error))completionBlock
                               requestID:(GTRequestID * _Nullable)requestID;

#pragma mark - Security methods

// Returns decrypted version of given `GTTONKey` key
- (void)exportDecryptedKeyWithEncryptedKey:(GTTONKey *)encryptedKey
                          withUserPassword:(NSData *)userPassword
                           completionBlock:(void(^ _Nonnull)(NSData * _Nullable decryptedSecretKey, NSError * _Nullable error))completionBlock
                                 requestID:(GTRequestID * _Nullable)requestID;

// Returns word list for given `GTTONKey` key
- (void)exportWordsForKey:(GTTONKey *)key
         withUserPassword:(NSData *)userPassword
          completionBlock:(void (^)(NSArray<NSString *> * _Nullable words, NSError * _Nullable error))completionBlock
                requestID:(GTRequestID * _Nullable)requestID;

// Decrypt encrypted content of messages
- (void)decryptMessagesWithKey:(GTTONKey *)key
                  userPassword:(NSData *)userPassword
                      messages:(NSArray<GTEncryptedData *> *)messages
               completionBlock:(void (^)(NSArray<id<GTTransactionMessageContents>> * _Nullable contents, NSError * _Nullable error))completionBlock
                     requestID:(GTRequestID * _Nullable)requestID;

#pragma mark - Account methods

// Returns walletd address ID for given `publicKey`
- (void)accountAddressWithCode:(NSData *)code
                          data:(NSData *)data
                     workchain:(int32_t)workchain
               completionBlock:(void(^ _Nonnull)(NSString * _Nullable address, NSError * _Nullable error))completionBlock
                     requestID:(GTRequestID * _Nullable)requestID;

// Returns account `GTAccountState` for given address
- (void)accountStateWithAddress:(NSString *)accountAddress
                completionBlock:(void (^)(GTAccountState * _Nullable accountState, NSError * _Nullable error))completionBlock
                      requestID:(GTRequestID * _Nullable)requestID;

// Returns local id of account with given address (run local TVM machine)
- (void)accountLocalIDWithAccountAddress:(NSString *)accountAddress
                         completionBlock:(void (^)(int64_t localID, NSError * _Nullable error))completionBlock
                               requestID:(GTRequestID * _Nullable)requestID;

// Returns result of execution `methodName` for account with given `accountLocalID`  (run local TVM machine)
- (void)accountLocalID:(int64_t)accountLocalID
     runGetMethodNamed:(NSString *)methodName
             arguments:(NSArray<GTExecutionStackValue> *)arguments
       completionBlock:(void (^)(GTExecutionResult * _Nullable accountState, NSError * _Nullable error))completionBlock
             requestID:(GTRequestID * _Nullable)requestID;

#pragma mark - Queries

// Prepare raw query
- (void)prepareQueryWithDestinationAddress:(NSString *)destinationAddress
                   initialAccountStateData:(NSData * _Nullable)initialAccountStateData
                   initialAccountStateCode:(NSData * _Nullable)initialAccountStateCode
                                      body:(NSData *)body
                           completionBlock:(void (^)(GTPreparedQuery * _Nullable, NSError * _Nullable))completionBlock
                                 requestID:(GTRequestID * _Nullable)requestID;

// Estimate fees for prepared query
- (void)estimateFeesForPreparedQueryWithID:(int64_t)preparedQueryID
                           completionBlock:(void (^)(GTFeesQuery * _Nullable fees, NSError * _Nullable error))completionBlock
                                 requestID:(GTRequestID * _Nullable)requestID;

// Commit and send prepared query
- (void)sendPreparedQueryWithID:(int64_t)preparedQueryID
                completionBlock:(void (^)(NSError * _Nullable error))completionBlock
                      requestID:(GTRequestID * _Nullable)requestID;

// Removes local message
- (void)deletePreparedQueryWithID:(int64_t)preparedQueryID
                  completionBlock:(void (^)(NSError * _Nullable error))completionBlock
                        requestID:(GTRequestID * _Nullable)_requestID;

#pragma mark - DNS

- (void)resolvedDNSWithRootDNSAccountAddress:(NSString * _Nullable)rootDNSAccountAddress
                                  domainName:(NSString *)domainName
                                    category:(NSString *)category
                                         ttl:(int32_t)ttl
                             completionBlock:(void (^)(GTDNS * _Nullable result, NSError * _Nullable error))completionBlock
                                   requestID:(GTRequestID * _Nullable)_requestID;

#pragma mark - Transactions

- (void)transactionsForAccountAddress:(NSString *)accountAddress
                    lastTransactionID:(GTTransactionID *)transactionID
                      completionBlock:(void (^)(NSArray<GTTransaction *> * _Nullable result, NSError * _Nullable error))completionBlock
                            requestID:(GTRequestID * _Nullable)requestID;

@end

NS_ASSUME_NONNULL_END
