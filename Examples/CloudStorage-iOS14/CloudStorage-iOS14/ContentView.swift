//
//  ContentView.swift
//  CloudStorage-iOS14
//
//  Created by Tom Lokhorst on 2020-07-04.
//

import SwiftUI
import CloudStorage

let turtles: [String] = [
    "Leonardo", "Michelangelo",
    "Donatello", "Raphael" ]
let terrestrialPlanets: [String] = [
    "Mercury", "Venus", "Earth", "Mars",
].sorted()

struct ContentView: View {
    @ObservedObject var cloudStorageSync = CloudStorageSync.shared

    @CloudStorage("readyForAction") var readyForAction: Bool = false
    @CloudStorage("speed") var speed: Double = 0
    @CloudStorage("numberOfItems") var numberOfItems: Int = 0
    @CloudStorage("ninjaTurtle") var ninjaTurtle = turtles[0]
    @CloudStorage("orientation") var orientation: String?
    @CloudStorage("favoriteColor") var favoriteColor = MyColor(.lightGray)
    @CloudStorage("planets") var planets: [String] = terrestrialPlanets

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("CloudStorageSync status:")
                    Text(cloudStorageSync.status.description).font(.caption)
                }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))

                Group {
                    Toggle(isOn: $readyForAction) {
                        Text("Ready for action")
                    }
                    HStack(spacing: 20) {
                        Text("Speed (km/h)")
                        Slider(value: $speed, in: 0...200)
                    }
                    Button("Set average speed") {
                        self.speed = 100
                    }

                    Stepper("Number of items: \(numberOfItems)", value: $numberOfItems, in: 0...5)

                    Picker("Ninja Turtle", selection: $ninjaTurtle) {
                        ForEach(turtles, id: \.self) { turtle in
                            Text("\(turtle)")
                        }
                    }
                    HStack {
                        Text("Orientation")
                        Spacer()
                        Text(orientation ?? "")
                    }
                    HStack {
                        Spacer()
                        Button("Left") { self.orientation = "Left" }
                        Spacer()
                        Button("Right") { self.orientation = "Right" }
                        Spacer()
                        Button("[Clear]") { self.orientation = nil }
                    }
                }

                Group {
                    HStack {
                        Text("Favorite color")
                        Spacer()
                        Rectangle()
                            .fill(Color(favoriteColor))
                            .frame(width: 80, height: 30)
                            .border(Color(UIColor.separator), width: 1)
                            .onDrag { NSItemProvider(object: self.favoriteColor.uiColor) }
                    }
                    .onDrop(
                        of: ["com.apple.uikit.color"],
                        delegate: ColorDropDelegate(color: $favoriteColor)
                    )

                    Text("Terrestrial planets")
                    List {
                        ForEach(planets, id: \.self) { planet in
                            Text(planet)
                        }
                        .onMove(perform: movePlanets)
                    }.frame(height: 140)
                }
            }
            .frame(maxWidth: 720)
            Spacer()
        }
        .padding()
    }

    private func movePlanets(source: IndexSet, destination: Int) {
        planets.move(fromOffsets: source, toOffset: destination)
    }
}

struct ColorDropDelegate: DropDelegate {
    @Binding var color: MyColor

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: ["com.apple.uikit.color"]) else {
            return false
        }
        let providers = info.itemProviders(for: ["com.apple.uikit.color"])
        for provider in providers {
            provider.loadObject(ofClass: UIColor.self) { color, _ in
                guard let color = color as? UIColor else { return }
                DispatchQueue.main.async {
                    self.color = MyColor(color)
                }
            }
        }

        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
