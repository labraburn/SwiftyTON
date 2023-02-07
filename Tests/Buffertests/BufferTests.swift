//
//  Created by Anton Spivak
//

import Foundation
import XCTest

@testable import Buffer

class BufferTests: XCTestCase {
    func testBufferElement() {
        // 42
        // 2A
        // 00101010

        let bigEndian: Binary = [
            .one,
            .zero,
            .one,
            .zero,
            .one,
            .zero,
        ]

        let decimal = BufferElement(42)

        XCTAssertEqual(
            decimal.binary(endianness: .big, truncation: .standart),
            bigEndian
        )

        XCTAssertEqual(
            decimal.binary(endianness: .little, truncation: .standart),
            bigEndian.reversed()
        )

        XCTAssertEqual(
            decimal.binary(endianness: .big),
            [.zero, .zero] + bigEndian
        )

        XCTAssertEqual(
            decimal.binary(endianness: .little),
            bigEndian.reversed() + [.zero, .zero]
        )

        XCTAssertEqual(BufferElement(binary: bigEndian, endianness: .big), decimal)
        XCTAssertEqual(BufferElement(binary: bigEndian.reversed(), endianness: .little), decimal)

        XCTAssertEqual(
            BufferElement(0).binary(endianness: .big),
            [.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero]
        )

        XCTAssertEqual(BufferElement(0).binary(truncation: .standart), [])

        XCTAssertEqual(
            BufferElement(0xff).binary(),
            [.one, .one, .one, .one, .one, .one, .one, .one]
        )

        XCTAssertEqual(
            BufferElement(0xff).binary(),
            [.one, .one, .one, .one, .one, .one, .one, .one]
        )
    }

    func testBufferRepresentable() throws {
        // 123456789
        // 07 5B CD 15
        // 00000111010110111100110100010101

        let bigEndian: Buffer = [0x07, 0x5B, 0xCD, 0x15]
        let decimal = UInt64(123456789)

        XCTAssertEqual(
            decimal.buffer(endianness: .big, truncation: .standart),
            bigEndian
        )

        XCTAssertEqual(
            decimal.buffer(endianness: .big),
            [0x0, 0x0, 0x0, 0x0] + bigEndian
        )

        XCTAssertEqual(
            decimal.buffer(endianness: .little, truncation: .standart),
            bigEndian.reversed()
        )

        XCTAssertEqual(
            decimal.buffer(endianness: .little),
            bigEndian.reversed() + [0x0, 0x0, 0x0, 0x0]
        )

        XCTAssertEqual(UInt64(buffer: bigEndian, endianness: .big), decimal)
        XCTAssertEqual(UInt64(buffer: bigEndian.reversed(), endianness: .little), decimal)

        XCTAssertEqual(
            UInt64.min.buffer(),
            [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]
        )

        XCTAssertEqual(UInt64.min.buffer(truncation: .standart), [])

        XCTAssertEqual(
            UInt64.max.buffer(truncation: .standart),
            [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
        )

        XCTAssertEqual(
            UInt64.max.buffer(truncation: .none),
            [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
        )
    }

    func testBinaryRepresentable() {
        // 123456789
        // 07 5B CD 15
        // 00000111010110111100110100010101

        let bigEndianBuffer: Buffer = [0x07, 0x5B, 0xCD, 0x15]
        let bigEndianBinary: Binary = [
            .one,
            .one,
            .one,
            .zero,
            .one,
            .zero,
            .one,
            .one,
            .zero,
            .one,
            .one,
            .one,
            .one,
            .zero,
            .zero,
            .one,
            .one,
            .zero,
            .one,
            .zero,
            .zero,
            .zero,
            .one,
            .zero,
            .one,
            .zero,
            .one,
        ]

        let decimal = UInt64(123456789)

        XCTAssertEqual(
            decimal.binary(endianness: .big, truncation: .standart),
            bigEndianBinary
        )

        XCTAssertEqual(
            decimal.binary(endianness: .little, truncation: .standart),
            bigEndianBinary.reversed()
        )

        XCTAssertEqual(UInt64(binary: bigEndianBinary, endianness: .big), decimal)
        XCTAssertEqual(UInt64(binary: bigEndianBinary.reversed(), endianness: .little), decimal)

        XCTAssertEqual(
            UInt64(buffer: bigEndianBuffer, endianness: .big),
            UInt64(binary: bigEndianBinary, endianness: .big)
        )

        XCTAssertEqual(
            UInt64(buffer: bigEndianBuffer.reversed(), endianness: .little),
            UInt64(binary: bigEndianBinary.reversed(), endianness: .little)
        )

        XCTAssertEqual(
            UInt64.max.binary(truncation: .standart),
            stride(from: 0, to: 64, by: 1).map({ _ in .one })
        )

        XCTAssertEqual(
            UInt64.max.binary(truncation: .none),
            stride(from: 0, to: 64, by: 1).map({ _ in .one })
        )

        XCTAssertEqual(
            Buffer(binary: bigEndianBinary, endianness: .big),
            bigEndianBuffer
        )

        XCTAssertEqual(
            Buffer(binary: bigEndianBinary.reversed(), endianness: .little),
            bigEndianBuffer.reversed()
        )
    }
}
