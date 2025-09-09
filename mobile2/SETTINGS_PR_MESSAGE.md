Changes added for Settings UI:

- Added screens:
  - lib/screens/settings.dart (main SettingsScreen)
  - lib/screens/settings/bank_details.dart
  - lib/screens/settings/payout_settings.dart
  - lib/screens/settings/qr_management.dart
  - lib/screens/settings/kyc_documents.dart
  - lib/screens/settings/security_settings.dart
  - lib/screens/settings/notifications.dart
  - lib/screens/settings/support.dart

- Widgets & utils:
  - lib/widgets/setting_row.dart (reusable row)
  - lib/utils/storage.dart (shared_preferences JSON helpers)

- Images / placeholders:
  - mobile2/assets/images/qr_placeholder.png
  - mobile2/assets/images/id_sample.png

TODOs / Backend wiring:
- KYC uploads need a secure upload API integration. // TODO
- Bank account verification must be done server-side and sensitive data stored securely. // TODO // SECURITY
- Account deletion must call backend with auth and proper verification. // TODO // SECURITY
- Password changes and PIN storage should use secure backends / keystore. // TODO // SECURITY

Notes:
- Settings button wired on dashboard to open Settings screen.
- Demo screenshots placeholders added under mobile2/screenshots/.
