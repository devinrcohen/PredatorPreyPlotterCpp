//
//  ContentView.swift
//  PredatorPreyPlotter
//
//  Created by Devin R Cohen on 11/23/25.
//

import SwiftUI
import Charts
import UIKit

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
    @State private var showPhasePlot = false
    
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
                Section("Plot") {
                    if points.isEmpty {
                        Text("Run a simulation to see the plot.")
                            .foregroundStyle(Color.secondary)
                    } else { // close: if points.isempty
                        Chart {
                            if !showPhasePlot {
                                // Prey Line
                                ForEach(points) { p in
                                    LineMark(
                                        x: .value("Time", p.t),
                                        y: .value("Prey Population", p.prey),
                                    )
                                    .foregroundStyle(by: .value("Species", "Prey"))
                                }
                                
                                // Predator Line
                                ForEach(points) { p in
                                    LineMark(
                                        x: .value("Time", p.t),
                                        y: .value("Predator Population", p.predator),
                                    )
                                    .foregroundStyle(by: .value("Species", "Predator"))
                                }
                            } else {
                                // Phase Plot
                                ForEach(points) { p in
                                    LineMark(
                                        x: .value("Prey", p.prey),
                                        y: .value("Predator", p.predator)
                                    )
                                    .foregroundStyle(.red)
                                }
                            }
                        }
                        .chartForegroundStyleScale([
                            "Prey": .green,
                            "Predator": .orange
                        ])
                        .chartLegend(showPhasePlot ? .hidden : .visible)
                        .chartXAxisLabel(showPhasePlot ? "Prey Population" : "Time")
                        .chartYAxisLabel{
                            if showPhasePlot {
                                Text("Predator Population")
                                    .rotationEffect(Angle(degrees: 0))
                            } else {
                                Text("Population")
                            }
                        }
                        .frame(height: 250)
                    }
                    Toggle(isOn: $showPhasePlot) {
                        Text(showPhasePlot ? "Phase Plot" : "Time Plot")
                    }
                    Button("Plot") {
                        //print("Solve Tapped")
                        solve()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Section {
                    DisclosureGroup(
                        isExpanded: $showCoefficients,
                        content: {
                            HStack {
                                Text("α = ")
                                    .fontWeight(.bold)
                                SelectAllNumberField(placeholder: "alpha", text: $alphaText)
                            }
                            HStack {
                                Text("β = ")
                                    .fontWeight(.bold)
                                SelectAllNumberField(placeholder: "beta", text: $betaText)
                            }
                            HStack {
                                Text("γ = ")
                                    .fontWeight(.bold)
                                SelectAllNumberField(placeholder: "gamma", text: $gammaText)
                            }
                            HStack {
                                Text("δ = ")
                                    .fontWeight(.bold)
                                SelectAllNumberField(placeholder: "delta", text: $deltaText)
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
                                Text("prey₀ = ")
                                    .fontWeight(.bold)
//                                TextField("x0", text: $x0Text)
//                                    .keyboardType(.decimalPad)
//                                    .focused($focusedField, equals: .x0)
                                SelectAllNumberField(placeholder: "x0", text: $x0Text)
                            }
                            HStack {
                                Text("predator₀ = ")
                                    .fontWeight(.bold)
//                                TextField("y0", text: $y0Text)
//                                    .keyboardType(.decimalPad)
//                                    .focused($focusedField, equals: .y0)
                                SelectAllNumberField(placeholder: "y0", text: $y0Text)
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
//                                TextField("dt", text: $dtText)
//                                    .keyboardType(.decimalPad)
//                                    .focused($focusedField, equals: .dt)
                                SelectAllNumberField(placeholder: "dt", text: $dtText)
                            }
                            HStack {
                                Text("Steps")
                                    .fontWeight(.bold)
//                                TextField("steps", text: $stepsText)
//                                    .keyboardType(.numberPad)
//                                    .focused($focusedField, equals: .steps)
                                SelectAllNumberField(placeholder: "steps", text: $stepsText)
                            }
                        },
                        label: {
                            Text("Integration")
                                .fontWeight(.bold)
                        }
                    )
                }
                
//                Button("Solve") {
//                    print("Solve Tapped")
//                    solve()
//                }
//                .buttonStyle(.borderedProminent)
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
        //print("dict from LVBridge: \(dict)")
        
        guard
            let tArr = dict["t"],
            let preyArr = dict["prey"],
            let predArr = dict["predator"]
        else {
            //print("Guard failed: keys missing in dict")
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

struct SelectAllNumberField: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SelectAllNumberField

        init(_ parent: SelectAllNumberField) {
            self.parent = parent
        }

        @objc func textDidChange(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            // Select all text when the user starts editing, like Slopes
            DispatchQueue.main.async {
                textField.selectAll(nil)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.placeholder = placeholder
        tf.text = text
        tf.keyboardType = .decimalPad
        tf.borderStyle = .roundedRect

        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator,
                     action: #selector(Coordinator.textDidChange(_:)),
                     for: .editingChanged)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
}

#Preview {
    ContentView()
}
