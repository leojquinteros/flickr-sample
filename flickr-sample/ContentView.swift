//
//  ContentView.swift
//  komoot-test
//
//  Created by Leo Quinteros on 10/04/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        if viewModel.shouldShowStartButton {
            VStack {
                Button {
                    viewModel.startUpdatingLocation()
                } label: {
                    StartButtonView()
                }
                .disabled(viewModel.hasDeniedLocation)
                if viewModel.hasDeniedLocation {
                    Text("Please allow the app to track your location in Settings")
                        .font(.caption2)
                }
            }
            .padding()
            .onAppear {
                viewModel.setupLocationManager()
            }
        } else {
            NavigationStack {
                ScrollView {
                    if viewModel.hasDeniedLocation {
                        Text("Please allow the app to track your location in Settings")
                            .font(.caption2)
                    } else {
                        ForEach(viewModel.photos, id: \.self) { photo in
                            if let photoURL = photo.url {
                                AsyncImageView(photoURL: photoURL)
                            }
                        }
                        if viewModel.hasStoppedUpdatingLocation {
                            Text("You have stopped sharing your location. Enjoy the photos! You can also 'pull to refresh' and continue...")
                                .font(.footnote)
                        }
                    }
                }
                .padding(.all, 8)
                .navigationBarItems(trailing:
                    Button(action: {
                        viewModel.stopUpdatingLocation()
                    }) {
                        Text("Stop")
                    }
                    .disabled(viewModel.hasStoppedUpdatingLocation || viewModel.hasDeniedLocation)
                )
                .refreshable {
                    if viewModel.hasStoppedUpdatingLocation && !viewModel.hasDeniedLocation {
                        viewModel.startUpdatingLocation()
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                viewModel.setupLocationManager()
            }
        }
    }
}

private struct StartButtonView: View {
        
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.right.square")
            Text("Start")
        }
        .frame(width: 150, height: 40)
        .foregroundColor(.white)
        .background(.blue)
    }
}

private struct AsyncImageView: View {
    var photoURL: URL
    
    var body: some View {
        AsyncImage (
            url: photoURL,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            },
            placeholder: {
                ProgressView()
            }
        )
    }
}
