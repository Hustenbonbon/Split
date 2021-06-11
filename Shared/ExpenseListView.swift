//
//  ExpenseListView.swift
//  Split
//
//  Created by Hendrik Schaeidt on 11/06/2021.
//

import SwiftUI

struct Person {
    let name: String
    let color: Color
}

struct Expense: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let paidBy: Person
    let forWhom: [Person]
    let date: Date
}

let hendrik = Person(name: "Hendrik", color: .blue)
let max = Person(name: "Max", color: .yellow)

let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
let dayBeforeYesterday = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

let previewExpenses = [
    Expense(title: "Döner", amount: 10.5, paidBy: max, forWhom: [hendrik, max], date: Date()),
    Expense(title: "Dürum", amount: 12, paidBy: hendrik, forWhom: [hendrik, max], date: yesterday),
    Expense(title: "Pizza Brot", amount: 22.9, paidBy: max, forWhom: [hendrik], date: yesterday),
    Expense(title: "Döner", amount: 10.5, paidBy: max, forWhom: [hendrik, max], date: dayBeforeYesterday),
]

struct ExpenseListView: View {
    @State var expenseStore = ExpensesStore(previewExpenses)
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List(expenseStore.filtered) { expense in
                VStack {
                    HStack {
                        Text(expense.title)
                        Spacer()
                        Text(expense.amount.asCurrency)
                            .font(.subheadline)
                    }
                    HStack {
                        Text(expense.paidBy.name)
                            .font(.subheadline)
                        Spacer()
                        Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                    }
                }//.background(expense.paidBy.color)
            }
            .refreshable {
                try! await expenseStore.updateData()
            }
            .task {
                expenseStore.add(Expense(title: "Test", amount: 1.0, paidBy: Person(name: "marcel", color: .green), forWhom: [hendrik,max], date: Date()))
            }
            .navigationBarTitle("Expenses")
        }
        .searchable(text: $expenseStore.filterText)
    }
}

struct ExpensesStore {
    private var all: [Expense]
    
    var filtered: [Expense] {
        if filterText.isEmpty {
            return all
        }
        return all.filter {
            $0.title.contains(filterText) ||
            $0.paidBy.name.contains(filterText)
        }
    }
    
    mutating func add(_ expense: Expense) {
        all.append(expense)
    }
    
    mutating func updateData() async throws {
        // https://swapi.dev/api/people/1
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: URL(string: "https://swapi.dev/api/people/1")!))
        // all = previewExpenses
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw "die welt hasst uns"
        }
        let jsonData = try! JSONDecoder().decode(StarWarsData.self, from: data)
        all.append(Expense(title: jsonData.name, amount: 2.0, paidBy: hendrik, forWhom: [], date: Date()))
        
    }
    
    var filterText = ""
    
    init(_ expenses: [Expense]) {
      all = expenses
    }
}

struct StarWarsData: Codable {
    var name: String
}

extension String: Error {}

extension Double {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: self))!
    }
}

struct ExpenseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseListView()
    }
}
