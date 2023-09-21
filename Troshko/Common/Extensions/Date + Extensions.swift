//
//  Date + Extensions.swift
//  Troshko
//
//  Created by Faris Hurić on 21. 9. 2023..
//

import Foundation

extension Date {
    enum DateFormat: String {
        case timeStamp = "dd-MM-yyyy HH:mm"
        case hour = "HH"
        case server = "yyyy-MM-dd"
        case serverCommand = "dd/MM/yyyy"
        case formation = "yyyy-MM-dd HH:mm:ss"
        case slashFormation = "yyyy/MM/dd HH:mm:ss"
        case serverHour = "HH:mm"
        case serverTwoHour = "HH:mm:ss"
        case agendaTimeStamp = "MM/dd/yyyy HH:mm:ss"
        case day = "d"
        case birthDate = "MMM dd,yyyy"
        case short = "MMM d, yyyy"
        case shortDateTime = "MMM dd, yyyy HH:mm"
        case monthDay = "MMM dd"
        case longDay = "EEEE, dd MMM"
        case isoFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }

    init?(string: String, format: DateFormat) {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue

        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: string) else {
            return nil
        }
        self.init(timeInterval: 0, since: date)
    }

    init?(string: String, formatUTC: DateFormat) {
        let formatter = DateFormatter()
        formatter.dateFormat = formatUTC.rawValue

        formatter.locale = .current
        guard let date = formatter.date(from: string) else {
            return nil
        }
        self.init(timeInterval: 0, since: date)
    }

    func format(with dateFormat: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.rawValue
        return formatter.string(from: self)
    }

    func formatUTC(with dateFormat: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.rawValue
        formatter.timeZone = TimeZone(identifier: "UTC")

        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}
