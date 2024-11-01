#if canImport(Testing)
import Testing
#else
import XCTest
#endif
@testable import SparkDI

#if canImport(Testing)
@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}
#endif
