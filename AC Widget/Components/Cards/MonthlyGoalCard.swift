//
//  MonthlyGoalCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct MonthlyGoalCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let type: InfoType
    let header: Bool
    @State private var current: Float = 0
    @State private var estimate: Float = 0
    @State private var goal: Float = 0
    @State private var isEditing: Bool = false

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                if header {
                    Label(type.title, systemImage: type.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(type.color)
                }
                Text("Monthly Goal")
                    .font(.title.weight(.medium))

                if isEditing {
                    editView
                } else if goal == 0 {
                    noGoal
                } else {
                    mainView
                }
            }
        }
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
        .overlay(alignment: .topTrailing) {
            if goal == 0 && !isEditing {
                EmptyView()
            } else {
                Button(action: {
                    if isEditing {
                        UserDefaults.shared?.set(goal, forKey: type.goalDefaultsKey)
                    }
                    self.isEditing.toggle()
                }) {
                    Text(self.isEditing ? "Done" : "Edit")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .foregroundColor(isEditing ? type.contrastColor : .gray)
                        .background(isEditing ? type.color : Color(uiColor: .systemGray6))
                        .cornerRadius(5)
                        .padding()
                }
            }
        }
    }

    private var mainView: some View {
        VStack {
            Spacer()
            VStack(spacing: 5) {
                HStack {
                    UnitText(current.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)
                    Spacer()
                    Text(((current/goal)*100).toString(abbreviation: .none, maxFractionDigits: 0).appending("%"))
                }
                ProgressBar(value: current/goal, type: type)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                Text("Estimation, based on the last 7 days")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    UnitText(estimate.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)
                    Spacer()
                    Text(((estimate/goal)*100).toString(abbreviation: .none, maxFractionDigits: 0).appending("%"))
                }
                ProgressBar(value: estimate/goal, color: .gray)
            }
        }
    }

    private var editView: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Current Goal")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    UnitText(goal.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 5) {
                    Text("This months estimation")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    UnitText(estimate.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                Text("New Goal")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                TextField("", value: $goal, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title.weight(.semibold))
            }
        }
    }

    private var noGoal: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "target")
                .font(.largeTitle.weight(.medium))
                .foregroundColor(type.color)
                .padding(.bottom, 8)

            Text("You have not set a goal yet.")
                .italic()
                .foregroundColor(.gray)
            Spacer()
            Button(action: { self.isEditing = true }) {
                Text("Set Goal")
                    .font(.body.weight(.medium))
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(type.contrastColor)
                    .background(type.color)
                    .cornerRadius(8)
            }
        }
    }

    private func refresh() {
        if let acData = dataProvider.data {
            self.goal = UserDefaults.shared?.float(forKey: type.goalDefaultsKey) ?? 0
            self.current = acData.getRawData(for: type, lastNDays: acData.latestReportingDate().dateToDayNumber()).reduce(0, { $0 + $1.0 })

            let avg = acData.getRawData(for: type, lastNDays: 7).reduce(0, { $0 + $1.0 }) / 7
            let calendar = Calendar.current
            let date = Date.now
            if let interval = calendar.dateInterval(of: .month, for: date) {
                let daysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 30
                let currentDate = calendar.dateComponents([.day], from: date).day ?? 0
                self.estimate = current + Float(daysInMonth-currentDate) * avg
            }
        }
    }
}

struct MonthlyGoalCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                MonthlyGoalCard(type: .downloads, header: false)
                MonthlyGoalCard(type: .proceeds, header: true)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)

            CardSection {
                MonthlyGoalCard(type: .downloads, header: false)
                MonthlyGoalCard(type: .proceeds, header: true)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)
            .preferredColorScheme(.dark)
        }
    }
}
