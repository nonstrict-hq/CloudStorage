//
//  ContentView.swift
//  CloudStorage-tvOS13
//
//  Created by Tom Lokhorst on 2021-03-27.
//

import SwiftUI
import CloudStorage

let turtles: [String] = [
    "Leonardo", "Michelangelo",
    "Donatello", "Raphael" ]

struct ContentView: View {
    @CloudStorage("ninjaTurtle") var ninjaTurtle = turtles[0]

    var body: some View {
        VStack {
            Picker("Ninja Turtle", selection: $ninjaTurtle) {
                ForEach(turtles, id: \.self) { turtle in
                    Text("\(turtle)")
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
