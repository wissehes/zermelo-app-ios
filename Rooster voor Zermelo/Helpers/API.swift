//
//  API.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import Foundation
import Alamofire

final class API {
    
    static let DEMO_BASEURL = "https://demo.wissehes.nl";
    
    static func getWeek(_ date: Date?) -> String {
        
        let components = Calendar.current.dateComponents([.year, .weekOfYear], from: date ?? Date())
        
        if let year = components.year, let week = components.weekOfYear {
            return String(describing: year) + String(format: "%02d", week)
        } else {
            return ""
        }
    }
    
    static func getLiveSchedule(completion: @escaping (Result<[ZermeloLivescheduleAppointment], AFError>) -> Void) {
        guard let user = UserManager.getCurrent() else { return completion(.success([])) }
        
        let params: Parameters = [
            "student": user.me.code,
            "week": getWeek(nil)
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.token.access_token)"
        ]
        
        AF.request("https://\(user.token.portal).zportal.nl/api/v3/liveschedule", parameters: params, headers: headers)
            .validate()
            .responseDecodable(of: GetZermeloLiveschedule.self) { response in
                switch response.result {
                case .success(let _data):
                    guard let data = _data.response.data.first else { return completion(.success([])) }
                    
                    completion(.success(data.appointments))
                case .failure(let err):
                    completion(.failure(err))
                }
            }
    }
    
    static func getLiveScheduleAsync(week: String = getWeek(nil)) async throws -> [ZermeloLivescheduleAppointment] {
        guard let user = UserManager.getCurrent() else { return [] }
        
        let params: Parameters = [
            "student": user.me.code,
            "week": week
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.token.access_token)"
        ]
        
        let result = await AF.request(
            "https://\(user.token.portal).zportal.nl/api/v3/liveschedule",
            parameters: params,
            headers: headers
        )
            .serializingDecodable(GetZermeloLiveschedule.self)
            .result
        
        switch result {
        case .success(let data):
            return data.response.data.first?.appointments ?? []
        case .failure(_):
            return []
        }
    }
    
    static func getScheduleForDay(date: Date) async throws -> [ZermeloLivescheduleAppointment] {
        let weekAppointments = try await self.getLiveScheduleAsync(week: getWeek(date))
        
        if weekAppointments.isEmpty {
            return []
        }
        
        let filtered = weekAppointments.filter { app in
            let appointmentDate = Date(timeIntervalSince1970: TimeInterval(app.start))
            return Calendar.current.isDate(appointmentDate, equalTo: date, toGranularity: .day)
        }
        
        return filtered
    }
    
    static func fetchMe(token: SavedToken, completion: @escaping (Result<ZermeloMeData, FetchError>) -> ()) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token.access_token)"
        ]
        
        AF.request("https://\(token.portal).zportal.nl/api/v3/users/~me", headers: headers)
            .validate()
            .responseDecodable(of: GetZermeloMe.self) { response in
                switch response.result {
                case .success(let data):
                    guard let me = data.response.data.first else {
                        completion(.failure(.noData))
                        return
                    }
                    completion(.success(me))
                case .failure(let err):
                    completion(.failure(.AFError(error: err)))
                }
            }
    }
    
    static func getToken(_ data: ZermeloQRData, completion: @escaping (Result<SavedToken, AFError>) -> ()) {
        
        let params: Parameters = [
            "grant_type": "authorization_code",
            "code": data.code
        ]
        AF.request("https://\(data.institution).zportal.nl/api/v3/oauth/token", method: .post, parameters: params)
            .validate()
            .responseDecodable(of: ZermeloTokenRequest.self){ response in
                switch response.result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let tokenInfo):
                    let tokenData = SavedToken.init(qrData: data, tokenInfo: tokenInfo)
                    completion(.success(tokenData))
                }
            }
    }

}

enum FetchError: Error {
    case noData
    case AFError(error: AFError)
}
