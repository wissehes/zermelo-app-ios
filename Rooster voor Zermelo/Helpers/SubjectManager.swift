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
    
    private func getAll() async -> [Vak] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let result = self.getAll()
                continuation.resume(returning: result)
            }
        }
    }
    
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
        let mapped = acronyms.map { acr in
            self.getFullName(acr) ?? acr
        }
        
        return mapped.unique()
    }
    
    func getFullName(_ acronym: String, all: [Vak]) -> String? {
        if let vak = all.first(where: { $0.afkorting.localizedLowercase == acronym.localizedLowercase }) {
            // Split into words, uppercase the first letter and combine again
            return vak.naam.split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
        } else {
            return nil
        }
    }
    
    func getFullNameAsync(_ acronyms: [String]) async -> [String] {
        let all = await self.getAll()
        
        let mapped = acronyms.map {
            self.getFullName($0, all: all) ?? $0
        }
        
        return mapped.unique()
    }
}

extension Sequence where Element: Hashable {
    /**
     Removes duplicates from an array.
     */
    func unique() -> [Element] {
        var set = Set<Element>()
        return self.filter { set.insert($0).inserted }
    }
}
