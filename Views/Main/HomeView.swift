//
//  HomeView.swift
//  UNIGATCH02
//
//  Created by 服部潤一 on 2024/12/19.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @Binding var selectedTab: MainView.Tab
    @Binding var showSuperNintendoWorldChat: Bool
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.6654, longitude: 135.4323),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))
    @State private var selectedArea: USJArea?
    @State private var isBubbleExpanded = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                ForEach(usjAreas) { area in
                    Annotation("", coordinate: area.coordinate) {
                        AreaMarker(area: area, isSelected: selectedArea == area) {
                            selectedArea = area
                            isBubbleExpanded = false
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            if let selectedArea = selectedArea {
                ChatBubble(area: selectedArea, isExpanded: $isBubbleExpanded, selectedTab: $selectedTab, showSuperNintendoWorldChat: $showSuperNintendoWorldChat)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: isBubbleExpanded)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        cameraPosition = .userLocation(fallback: .automatic)
                    }) {
                        Image(systemName: "location")
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding()
                }
            }
        }
    }
}

struct AreaMarker: View {
    let area: USJArea
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: area.icon)
                    .font(.system(size: 14))
                Text(area.name)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? area.color : area.color.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct ChatBubble: View {
    let area: USJArea
    @Binding var isExpanded: Bool
    @Binding var selectedTab: MainView.Tab
    @Binding var showSuperNintendoWorldChat: Bool
    @State private var showAreaSpecificChat = false
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        VStack {
            if isExpanded {
                ExpandedChatView(area: area, isExpanded: $isExpanded, showAreaSpecificChat: $showAreaSpecificChat, showSuperNintendoWorldChat: $showSuperNintendoWorldChat)
            } else {
                CollapsedChatView(area: area)
            }
        }
        .frame(maxWidth: isExpanded ? .infinity : 200, maxHeight: isExpanded ? .infinity : 100)
        .background(area.color.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 5)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
        
    }
}

struct CollapsedChatView: View {
    let area: USJArea
    
    var body: some View {
        VStack {
            Image(systemName: area.icon)
                .font(.system(size: 24))
            Text(area.name)
                .font(.headline)
            Text("タップしてチャットを開く")
                .font(.caption)
        }
        .padding()
        .foregroundColor(.white)
    }
}

struct ExpandedChatView: View {
    let area: USJArea
    @Binding var isExpanded: Bool
    @Binding var showAreaSpecificChat: Bool
    @Binding var showSuperNintendoWorldChat: Bool

    var body: some View {
        VStack {
            HStack {
                Text(area.name)
                    .font(.headline)
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                showSuperNintendoWorldChat = true
            }) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("エリア専用チャットを開く")
                }
                .padding()
                .background(Color.white)
                .foregroundColor(area.color)
                .cornerRadius(10)
            }
            .padding()
            
            Spacer()
            
            Text("アトラクション:")
                .font(.headline)
                .padding(.top)
            
            ForEach(area.attractions) { attraction in
                Text(attraction.name)
                    .padding(.vertical, 2)
            }
            
            Spacer()
        }
        .foregroundColor(.white)
    }
}



