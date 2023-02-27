//
//  SubjectManager.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 27/02/2023.
//

import Foundation
import CodableCSV

struct Vak: Codable {
    var afkorting: String
    var naam: String
}

final class SubjectManager: ObservableObject {
    static let shared = SubjectManager()
    
    lazy var all: [Vak] = getAll()
    
    private func getAll() -> [Vak] {
        guard let url = Bundle.main.url(forResource: "vakken", withExtension: "csv") else { return [] }
        
        do {
            let decoder = CSVDecoder { config in
                config.headerStrategy = .firstLine
                config.delimiters.field = ";"
                config.delimiters.row = "\r\n"
                config.encoding = .utf8
                config.trimStrategy = .whitespaces
            }
            let results = try decoder.decode([Vak].self, from: url)
            return results
        } catch(let err) {
            print(err)
            return []
        }
    }
    
    func getFullName(_ acronym: String) -> String? {
        if let vak = all.first(where: { $0.afkorting.localizedLowercase == acronym.localizedLowercase }) {
            // Split into words, uppercase the first letter and combine again
            return vak.naam.split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
        } else {
            return nil
        }
    }
    
    func getFullName(_ acronyms: [String]) -> [String] {
        return acronyms.map { acr in
            self.getFullName(acr) ?? acr
        }
    }
}
