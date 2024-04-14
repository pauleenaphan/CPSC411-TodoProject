//
//  todo.swift
//  CPSC411-TodoProject
//
//  Created by csuftitan on 3/20/24.
//

import SwiftUI

//identifiable is used for unique identifiers like our todo
//codable says that todo can be encoded and decoded in JSON
struct TodoItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var dueDate: Date
}
