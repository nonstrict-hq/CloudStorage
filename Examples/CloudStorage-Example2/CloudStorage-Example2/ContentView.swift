//
//  ContentView.swift
//  Untitled 1
//
//  Created by Nonstrict on 2023-04-20.
//

import SwiftUI
import CloudStorage

struct ContentView: View {

    var body: some View {
        NavigationStack {
            NavigationLink("Detail") {
                DetailView()
            }
        }
    }
}


struct DetailView: View {


    var body: some View {
        VStack {
            TopView()
            Divider()
            MiddleView()
            Divider()
            BottomView()
        }
        .padding()
    }
}


struct TopView: View {
    @CloudStorage("myBool") var myBool = false

    var body: some View {
        Toggle("My Bool", isOn: $myBool)
    }
}

struct MiddleView: View {
    @CloudStorage("myBool") var myBool = false

    var body: some View {
        Toggle("My Bool", isOn: $myBool)
    }
}

struct BottomView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        Toggle("My Bool", isOn: $viewModel.myBool)

        Button("Toggle") { viewModel.myBool.toggle() }
    }
}

class ViewModel: ObservableObject {
    @CloudStorage("myBool") var myBool = false
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
