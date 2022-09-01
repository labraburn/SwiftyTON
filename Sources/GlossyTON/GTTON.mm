//
//  Created by Anton Spivak
//

#import "GTTON.h"
#import "GTTONConfiguration.h"
#import "GTThreadParameters.h"
#import "GTURLRequest.h"
#import "GTQueue.h"
#import "GTTONKey.h"
#import "GTRequestHandler.h"
#import "NSError+GT.h"
#import "GTTransaction.h"
#import "GTAccountState.h"
#import "GTExecutionResult.h"
#import "GTPreparedQuery.h"
#import "GTFees.h"
#import "GTEncryptedData.h"
#import "GTRequestID+Internal.h"
#import "GTDNS.h"
#import "NSData+SHA256.h"

using tonlib_api::make_object;

typedef void (^GTTONExternalRequestHandler)(GTURLRequest * _Nonnull);
typedef void (^GTTONSynchronizationHandler)(double);

@interface GTTON ()

@property (nonatomic, weak, readonly) NSThread *thread;
@property (nonatomic, assign, readonly) std::shared_ptr<tonlib::Client> client;

@property (nonatomic, strong, readonly) GTRequestHandlerStorage *handlerStorage;
@property (nonatomic, strong) GTQueue *queue;

@property (nonatomic, strong, nullable) GTTONConfiguration *configuration;

@end

@implementation GTTON

@synthesize client = _client;

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _queue = [GTQueue main];
        _handlerStorage = [[GTRequestHandlerStorage alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self.thread cancel];
}

- (void)initializeWithConfiguration:(GTTONConfiguration *)configuration
                    completionBlock:(GTTONInitializationHandler)completionBlock
{
    [self enableLoggingIfNeededWithConfiguration:configuration];
    [self initializeThreadIfNeeded];
    
    self.configuration = configuration;
    [self requestInitializeWithConfiguration:configuration
                    isExternalRequestEnabled:[self isExternalRequestsEnabled]
                             completionBlock:completionBlock];
}

#pragma mark - Setters & Getters

- (std::shared_ptr<tonlib::Client>)client {
    if (_client == NULL) {
        _client = std::make_shared<tonlib::Client>();
    }
    return _client;
}

- (void)initializeThreadIfNeeded {
    if (self.thread != nil && self.thread.isExecuting) {
        return;
    }
    
    Class klass = [self class];
    std::weak_ptr<tonlib::Client> wclient = self.client;
    
    @weakify(self);
    GTThreadParameters *parameters = [[GTThreadParameters alloc] initWithClient:self.client handler:^(tonlib::Client::Response & response) {
        
        GTTONExternalRequestHandler externalRequestHandler = ^(GTURLRequest *request) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(ton:didRequiredPerfromURLRequest:)]) {
                [self.delegate ton:self didRequiredPerfromURLRequest:request];
            }
        };
        
        GTTONSynchronizationHandler synchronizationHandler = ^(double progress) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(ton:didUpdateSynchronizationProgress:)]) {
                [self.delegate ton:self didUpdateSynchronizationProgress:progress];
            }
        };
        
        @strongify(self);
        [klass didReceiveResponse:response
                       withClient:wclient
                   handlerStorage:self.handlerStorage
           externalRequestHandler:[externalRequestHandler copy]
           synchronizationHandler:[synchronizationHandler copy]];
    }];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:klass
                                               selector:@selector(threadDidReceiveParameters:)
                                                 object:parameters];
    [thread start];
    _thread = thread;
}

#pragma mark - Logging

- (void)enableLoggingIfNeededWithConfiguration:(GTTONConfiguration *)configuration {
    GTTONConfigurationLogging logging = configuration.logging;
    
    #if !DEBUG
    logging = GTTONConfigurationLoggingNever;
    #endif
    
    if (logging == GTTONConfigurationLoggingNever) {
        auto query = make_object<tonlib_api::setLogStream>(make_object<tonlib_api::logStreamEmpty>());
        self.client->execute({ INT16_MAX + 1, std::move(query) });
        return;
    }
    
    auto squery = make_object<tonlib_api::setLogStream>(make_object<tonlib_api::logStreamDefault>());
    self.client->execute({ INT16_MAX + 1, std::move(squery) });
    
    int32_t level = (int32_t)logging;
    auto vquery = make_object<tonlib_api::setLogVerbosityLevel>(level);
    self.client->execute({ INT16_MAX + 1, std::move(vquery) });
}

#pragma mark - Requests

- (GTRequestID *)requestInitializeWithConfiguration:(GTTONConfiguration *)configuration
                           isExternalRequestEnabled:(BOOL)isExternalRequestEnabled
                                    completionBlock:(void (^ _Nonnull)(NSError * _Nullable error))completionBlock
{
    NSNumber *requestID = [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock([NSError errorWithCancelledMessage]);
                return;
            }
            
            NSError *error = nil;
            if (object->get_id() == tonlib_api::error::ID) {
                auto terror = tonlib_api::move_object_as<tonlib_api::error>(object);
                error = [NSError errorWithTONError:terror];
            }
            
            completionBlock(error);
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        BOOL isCacheIgnored = [self isCacheIgnored];
        
        NSString *networkString = configuration.networkName;
        NSString *conigurationString = configuration.JSONString;
        NSString *keystorePath = configuration.keystoreURL.relativePath;
        
        auto query = make_object<tonlib_api::init>(make_object<tonlib_api::options>(
            make_object<tonlib_api::config>(conigurationString.UTF8String, networkString.UTF8String, isExternalRequestEnabled, isCacheIgnored),
            make_object<tonlib_api::keyStoreTypeDirectory>(keystorePath.UTF8String)
        ));
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
    
    return [[GTRequestID alloc] initWithNumber:requestID];
}

