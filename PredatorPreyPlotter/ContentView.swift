//
//  ContentView.swift
//  PredatorPreyPlotter
//
//  Created by Devin R Cohen on 11/23/25.
//

import SwiftUI

struct ContentView: View {
    @State private var alphaText = "0.66"
    @State private var betaText = "1.33"
    @State private var gammaText = "1.0"
    @State private var deltaText = "1.0"
    
    @State private var x0Text = "0.9"
    @State private var y0Text = "0.9"
    
    @State private var dtText = "0.1"
    @State private var stepsText = "200"
    
    @State private var showCoefficients = false
    @State private var showInitialConditions = false
    @State private var showIntegration = false
    
    enum Field: Hashable {
        case alpha, beta, gamma, delta
        case x0, y0
        case dt, steps
    }
    
    @FocusState private var focusedField: Field?
    
    struct LVPoint: Identifiable {
        let id = UUID()
        let t: Double
        let prey: Double
        let predator: Double
    }
    
    @State private var points: [LVPoint] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DisclosureGroup(
                        isExpanded: $showCoefficients,
                        content: {
                            HStack {
                                Text("α")
                                    .fontWeight(.bold)
                                TextField("alpha", text: $alphaText)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .alpha)
                            }
                            HStack {
                                Text("β")
                                    .fontWeight(.bold)
                                TextField("beta", text: $betaText)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .beta)
                            }
                            HStack {
                                Text("γ")
                                    .fontWeight(.bold)
                                TextField("gamma", text: $gammaText)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .gamma)
                            }
                            HStack {
                                Text("δ")
                                    .fontWeight(.bold)
                                TextField("delta", text: $deltaText)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .delta)
                            }
                        },
                        label: {
                            Text("Coefficients")
                                .fontWeight(.bold)
                        }
                    )
                    DisclosureGroup(
                        isExpanded: $showInitialConditions,
                        content: {
                            HStack {
                                Text("x₀")
                                    .fontWeight(.bold)
                                TextField("x0", text: $x0Text)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .x0)
                            }
                            HStack {
                                Text("y₀")
                                    .fontWeight(.bold)
                                TextField("y0", text: $y0Text)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .y0)
                            }
                        },
                        label: {
                            Text("Initial Conditions")
                                .fontWeight(.bold)
                        }
                    )
                    DisclosureGroup(
                        isExpanded: $showIntegration,
                        content: {
                            HStack {
                                Text("Δt")
                                    .fontWeight(.bold)
                                TextField("dt", text: $dtText)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .dt)
                            }
                            HStack {
                                Text("Steps")
                                    .fontWeight(.bold)
                                TextField("steps", text: $stepsText)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .steps)
                            }
                        },
                        label: {
                            Text("Integration")
                                .fontWeight(.bold)
                        }
                    )
                }
                
                Button("Solve") {
                    print("Solve Tapped")
                    solve()
                }
                .buttonStyle(.borderedProminent)
                
                Section("Sample Output") {
                    if points.isEmpty {
                        Text("Press Solve to compute.")
                            .foregroundStyle(Color.secondary)
                            .contentShape(Rectangle())
                            .onTapGesture { focusedField = nil }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(points.prefix(50)) { p in
                                        Text(
                                            String(
                                                format: "t = %.2f prey = %.3f pred = %.3f",
                                                p.t, p.prey, p.predator
                                            )
                                        )
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = nil }
                        
                        Text("Showing first \(min(points.count, 50)) of \(points.count) points")
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .navigationTitle("Predator-Prey")
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil // dismiss keyboard
                }
            }
        }
    }
    
    private func solve() {
        let alpha = Double(alphaText) ?? 0.66
        let beta = Double(betaText) ?? 1.33
        let gamma = Double(gammaText) ?? 1.0
        let delta = Double(deltaText) ?? 1.0
        
        let x0 = Double(x0Text) ?? 0.9
        let y0 = Double(y0Text) ?? 0.9
        
        let dt = Double(dtText) ?? 0.1
        let steps = Int(stepsText) ?? 200
        
        let dict = LVBridge.solve(withAlpha: alpha, beta: beta, gamma: gamma, delta: delta, x0: x0, y0: y0, dt: dt, steps: Int32(steps))
        print("dict from LVBridge: \(dict)")
        
        guard
            let tArr = dict["t"],
            let preyArr = dict["prey"],
            let predArr = dict["predator"]
        else {
            print("Guard failed: keys missing in dict")
            points = []
            return
        }
        
        let count = min(tArr.count, preyArr.count, predArr.count)
        var newPoints: [LVPoint] = []
        newPoints.reserveCapacity(count)
        
        for i in 0..<count {
            let t = tArr[i].doubleValue
            let prey = preyArr[i].doubleValue
            let pred = predArr[i].doubleValue
            newPoints.append(LVPoint(t: t, prey: prey, predator: pred))
        }
        
        points = newPoints
    }
}

#Preview {
    ContentView()
}
