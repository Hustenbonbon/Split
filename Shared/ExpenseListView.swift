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
    @State var expenses: [Expense]
    
    var body: some View {
        List($expenses) { $expense in
            VStack {
                HStack {
                    Text(expense.title)
                    Spacer()
                    Text(expense.amount.asCurrency)
                }
                HStack {
                    Text(expense.paidBy.name)
                    Spacer()
                    Text(expense.date.formatted())
                }
            }
        }
    }
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
        ExpenseListView(expenses: previewExpenses)
    }
}
