//
//  OnboardingView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 03.04.21.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selection = 0
    
    @State private var issuerID = ""
    @State private var keyID = ""
    @State private var key = ""
    @State private var vendor = ""
    
    var body: some View {
        TabView(selection: $selection) {
            welcomeSection
                .padding()
                .tag(0)
            
            issuerIDSection
                .padding()
                .tag(1)
            
            privateKeyIDSection
                .padding()
                .tag(2)
            
            privateKeySection
                .padding()
                .tag(3)
            
            VendorNrSection
                .padding()
                .tag(4)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    
    // MARK: Pages
    var welcomeSection: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.system(.largeTitle, design: .rounded))
            
            SummaryMedium(data: ACData.exampleLargeSums)
                .showAsWidget(.systemMedium)
            
            Text("ONBOARD_WELCOME")
            
            Spacer()
            nextButton
        }
    }
    
    var issuerIDSection: some View {
        VStack(spacing: 20) {
            Text("Issuer ID")
                .font(.system(.largeTitle, design: .rounded))
            
            TextField("Issuer ID", text: $issuerID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("ONBOARD_ISSUER_ID")
            
            Spacer()
            nextButton
                .disabled(issuerID.isEmpty)
        }
    }
    
    var privateKeyIDSection: some View {
        VStack(spacing: 20) {
            Text("Private Key ID")
                .font(.system(.largeTitle, design: .rounded))
            
            TextField("Private Key ID", text: $keyID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("ONBOARD_PRIVATE_KEY_ID")
            
            Spacer()
            nextButton
                .disabled(keyID.isEmpty)
        }
    }
    
    var privateKeySection: some View {
        VStack(spacing: 20) {
            Text("Private Key")
                .font(.system(.largeTitle, design: .rounded))
            
            TextEditor(text: $key)
                .frame(maxHeight: 250)
                .border(Color.gray)
            
            Text("ONBOARD_PRIVATE_KEY")
            
            Spacer()
            nextButton
                .disabled(key.isEmpty)
        }
    }
    
    var VendorNrSection: some View {
        VStack(spacing: 20) {
            Text("Vendor Nr.")
                .font(.system(.largeTitle, design: .rounded))
            
            TextField("Vendor Nr.", text: $vendor)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("ONBOARD_VENDOR_NR")
            
            Spacer()
            nextButton
                .disabled(vendor.isEmpty)
        }
    }
    
    
    // MARK: Next Button
    var nextButton: some View {
        Button(action: onNextPress, label: {
            Text(selection < 4 ? "Next" : "Finish")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .contentShape(Rectangle())
        })
    }
    
    private func onNextPress() {
        if selection < 4 {
            selection += 1
        } else {
            defer { UserDefaults.standard.set(true, forKey: "completedOnboarding") }
            UserDefaults.shared?.setValue(issuerID, forKey: UserDefaultsKey.issuerID)
            UserDefaults.shared?.setValue(keyID, forKey: UserDefaultsKey.privateKeyID)
            UserDefaults.shared?.setValue(key, forKey: UserDefaultsKey.privateKey)
            UserDefaults.shared?.setValue(vendor, forKey: UserDefaultsKey.vendorNumber)
        }
    }
    
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