- (GTRequestID *)generateRequestID {
    NSNumber *number = [self.handlerStorage generateRequestID];
    return [[GTRequestID alloc] initWithNumber:number];
}

- (void)cancelRequestID:(GTRequestID *)requestID {
    [self.handlerStorage markRequestHandlerCancelledForRequestID:requestID.number];
}

#pragma mark - NSThread

+ (void)threadDidReceiveParameters:(GTThreadParameters *)parameters {
    while (true) {
        @autoreleasepool {
            auto response = parameters.client->receive(1000);
            if (response.object) {
                parameters.handler(response);
            }
            
            if ([[NSThread currentThread] isCancelled]) {
                parameters = nil;
                [NSThread exit];
                return;
            }
        }
    }
}

+ (void)didReceiveResponse:(tonlib::Client::Response &)response
                withClient:(std::weak_ptr<tonlib::Client>)client
            handlerStorage:(GTRequestHandlerStorage *)handlerStorage
    externalRequestHandler:(GTTONExternalRequestHandler _Nullable)externalRequestHandler
    synchronizationHandler:(GTTONSynchronizationHandler _Nullable)synchronizationHandler
{
    if (response.object->get_id() == tonlib_api::updateSendLiteServerQuery::ID) {
        if (externalRequestHandler == nil) {
            return;
        }
        
        auto result = tonlib_api::move_object_as<tonlib_api::updateSendLiteServerQuery>(response.object);
        int64_t requestID = result->id_;
        NSData *data = GTDataWithString(result->data_);
        
        GTURLRequest *request = [[GTURLRequest alloc] initWithData:data didFinishBlock:^(NSData * _Nullable response, NSError * _Nullable error) {
            auto sclient = client.lock();
            if (sclient == nullptr) {
                return;
            }
            
            if (response != nil) {
                auto query = make_object<tonlib_api::onLiteServerQueryResult>(requestID, GTStringWithData(response));
                sclient->send({ 1, std::move(query) });
            } else {
                NSString *message = (error.localizedDescription ?: @"Undefined error.");
                int32_t code = (int32_t)error.code;
                
                auto query = make_object<tonlib_api::onLiteServerQueryError>(requestID, make_object<tonlib_api::error>(code, message.UTF8String));
                sclient->send({ 1, std::move(query) });
            }
        }];
        
        externalRequestHandler(request);
    } else if (response.object->get_id() == tonlib_api::updateSyncState::ID) {
        if (synchronizationHandler == nil) {
            return;
        }
        
        auto result = tonlib_api::move_object_as<tonlib_api::updateSyncState>(response.object);
        switch (result->sync_state_->get_id()) {
            case tonlib_api::syncStateInProgress::ID: {
                auto syncStateInProgress = tonlib_api::move_object_as<tonlib_api::syncStateInProgress>(result->sync_state_);
                
                int32_t currentDelta = syncStateInProgress->current_seqno_ - syncStateInProgress->from_seqno_;
                int32_t fullDelta = syncStateInProgress->to_seqno_ - syncStateInProgress->from_seqno_;
                double progress = ((double)currentDelta) / ((double)fullDelta);
                
                if (currentDelta > 0 && fullDelta > 0) {
                    synchronizationHandler(progress);
                } else {
                    synchronizationHandler(0.0f);
                }
                
                break;
            }
            case tonlib_api::syncStateDone::ID: {
                synchronizationHandler(1.0f);
                break;
            }
            default: {
                break;
            }
        }
    } else {
        NSNumber *responseID = @(response.id);
        GTRequestHandler *handler = [handlerStorage requestHandlerForRequestID:responseID];
        
        if (handler == nil) {
            return;
        }
        
        [handlerStorage removeRequestHandlerForRequestID:responseID];
        handler.completionBlock(handler, response.object);
    }
}

#pragma mark - Internal

- (BOOL)isExternalRequestsEnabled {
    return [self.delegate respondsToSelector:@selector(ton:didRequiredPerfromURLRequest:)];
}

- (BOOL)isCacheIgnored {
    return NO;
}

@end

@implementation GTTON (API)

#pragma mark - Confugarion methods

