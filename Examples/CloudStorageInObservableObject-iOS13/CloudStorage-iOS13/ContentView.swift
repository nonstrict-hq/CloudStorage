//
//  ContentView.swift
//  CloudStorage-iOS13
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

    @StateObject var settings = CloudSettings()

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
                    Toggle(isOn: $settings.readyForAction) {
                        Text("Ready for action")
                    }
                    HStack(spacing: 20) {
                        Text("Speed (km/h)")
                        Slider(value: $settings.speed, in: 0...200)
                    }
                    Button("Set average speed") {
                        self.settings.speed = 100
                    }

                    Stepper("Number of items: \(settings.numberOfItems)", value: $settings.numberOfItems, in: 0...5)

                    Picker("Ninja Turtle", selection: $settings.ninjaTurtle) {
                        ForEach(turtles, id: \.self) { turtle in
                            Text("\(turtle)")
                        }
                    }
                    HStack {
                        Text("Orientation")
                        Spacer()
                        Text(settings.orientation ?? "")
                    }
                    HStack {
                        Spacer()
                        Button("Left") { self.settings.orientation = "Left" }
                        Spacer()
                        Button("Right") { self.settings.orientation = "Right" }
                        Spacer()
                        Button("[Clear]") { self.settings.orientation = nil }
                    }
                }

                Group {
                    HStack {
                        Text("Favorite color")
                        Spacer()
                        Rectangle()
                            .fill(Color(settings.favoriteColor))
                            .frame(width: 80, height: 30)
                            .border(Color(UIColor.separator), width: 1)
                            .onDrag { NSItemProvider(object: self.settings.favoriteColor.uiColor) }
                    }
                    .onDrop(
                        of: ["com.apple.uikit.color"],
                        delegate: ColorDropDelegate(color: $settings.favoriteColor)
                    )

                    Text("Terrestrial planets")
                    List {
                        ForEach(settings.planets, id: \.self) { planet in
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
        settings.planets.move(fromOffsets: source, toOffset: destination)
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
