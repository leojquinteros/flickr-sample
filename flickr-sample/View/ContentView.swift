//
//  ContentView.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 10/04/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            switch viewModel.state {
            case .deniedLocation:
                Text("Please allow the app to track your location in Settings")
                    .font(.caption2)
            case .ready:
                VStack {
                    Button {
                        viewModel.startUpdatingLocation()
                    } label: {
                        Text("Start")
                    }
                    .buttonStyle(StartButton())
                    .disabled(viewModel.state == .loading)
                }
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.primary)
                
            case .error(let message):
                VStack {
                    Text("Error‼️")
                        .font(.title)
                    Text(message)
                        .font(.caption2)
                }
            case .loaded(let photosURL):
                NavigationStack {
                    ScrollView {
                        ForEach(photosURL, id: \.self) { photoURL in
                            AsyncImageView(photoURL: photoURL)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                viewModel.startUpdatingLocation()
                            } label: {
                                Text("Resume")
                            }
                            .disabled(viewModel.state != .stopSharing)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.stopUpdatingLocation()
                            } label: {
                                Text("Stop")
                            }
                            .disabled(viewModel.state == .stopSharing)
                        }
                    }
                }
            default:
                EmptyView()
            }
        }
        .padding(.all, 8)
        .ignoresSafeArea()
        .onAppear {
            viewModel.updateLocationManager()
        }
    }
}

private struct StartButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 50)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

private struct AsyncImageView: View {
    var photoURL: URL
    var body: some View {
        AsyncImage(url: photoURL, content: { image in
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

