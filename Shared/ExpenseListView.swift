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
    @State var expenseStore = ExpensesStore()
    
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
            .task {
                expenseStore.add(Expense(title: "Test", amount: 1.0, paidBy: Person(name: "marcel", color: .green), forWhom: [hendrik,max], date: Date()))
            }
            .navigationBarTitle("Expenses")
        }
        .searchable(text: $expenseStore.filterText)
    }
}

struct ExpensesStore {
    var all: [Expense] {
        get {
            _all
        }
        set {
            _all = newValue
        }
    }
    
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
        _all.append(expense)
    }
    
    var filterText = ""
    
    private var _all = previewExpenses
}

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
