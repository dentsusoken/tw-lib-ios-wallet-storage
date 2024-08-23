//
//  PresentationLog.swift
//
//
//  Created by r-ebisawa on 2024/08/21.
//

import Foundation
import PresentationExchange
import SiopOpenID4VP
import MdocDataModel18013
import SwiftCBOR


public struct PresentationLog : Codable{
    public var id: String = UUID().uuidString
    public var verifierName:String?
    public var verifierURL:String?
    public var submitAt:Date
    public var isSuccess:Bool
    public var idToken:String?
    public var vpToken:String?
    public var presentationSubmission:PresentationSubmission?
    public var message:String?
    
    public init(id: String = UUID().uuidString, verifierName: String?, verifierURL: String?, submitAt: Date, isSuccess: Bool, consent: ClientConsent,idToken:String? = nil,vpToken:String? = nil,presentationSubmission:PresentationSubmission? = nil,message:String? = nil) {
        self.id = id
        self.verifierName = verifierName
        self.verifierURL = verifierURL
        self.submitAt = submitAt
        self.isSuccess = isSuccess
        switch consent {
        case .idToken(let idToken):
            self.idToken = idToken
        case .vpToken(let vpToken, let presentationSubmission):
            self.vpToken = vpToken.value
            self.presentationSubmission =  presentationSubmission
        case .idAndVPToken(let idToken, let vpToken, let presentationSubmission):
            self.idToken = idToken
            self.vpToken = vpToken.value
            self.presentationSubmission =  presentationSubmission
        case .negative(let message):
            self.message = message
        }
    }
    
    public func decodeVPToken() -> [IssuerNameSpaces]?{
        guard let vpToken = self.vpToken  else{ return nil }
        guard let data = Data(base64URLEncoded: vpToken) else { return nil }
        let deviceResponse = DeviceResponse(data: [UInt8](data))
        
        guard let documents = deviceResponse?.documents else { return nil }
        
        let nameSpacesList =  documents.compactMap {document in
            return document.issuerSigned.issuerNameSpaces
        }
        return nameSpacesList
    }
    
}
