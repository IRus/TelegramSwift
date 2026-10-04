import Foundation
import XCTest
import DateUtils

final class DateUtilsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        DateUtils.setDateLocalizationFunc { key in
            switch key {
            case "Time.today": return "Localized today"
            case "Time.tomorrow": return "Localized tomorrow"
            default: return key
            }
        }
    }

    override func tearDown() {
        DateUtils.setDateLocalizationFunc { $0 }
        super.tearDown()
    }

    func testUntilTodayMorning() throws {
        try assertUntil(dayOffset: 0, hour: 1, label: "Localized today")
    }

    func testUntilTodayAfternoon() throws {
        try assertUntil(dayOffset: 0, hour: 13, label: "Localized today")
    }

    func testUntilTomorrowMorning() throws {
        try assertUntil(dayOffset: 1, hour: 1, label: "Localized tomorrow")
    }

    func testUntilTomorrowAfternoon() throws {
        try assertUntil(dayOffset: 1, hour: 13, label: "Localized tomorrow")
    }

    private func assertUntil(dayOffset: Int, hour: Int, label: String) throws {
        let calendar = Calendar.current
        let now = Date()
        let day = try XCTUnwrap(calendar.date(byAdding: .day, value: dayOffset, to: now))
        // Dates in another year use the numeric-date branch of this API.
        guard calendar.component(.year, from: day) == calendar.component(.year, from: now) else {
            throw XCTSkip("Tomorrow falls in a different calendar year")
        }
        let date = try XCTUnwrap(calendar.date(bySettingHour: hour, minute: 5, second: 0, of: day))
        let expectedTime: String
        if TGUse12hDateFormat() {
            expectedTime = hour < 12 ? "1:05 AM" : "1:05 PM"
        } else {
            expectedTime = hour < 12 ? "01:05" : "13:05"
        }
        XCTAssertEqual(DateUtils.stringFor(until: Int32(date.timeIntervalSince1970)), "\(label), \(expectedTime)")
    }
}