- (void)validateCurrentConfigurationWithCompletionBlock:(void(^ _Nonnull)(int64_t prefixWalletID, NSError * _Nullable error))completionBlock
                                              requestID:(GTRequestID * _Nullable)_requestID
{
    if (self.configuration == nil) {
        completionBlock(-1, [NSError errorWithTONMessage:@"Configuration not set."]);
        return;
    }
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(-1, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(-1, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::options_configInfo::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::options_configInfo>(object);
                completionBlock(result->default_wallet_id_, nil);
            } else {
                assert(false);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        NSString *networkString = self.configuration.networkName;
        NSString *conigurationString = self.configuration.JSONString;
        NSString *keystorePath = self.configuration.keystoreURL.relativePath;
        
        auto query = make_object<tonlib_api::options_validateConfig>(
            make_object<tonlib_api::config>(conigurationString.UTF8String,networkString.UTF8String, true, false)
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)updateConfiguration:(GTTONConfiguration *)configuration
            completionBlock:(void (^)(NSError * _Nullable error))completionBlock
                  requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        [self enableLoggingIfNeededWithConfiguration:configuration];
        self.configuration = configuration;
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock([NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock([NSError errorWithTONError:error]);
            } else {
                completionBlock(nil);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        NSString *networkString = configuration.networkName;
        NSString *conigurationString = configuration.JSONString;
        BOOL isExternalRequestsEnabled = [self isExternalRequestsEnabled];
        
        auto query = make_object<tonlib_api::options_setConfig>(
            make_object<tonlib_api::config>(
                conigurationString.UTF8String,
                networkString.UTF8String,
                isExternalRequestsEnabled,
                false
            )
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

#pragma mark - Keys methods

- (void)createKeyWithUserPassword:(NSData *)userPassword
                 mnemonicPassword:(NSData *)mnemonicPassword
                  completionBlock:(void(^ _Nonnull)(GTTONKey * _Nullable key, NSError * _Nullable error))completionBlock
                        requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::key::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::key>(object);
                
                NSData *publicKeyData = [[NSData alloc] initWithBytes:result->public_key_.data() length:result->public_key_.length()];
                NSString *publicKey = [[NSString alloc] initWithData:publicKeyData encoding:NSUTF8StringEncoding];
                
                if (publicKey == nil) {
                    completionBlock(nil, [NSError errorWithTONMessage:@"Can't decode (UTF8) from `tonlib_api::createNewKey` query."]);
                    return;
                }
                
                NSData *secretData = [[NSData alloc] initWithBytes:result->secret_.data()
                                                        length:result->secret_.length()];
                
                GTTONKey *key = [[GTTONKey alloc] initWithPublicKey:publicKey
                                                 encryptedSecretKey:secretData];
                
                completionBlock(key, nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::createNewKey` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::createNewKey>(
            GTSecureStringWithData(userPassword),
            GTSecureStringWithData(mnemonicPassword),
            td::SecureString()
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)importKeyWithUserPassword:(NSData *)userPassword
                 mnemonicPassword:(NSData *)mnemonicPassword
                            words:(NSArray<NSString *> *)words
                  completionBlock:(void(^ _Nonnull)(GTTONKey * _Nullable key, NSError * _Nullable error))completionBlock
                        requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::key::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::key>(object);
                
                NSData *publicKeyData = [[NSData alloc] initWithBytes:result->public_key_.data() length:result->public_key_.length()];
                NSString *publicKey = [[NSString alloc] initWithData:publicKeyData encoding:NSUTF8StringEncoding];
                
                if (publicKey == nil) {
                    completionBlock(nil, [NSError errorWithTONMessage:@"Can't decode (UTF8) from `tonlib_api::importKey` query."]);
                    return;
                }
                
                NSData *secretKeyData = [[NSData alloc] initWithBytes:result->secret_.data()
                                                               length:result->secret_.length()];
                
                GTTONKey *key = [[GTTONKey alloc] initWithPublicKey:publicKey
                                                 encryptedSecretKey:secretKeyData];
                
                completionBlock(key, nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::importKey` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        __block std::vector<td::SecureString> vector;
        [words enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
            vector.push_back(GTSecureStringWithData(data));
        }];
        
        auto query = make_object<tonlib_api::importKey>(
            GTSecureStringWithData(userPassword),
            GTSecureStringWithData(mnemonicPassword),
            make_object<tonlib_api::exportedKey>(std::move(vector))
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)deleteKey:(GTTONKey *)key
  completionBlock:(void (^)(NSError * _Nullable error))completionBlock
        requestID:(GTRequestID * _Nullable)_requestID
{
    NSData *publicKeyData = [key.publicKey dataUsingEncoding:NSUTF8StringEncoding];
    if (publicKeyData == nil) {
        completionBlock([NSError errorWithTONMessage:@"Can't encode (UTF8) publicKey."]);
        return;
    }
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock([NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock([NSError errorWithTONError:error]);
            } else {
                completionBlock(nil);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::deleteKey>(
            make_object<tonlib_api::key>(
                GTStringWithData(publicKeyData),
                GTSecureStringWithData(key.encryptedSecretKey)
            )
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)deleteAllKeysWithCompletionBlock:(void (^)(NSError * _Nullable error))completionBlock
                               requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock([NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock([NSError errorWithTONError:error]);
            } else {
                completionBlock(nil);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::deleteAllKeys>();
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

#pragma mark - Security methods

- (void)exportDecryptedKeyWithEncryptedKey:(GTTONKey *)encryptedKey
                          withUserPassword:(NSData *)userPassword
                           completionBlock:(void(^ _Nonnull)(NSData * _Nullable decryptedSecretKey, NSError * _Nullable error))completionBlock
                                 requestID:(GTRequestID * _Nullable)_requestID
{
    NSData *publicKeyData = [encryptedKey.publicKey dataUsingEncoding:NSUTF8StringEncoding];
    if (publicKeyData == nil) {
        completionBlock(nil, [NSError errorWithTONMessage:@"Can't encode (UTF8) publicKey."]);
        return;
    }
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::exportedUnencryptedKey::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::exportedUnencryptedKey>(object);
                NSData *data = GTReadSecureStringWithString(result->data_);
                completionBlock(GTReadSecureStringWithString(result->data_), nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::exportUnencryptedKey` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::exportUnencryptedKey>(
            make_object<tonlib_api::inputKeyRegular>(
                make_object<tonlib_api::key>(
                    GTStringWithData(publicKeyData),
                    GTSecureStringWithData(encryptedKey.encryptedSecretKey)
                ),
                GTSecureStringWithData(userPassword)
            )
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)exportWordsForKey:(GTTONKey *)key
         withUserPassword:(NSData *)userPassword
          completionBlock:(void (^)(NSArray<NSString *> * _Nullable words, NSError * _Nullable error))completionBlock
                requestID:(GTRequestID * _Nullable)_requestID
{
    NSData *publicKeyData = [key.publicKey dataUsingEncoding:NSUTF8StringEncoding];
    if (publicKeyData == nil) {
        completionBlock(nil, [NSError errorWithTONMessage:@"Can't encode (UTF8) publicKey."]);
        return;
    }
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::exportedKey::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::exportedKey>(object);
                
                NSMutableArray *words = [[NSMutableArray alloc] init];
                for (auto &it : result->word_list_) {
                    NSData *wordData = [[NSData alloc] initWithBytes:it.data() length:it.size()];
                    NSString *word = [[NSString alloc] initWithData:wordData encoding:NSUTF8StringEncoding];
                    
                    if (word == nil) {
                        completionBlock(nil, [NSError errorWithTONMessage:@"Can't decode (UTF8) from `exportedKey::word_list` query."]);
                        return;
                    }
                    
                    [words addObject:word];
                }
                
                completionBlock([words copy], nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::exportKey` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::exportKey>(
            make_object<tonlib_api::inputKeyRegular>(
                make_object<tonlib_api::key>(
                    GTStringWithData(publicKeyData),
                    GTSecureStringWithData(key.encryptedSecretKey)
                ),
                GTSecureStringWithData(userPassword)
            )
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)decryptMessagesWithKey:(GTTONKey *)key
                  userPassword:(NSData *)userPassword
                      messages:(NSArray<GTEncryptedData *> *)messages
               completionBlock:(void (^)(NSArray<id<GTTransactionMessageContents>> * _Nullable contents, NSError * _Nullable error))completionBlock
                     requestID:(GTRequestID * _Nullable)_requestID
{
    NSData *publicKeyData = [key.publicKey dataUsingEncoding:NSUTF8StringEncoding];
    if (publicKeyData == nil) {
        completionBlock(nil, [NSError errorWithTONMessage:@"Can't encode (UTF8) publicKey."]);
        return;
    }
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::msg_dataDecryptedArray::ID) {
                auto result_ = tonlib_api::move_object_as<tonlib_api::msg_dataDecryptedArray>(object);
                if (result_->elements_.size() != messages.count) {
                    completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::msg_decrypt` query."]);
                } else {
                    NSMutableArray<id<GTTransactionMessageContents>> *result = [[NSMutableArray alloc] init];
                    int index = 0;
                    for (auto &it : result_->elements_) {
                        if (it->data_->get_id() == tonlib_api::msg_dataDecryptedText::ID) {
                            auto dataDecryptedText = tonlib_api::move_object_as<tonlib_api::msg_dataDecryptedText>(it->data_);
                            NSString *decryptedString = GTReadStringWithString(dataDecryptedText->text_);
                            if (decryptedString != nil) {
                                [result addObject:[[GTTransactionMessageContentsPlainText alloc] initWithText:decryptedString]];
                            } else {
                                [result addObject:[[GTTransactionMessageContentsEncryptedText alloc] initWithEncryptedData:messages[index]]];
                            }
                        } else {
                            [result addObject:[[GTTransactionMessageContentsEncryptedText alloc] initWithEncryptedData:messages[index]]];
                        }
                        index++;
                    }
                    completionBlock([result copy], nil);
                }
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::msg_decrypt` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        __block std::vector<tonlib_api::object_ptr<tonlib_api::msg_dataEncrypted>> inputData;
        [messages enumerateObjectsUsingBlock:^(GTEncryptedData * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *sourceAddressData = [message.sourceAccountAddress dataUsingEncoding:NSUTF8StringEncoding];
            if (sourceAddressData == nil) {
                return;
            }
            
            inputData.push_back(make_object<tonlib_api::msg_dataEncrypted>(
                make_object<tonlib_api::accountAddress>(
                    GTStringWithData(sourceAddressData)
                ),
                make_object<tonlib_api::msg_dataEncryptedText>(
                    GTStringWithData(message.data)
                )
            ));
        }];
        
        auto query = make_object<tonlib_api::msg_decrypt>(
            make_object<tonlib_api::inputKeyRegular>(
                make_object<tonlib_api::key>(
                    GTStringWithData(publicKeyData),
                    GTSecureStringWithData(key.encryptedSecretKey)
                ),
                GTSecureStringWithData(userPassword)
            ),
            make_object<tonlib_api::msg_dataEncryptedArray>(
                std::move(inputData)
            )
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

#pragma mark - Account methods

- (void)accountAddressWithCode:(NSData *)code
                          data:(NSData *)data
                     workchain:(int32_t)workchain
               completionBlock:(void(^ _Nonnull)(NSString * _Nullable address, NSError * _Nullable error))completionBlock
                     requestID:(GTRequestID * _Nullable)_requestID
{
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::accountAddress::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::accountAddress>(object);
                NSString *address = [[NSString alloc] initWithUTF8String:result->account_address_.c_str()];
                if (address == nil) {
                    completionBlock(nil, [NSError errorWithTONMessage:@"Can't decode (UTF8) from `tonlib_api::getAccountAddress` query."]);
                    return;
                }
                completionBlock(address, nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::getAccountAddress` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        tonlib_api::object_ptr<tonlib_api::InitialAccountState> initialAccountState = tonlib_api::move_object_as<tonlib_api::InitialAccountState>(make_object<tonlib_api::raw_initialAccountState>(
            GTStringWithData(code),
            GTStringWithData(data)
        ));
        
        auto query = make_object<tonlib_api::getAccountAddress>(
            tonlib_api::move_object_as<tonlib_api::InitialAccountState>(initialAccountState),
            0, // revision is empty because we manually passed the initial data
            workchain
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)accountStateWithAddress:(NSString *)accountAddress
                completionBlock:(void (^)(GTAccountState * _Nullable, NSError * _Nullable))completionBlock
                      requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::raw_fullAccountState::ID) {
                auto rawAccountState = tonlib_api::move_object_as<tonlib_api::raw_fullAccountState>(object);
                
                GTTransactionID *lastTransactionID = nil;
                if (rawAccountState->last_transaction_id_ != nullptr) {
                    NSData *transactionHashData = GTDataWithString(rawAccountState->last_transaction_id_->hash_);
                    lastTransactionID = [[GTTransactionID alloc] initWithLogicalTime:rawAccountState->last_transaction_id_->lt_
                                                                     transactionHash:transactionHashData];
                }
                
                GTAccountState *account = [[GTAccountState alloc] initWithCode:GTDataWithString(rawAccountState->code_)
                                                                          data:GTDataWithString(rawAccountState->data_)
                                                             lastTransactionID:lastTransactionID
                                                                       balance:rawAccountState->balance_
                                                                      synctime:rawAccountState->sync_utime_];
                completionBlock(account, nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::raw_getAccountState` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::raw_getAccountState>(
            make_object<tonlib_api::accountAddress>(accountAddress.UTF8String)
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)accountLocalIDWithAccountAddress:(NSString *)accountAddress
                         completionBlock:(void (^)(int64_t, NSError * _Nullable))completionBlock
                               requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(-1, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(-1, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::smc_info::ID) {
                auto info = tonlib_api::move_object_as<tonlib_api::smc_info>(object);
                completionBlock(info->id_, nil);
            } else {
                completionBlock(-1, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::smc_load` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::smc_load>(
            make_object<tonlib_api::accountAddress>(accountAddress.UTF8String)
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)accountLocalID:(int64_t)smartcontractID
     runGetMethodNamed:(NSString *)methodName
             arguments:(NSArray<GTExecutionStackValue> *)arguments
       completionBlock:(void (^)(GTExecutionResult * _Nullable, NSError * _Nullable))completionBlock
             requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    id (^parser)(tonlib_api::object_ptr<tonlib_api::tvm_StackEntry> &) = ^id (tonlib_api::object_ptr<tonlib_api::tvm_StackEntry> &entry) {
        if (entry->get_id() == tonlib_api::tvm_stackEntryNumber::ID) {
            auto entryNumber = tonlib_api::move_object_as<tonlib_api::tvm_stackEntryNumber>(entry);
            NSString *value = GTReadStringWithString(entryNumber->number_->number_);
            return [[GTExecutionResultDecimal alloc] initWithValue:value];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntrySlice::ID) {
            auto entrySlice = tonlib_api::move_object_as<tonlib_api::tvm_stackEntrySlice>(entry);
            NSData *data = GTDataWithString(entrySlice->slice_->bytes_);
            return [[GTExecutionResultSlice alloc] initWithHEX:data];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntryCell::ID) {
            auto entryCell = tonlib_api::move_object_as<tonlib_api::tvm_stackEntryCell>(entry);
            NSData *data = GTDataWithString(entryCell->cell_->bytes_);
            return [[GTExecutionResultCell alloc] initWithHEX:data];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntryTuple::ID) {
            auto entryTuple = tonlib_api::move_object_as<tonlib_api::tvm_stackEntryTuple>(entry);
            NSMutableArray<GTExecutionStackValue> *enumeration = (NSMutableArray<GTExecutionStackValue> *)[[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < entryTuple->tuple_->elements_.size(); i++) {
                auto _element = tonlib_api::move_object_as<tonlib_api::tvm_StackEntry>(entryTuple->tuple_->elements_[i]);
                id _parsed = parser(_element);
                if (_element != nil) {
                    [enumeration addObject:_parsed];
                }
            }
            return [[GTExecutionResultEnumeration alloc] initWithEnumeration:enumeration];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntryList::ID) {
            auto entryList = tonlib_api::move_object_as<tonlib_api::tvm_stackEntryList>(entry);
            NSMutableArray<GTExecutionStackValue> *enumeration = (NSMutableArray<GTExecutionStackValue> *)[[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < entryList->list_->elements_.size(); i++) {
                auto _element = tonlib_api::move_object_as<tonlib_api::tvm_StackEntry>(entryList->list_->elements_[i]);
                id _parsed = parser(_element);
                if (_element != nil) {
                    [enumeration addObject:_parsed];
                }
            }
            return [[GTExecutionResultEnumeration alloc] initWithEnumeration:enumeration];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntryUnsupported::ID) {
            return nil;
        } else {
            return nil;
        };
    };
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::smc_runResult::ID) {
                auto runResult = tonlib_api::move_object_as<tonlib_api::smc_runResult>(object);
                
                NSMutableArray<GTExecutionStackValue> *stack = (NSMutableArray<GTExecutionStackValue> *)[[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < runResult->stack_.size(); i++) {
                    auto entry = tonlib_api::move_object_as<tonlib_api::tvm_StackEntry>(runResult->stack_[i]);
                    id parsed = parser(entry);
                    if (parsed != nil) {
                        [stack addObject:parsed];
                    }
                }
                
                GTExecutionResult *result = [[GTExecutionResult alloc] initWithCode:runResult->exit_code_
                                                                              stack:stack];
                
                completionBlock(result, nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::smc_runGetMethod` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        __block std::vector<tonlib_api::object_ptr<tonlib_api::tvm_StackEntry>> _arguments;
        [arguments enumerateObjectsUsingBlock:^(id<GTExecutionStackValue> obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[GTExecutionResultCell class]]) {
                GTExecutionResultCell *cell = (GTExecutionResultCell *)obj;
                _arguments.push_back(
                    make_object<tonlib_api::tvm_stackEntryCell>(
                        make_object<tonlib_api::tvm_cell>(GTStringWithData(cell.hex))
                    )
                );
            } else if ([obj isKindOfClass:[GTExecutionResultSlice class]]) {
                GTExecutionResultSlice *cell = (GTExecutionResultSlice *)obj;
                _arguments.push_back(
                    make_object<tonlib_api::tvm_stackEntrySlice>(
                        make_object<tonlib_api::tvm_slice>(GTStringWithData(cell.hex))
                    )
                );
            } else {
                NSLog(@"Unsupported argument type: %@", [obj class]);
            }
        }];
        
        auto query = make_object<tonlib_api::smc_runGetMethod>(
            smartcontractID,
            make_object<tonlib_api::smc_methodIdName>(methodName.UTF8String),
            std::move(_arguments)
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

#pragma mark - Queries

- (void)prepareQueryWithDestinationAddress:(NSString *)destinationAddress
                   initialAccountStateData:(NSData * _Nullable)initialAccountStateData
                   initialAccountStateCode:(NSData * _Nullable)initialAccountStateCode
                                      body:(NSData *)body
                           completionBlock:(void (^)(GTPreparedQuery * _Nullable, NSError * _Nullable))completionBlock
                                 requestID:(GTRequestID * _Nullable)_requestID
{
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::query_info::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::query_info>(object);
                GTPreparedQuery *query = [[GTPreparedQuery alloc] initWithQueryID:result->id_
                                                           validUntilTimeInterval:result->valid_until_
                                                                             body:GTDataWithString(result->body_)
                                                                         bodyHash:GTDataWithString(result->body_hash_)];
                completionBlock(query, nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::createQuery` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];

        auto query = make_object<tonlib_api::raw_createQuery>(
            make_object<tonlib_api::accountAddress>(destinationAddress.UTF8String),
            GTStringWithData(initialAccountStateCode ?: [NSData new]),
            GTStringWithData(initialAccountStateData ?: [NSData new]),
            GTStringWithData(body)
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)estimateFeesForPreparedQueryWithID:(int64_t)preparedQueryID
                           completionBlock:(void (^)(GTFeesQuery * _Nullable fees, NSError * _Nullable error))completionBlock
                                 requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::query_fees::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::query_fees>(object);
                GTFees *sourceFees = [[GTFees alloc] initWithInFwdFee:result->source_fees_->in_fwd_fee_
                                                           storageFee:result->source_fees_->storage_fee_
                                                               gasFee:result->source_fees_->gas_fee_
                                                               fwdFee:result->source_fees_->fwd_fee_];
                
                NSMutableArray<GTFees *> *destinationFees = [[NSMutableArray alloc] init];
                for (auto &fee : result->destination_fees_) {
                    GTFees *destinationFee = [[GTFees alloc] initWithInFwdFee:fee->in_fwd_fee_
                                                                   storageFee:fee->storage_fee_
                                                                       gasFee:fee->gas_fee_
                                                                       fwdFee:fee->fwd_fee_];
                    [destinationFees addObject:destinationFee];
                }
                
                GTFeesQuery *queryFees = [[GTFeesQuery alloc] initWithSourceFees:sourceFees
                                                                 destinationFees:destinationFees];
                
                completionBlock(queryFees, nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::query_estimateFees` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::query_estimateFees>(
            preparedQueryID,
            true
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)sendPreparedQueryWithID:(int64_t)preparedQueryID
                completionBlock:(void (^)(NSError * _Nullable error))completionBlock
                      requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock([NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock([NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::ok::ID) {
                completionBlock(nil);
            } else {
                completionBlock([NSError errorWithTONMessage:@"Undefined error from `tonlib_api::query_send` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::query_send>(
            preparedQueryID
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

- (void)deletePreparedQueryWithID:(int64_t)preparedQueryID
                  completionBlock:(void (^)(NSError * _Nullable error))completionBlock
                        requestID:(GTRequestID * _Nullable)_requestID
{
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock([NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock([NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::ok::ID) {
                completionBlock(nil);
            } else {
                completionBlock([NSError errorWithTONMessage:@"Undefined error from `tonlib_api::query_send` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::query_forget>(
            preparedQueryID
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

#pragma mark - DNS

- (void)resolvedDNSWithRootDNSAccountAddress:(NSString * _Nullable)rootDNSAccountAddress
                                  domainName:(NSString *)domainName
                                    category:(NSString *)category
                                         ttl:(int32_t)ttl
                             completionBlock:(void (^)(GTDNS * _Nullable result, NSError * _Nullable error))completionBlock
                                   requestID:(GTRequestID * _Nullable)_requestID
{
    NSData *rootDNSAddressData = [rootDNSAccountAddress dataUsingEncoding:NSUTF8StringEncoding];
    if (rootDNSAddressData == nil) {
        rootDNSAddressData = [NSData new];
    }
    
    NSData *domainNameData = [domainName dataUsingEncoding:NSUTF8StringEncoding];
    if (domainNameData == nil) {
        completionBlock(nil, [NSError errorWithTONMessage:@"Can't encode (UTF8) domainName."]);
        return;
    }
    
    NSData *categoryData = [[category dataUsingEncoding:NSUTF8StringEncoding] sha256];
    if (categoryData == nil && [categoryData length] == 32) {
        completionBlock(nil, [NSError errorWithTONMessage:@"Can't encode (UTF8) category."]);
        return;
    }
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::dns_resolved::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::dns_resolved>(object);
                
                NSMutableArray<GTDNSEntry> *entries = (NSMutableArray<GTDNSEntry> *)[NSMutableArray new];
                for (auto &resolved_entry : result->entries_) {
                    if (resolved_entry->entry_->get_id() == tonlib_api::dns_entryDataText::ID) {
                        auto dns_entryDataText = tonlib_api::move_object_as<tonlib_api::dns_entryDataText>(resolved_entry->entry_);
                        GTDNSEntryText *entry = [[GTDNSEntryText alloc] initWithText:GTReadStringWithString(dns_entryDataText->text_)];
                        [entries addObject:entry];
                    } else if (resolved_entry->entry_->get_id() == tonlib_api::dns_entryDataNextResolver::ID) {
                        auto dns_entryDataNextResolver = tonlib_api::move_object_as<tonlib_api::dns_entryDataNextResolver>(resolved_entry->entry_);
                        NSString *address = GTReadStringWithString(dns_entryDataNextResolver->resolver_->account_address_);
                        GTDNSEntryNextResolver *entry = [[GTDNSEntryNextResolver alloc] initWithAddress:address];
                        [entries addObject:entry];
                    } else if (resolved_entry->entry_->get_id() == tonlib_api::dns_entryDataSmcAddress::ID) {
                        auto dns_entryDataSmcAddress = tonlib_api::move_object_as<tonlib_api::dns_entryDataSmcAddress>(resolved_entry->entry_);
                        NSString *address = GTReadStringWithString(dns_entryDataSmcAddress->smc_address_->account_address_);
                        GTDNSEntrySMCAddress *entry = [[GTDNSEntrySMCAddress alloc] initWithAddress:address];
                        [entries addObject:entry];
                    } else if (resolved_entry->entry_->get_id() == tonlib_api::dns_entryDataAdnlAddress::ID) {
                        auto dns_entryDataText = tonlib_api::move_object_as<tonlib_api::dns_entryDataAdnlAddress>(resolved_entry->entry_);
                        continue;
                    } else {
                        continue;
                    }
                }
                
                GTDNS *dns = [[GTDNS alloc] initWithName:domainName
                                                 entries:entries];
                completionBlock(dns, nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::dns_resolve` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        
        auto category_bytes = std::array<unsigned char, 32>();
        const char *categoryDataBytes = (const char *)[categoryData bytes];
        for (int i = 0; i < [categoryData length]; i++) {
            category_bytes[i] = (unsigned char)categoryDataBytes[i];
        }
        
        auto query = make_object<tonlib_api::dns_resolve>(
            [rootDNSAddressData length] > 0 ? make_object<tonlib_api::accountAddress>(GTStringWithData(rootDNSAddressData)) : std::nullptr_t(),
            GTStringWithData(domainNameData),
            td::Bits256(category_bytes),
            ttl
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

#pragma mark - Transactions

- (void)transactionsForAccountAddress:(NSString *)accountAddress
                    lastTransactionID:(GTTransactionID *)transactionID
                      completionBlock:(void (^)(NSArray<GTTransaction *> * _Nullable result, NSError * _Nullable error))completionBlock
                            requestID:(GTRequestID * _Nullable)_requestID
{
    NSData *accounAddressData = [accountAddress dataUsingEncoding:NSUTF8StringEncoding];
    if (accounAddressData == nil) {
        completionBlock(nil, [NSError errorWithTONMessage:@"Can't encode (UTF8) accountAddress."]);
        return;
    }
    
    NSNumber *requestID = _requestID.number ?: [self.handlerStorage generateRequestID];
    
    @weakify(self);
    [self.queue async:^{
        @strongify(self);
        
        GTRequestHandler *handler = [[GTRequestHandler alloc] initWithCompletionBlock:^(GTRequestHandler *handler, tonlib_api::object_ptr<tonlib_api::Object> & object) {
            if (handler.isCancelled) {
                completionBlock(nil, [NSError errorWithCancelledMessage]);
                return;
            }
            
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                completionBlock(nil, [NSError errorWithTONError:error]);
            } else if (object->get_id() == tonlib_api::raw_transactions::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::raw_transactions>(object);
                NSMutableArray<GTTransaction *> *transactions = [[NSMutableArray alloc] init];

                GTTransactionID *initializationTransactionID = nil;
                if (result->transactions_.size() != 0 && result->previous_transaction_id_->lt_ == 0) {
                    for (int i = (int)(result->transactions_.size()) - 1; i >= 0; i--) {
                        if (result->transactions_[i]->in_msg_ == nullptr || result->transactions_[i]->in_msg_->value_ == 0) {
                            break;
                        } else {
                            int64_t value = 0;
                            if (result->transactions_[i]->in_msg_ != nullptr) {
                                value += result->transactions_[i]->in_msg_->value_;
                            }
                            for (auto &message : result->transactions_[i]->out_msgs_) {
                                value -= message->value_;
                            }
                            if (value == 0) {
                                uint64_t identifier = result->transactions_[i]->transaction_id_->lt_;
                                NSData *hash = GTDataWithString(result->transactions_[i]->transaction_id_->hash_);
                                initializationTransactionID = [[GTTransactionID alloc] initWithLogicalTime:identifier
                                                                                           transactionHash:hash];
                                break;
                            }
                        }
                    }
                }

                for (auto &it : result->transactions_) {
                    NSData *hash = GTDataWithString(it->transaction_id_->hash_);
                    GTTransactionID *transactionID = [[GTTransactionID alloc] initWithLogicalTime:it->transaction_id_->lt_
                                                                                  transactionHash:hash];
                    GTTransactionMessage *inMessage = GTTransactionMessageCreate(it->in_msg_);
                    NSMutableArray<GTTransactionMessage *> * outMessages = [[NSMutableArray alloc] init];
                    for (auto &messageIt : it->out_msgs_) {
                        GTTransactionMessage *outMessage = GTTransactionMessageCreate(messageIt);
                        if (outMessage != nil) {
                            [outMessages addObject:outMessage];
                        }
                    }
                    
                    BOOL isInitialization = NO;
                    if (initializationTransactionID != nil &&
                        initializationTransactionID.logicalTime == transactionID.logicalTime &&
                        [initializationTransactionID.transactionHash isEqualToData:transactionID.transactionHash])
                    {
                        isInitialization = true;
                    }
                    
                    [transactions addObject:[[GTTransaction alloc] initWithData:GTDataWithString(it->data_)
                                                                  transactionID:transactionID
                                                                      timestamp:it->utime_
                                                                     storageFee:it->storage_fee_
                                                                       otherFee:it->other_fee_
                                                                      inMessage:inMessage
                                                                    outMessages:outMessages
                                                               isInitialization:isInitialization]];
                }
                
                completionBlock([transactions copy], nil);
            } else {
                completionBlock(nil, [NSError errorWithTONMessage:@"Undefined error from `tonlib_api::raw_getTransactions` query."]);
            }
        }];
        
        [self.handlerStorage setRequestHandler:handler withRequestID:requestID];
        
        auto query = make_object<tonlib_api::raw_getTransactions>(
            make_object<tonlib_api::inputKeyFake>(),
            make_object<tonlib_api::accountAddress>(
                GTStringWithData(accounAddressData)
            ),
            make_object<tonlib_api::internal_transactionId>(
                transactionID.logicalTime,
                GTStringWithData(transactionID.transactionHash)
            )
        );
        
        u_int64_t rid = requestID.longLongValue;
        self.client->send({ rid, std::move(query) });
    }];
}

@end
