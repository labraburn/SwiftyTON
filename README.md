# SwiftyTON

Native tonlib swift wrapper for [tonlib](https://github.com/labraburn/ton)

- Binaries of tonlib can be located here - [tonlib-xcframework](https://github.com/labraburn/tonlib-xcframework)
- Library uses modern swift cconcurrency API

## Roadmap
- [x] Full Swift over Objetive-C wrapper around C++ tonlib API
- [x] DNS resolving
- [x] Custom contracts
- [ ] Remove tonlib public/private keys management
- [ ] Native BOC parsing (now [ton-3](https://github.com/tonstack/ton3) JS API used)
- [ ] Use only tonlib C++ sending API

## Installation
```swift
.package(
    url: "https://github.com/labraburn/SwiftyTON.git",
    .upToNextMajor(from: "0.1.0")
)
```
## Usage
```swift
// Create local passcode
let passcode = "parole"

// Configurate SwiftyTON with mainnet
SwiftyTON.configurate(with: .main)

// Import key
let words = ["my", "24", "words", "array"]
let key = try await Key.import(password: passcode, words: words)

// Create Wallet v3R2 initial state
let initialState = try await Wallet3.initial(
    revision: .r2,
    deserializedPublicKey: try key.deserializedPublicKey()
)

// Get address from initial data
guard let myAddress = await Address(initial: initial)
else {
    fatalError()
}

// Parse address (and resolve, if needed) from example.ton, example.t.me or simple address string
guard let displayableAddress = await DisplayableAddress(string: "example.ton")
else {
    fatalError()
}

// Transfer
var contract = try await Contract(address: myAddress)
let selectedContractInfo = contract.info

switch contract.kind {
case .none:
    fatalError()
case .uninitialized: // for uninited state we should pass initial data
    contract = Contract(
        address: myAddress,
        info: selectedContractInfo,
        kind: .walletV3R2,
        data: .zero // will be created automatically
    )
default:
    break
}

guard let wallet = AnyWallet(contract: contract) else {
  fatalError()
}

let message = try await wallet.subsequentTransferMessage(
    to: displayableAddress.concreteAddress,
    amount: Currency(0.5), // 0.5 TON
    message: ("SwiftyTON".data(using: .utf8), nil),
    key: key,
    passcode: passcode
)

let fees = try await message.fees() // get estimated fees
print("Estimated fees - \(fees)")

try await message.send() // send transaction
```

## Notes
- This is **alpha** version
- API can be changed and will be changed

## Authors

- anton@stragner.com (stragner.ton)
