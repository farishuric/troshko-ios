//
//  PrivacyPolicySection.swift
//  Troshko
//
//  Created by Faris Hurić on 30. 9. 2024..
//

enum PrivacyPolicySection: CaseIterable {
    case informationWeCollect
    case localDataStorage
    case icloudBackup
    case thirdPartyServices
    case dataSecurity
    case childrensPrivacy
    case changes
    case yourConsent
    case contactUs

    var title: String {
        switch self {
        case .informationWeCollect:
            return "PRIVACY_POLICY.INFORMATION_WE_COLLECT.TITLE".localized
        case .localDataStorage:
            return "PRIVACY_POLICY.LOCAL_DATA_STORAGE.TITLE".localized
        case .icloudBackup:
            return "PRIVACY_POLICY.ICLOUD_BACKUP.TITLE".localized
        case .thirdPartyServices:
            return "PRIVACY_POLICY.THIRD_PARTY_SERVICES.TITLE".localized
        case .dataSecurity:
            return "PRIVACY_POLICY.DATA_SECURITY.TITLE".localized
        case .childrensPrivacy:
            return "PRIVACY_POLICY.CHILDRENS_PRIVACY.TITLE".localized
        case .changes:
            return "PRIVACY_POLICY.CHANGES.TITLE".localized
        case .yourConsent:
            return "PRIVACY_POLICY.YOUR_CONSENT.TITLE".localized
        case .contactUs:
            return "PRIVACY_POLICY.CONTACT_US.TITLE".localized
        }
    }

    var textDescription: String {
        switch self {
        case .informationWeCollect:
            return "PRIVACY_POLICY.INFORMATION_WE_COLLECT.CONTENT".localized
        case .localDataStorage:
            return "PRIVACY_POLICY.LOCAL_DATA_STORAGE.CONTENT".localized
        case .icloudBackup:
            return "PRIVACY_POLICY.ICLOUD_BACKUP.CONTENT".localized
        case .thirdPartyServices:
            return "PRIVACY_POLICY.THIRD_PARTY_SERVICES.CONTENT".localized
        case .dataSecurity:
            return "PRIVACY_POLICY.DATA_SECURITY.CONTENT".localized
        case .childrensPrivacy:
            return "PRIVACY_POLICY.CHILDRENS_PRIVACY.CONTENT".localized
        case .changes:
            return "PRIVACY_POLICY.CHANGES.CONTENT".localized
        case .yourConsent:
            return "PRIVACY_POLICY.YOUR_CONSENT.CONTENT".localized
        case .contactUs:
            return "PRIVACY_POLICY.CONTACT_US.CONTENT".localized
        }
    }
}
