//
//  DateTimeManager.swift
//  LOOKHEART 100
//
//  Created by KHJ on 4/24/25.
//

import Foundation


final class DateTimeManager {
    static let shared = DateTimeManager()
    
    private let utcDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    private let utcDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    private let localDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    private let localDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    
    init() { }
    
    
    // MARK: - UTC
    public func getCurrentUTCDate() -> String {
        let now = Date()
        return utcDateFormatter.string(from: now)
    }
    
    public func getCurrentUTCDateTime() -> String {
        let now = Date()
        return utcDateTimeFormatter.string(from: now)
    }
    
    
    // MARK: - Local
    public func getCurrentLocalDate() -> String {
        let now = Date()
        return localDateFormatter.string(from: now)
    }
    
    public func getCurrentLocalDateTime() -> String {
        let now = Date()
        return localDateTimeFormatter.string(from: now)
    }
    
    
    // MARK: - TimeZone
    public func getTimeZone() -> String {
        let currentTimeZone = TimeZone.current
        let utcOffsetInSeconds = currentTimeZone.secondsFromGMT()
        let hours = abs(utcOffsetInSeconds) / 3600
        let minutes = (abs(utcOffsetInSeconds) % 3600) / 60
        let offsetString = String(format: "%@%02d:%02d", utcOffsetInSeconds >= 0 ? "+" : "-", hours, minutes)
        return offsetString
    }
    
    public func getIdentifier() -> String {
        let currentTimeZone = TimeZone.current
        let identifier = currentTimeZone.identifier     // 현재 국가, 도시
        return identifier
    }
    
    public func getCountryCode() -> String {
        let currentCountryCode = Locale.current.regionCode ?? "Unknown"  // "US", "KR" 등
        return currentCountryCode
    }
    
    public func getAllTimeZoneData() -> String {
        let timeZone = getTimeZone()
        let identifier = getIdentifier()
        let countryCode = getCountryCode()
        return "\(timeZone)/\(identifier)/\(countryCode)"   // +09:00/Asia/Seoul/KR
    }
    
    
    // MARK: -
    public func checkLocalDate(
      utcDateTime: String?,
      localDate: String? = nil
    ) -> Bool {
      guard let utcDateTime = utcDateTime else { return false }
        
      guard let utcDateTime = utcDateTimeFormatter.date(from: utcDateTime) else {
        return false
      }
        
      let targetLocalDateStr: String = {
        if let local = localDate, !local.isEmpty {
          return local
        } else {
            return localDateFormatter.string(from: Date())
        }
      }()
        
      guard let localDateAtMidnight = localDateFormatter.date(from: targetLocalDateStr) else {
        return false
      }

      // 시작(00:00)과 다음날 시작(다음날 00:00)
      let calendar = Calendar.current
      let startOfDay = calendar.startOfDay(for: localDateAtMidnight)
      guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
        return false
      }

      // utcDateTime이 localDate 시작~다음날에 속하는지 비교
      return (utcDateTime >= startOfDay) && (utcDateTime < startOfNextDay)
    }
}

