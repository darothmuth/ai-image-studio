/// Blocks prompt categories this app must never generate, BEFORE any
/// network call is made. This is a first line of defense — the backend's
/// AI provider also enforces its own content policy as a second layer
/// (see backend/server.js's "safety|policy" error handling).
///
/// Categories blocked here, per the project's responsible-AI requirements
/// (handbook Rule 5 — sensitive domains, Section 13 — responsible AI use):
///   - Nudity / sexual content
///   - Forged or official documents: signatures, ID cards, passports,
///     invoices, receipts, contracts, currency/banknotes
///   - Real, named public figures (cannot be verified as consensual/legal)
class ContentFilterService {
  ContentFilterService._();

  static final List<_BlockedCategory> _categories = [
    _BlockedCategory(
      label: "nudity or sexual content",
      keywords: [
        "nude", "naked", "nsfw", "porn", "sexual", "topless", "explicit",
      ],
    ),
    _BlockedCategory(
      label: "signatures or forged documents",
      keywords: [
        "signature", "sign here", "forged", "forgery", "autograph",
      ],
    ),
    _BlockedCategory(
      label: "official identity documents",
      keywords: [
        "passport", "id card", "identity card", "driver's license",
        "driving license", "national id", "visa stamp",
      ],
    ),
    _BlockedCategory(
      label: "financial or legal paperwork",
      keywords: [
        "invoice", "receipt", "bank statement", "contract agreement",
        "legal document", "court order", "will and testament",
        "banknote", "currency note", "counterfeit money", "check payable",
      ],
    ),
  ];

  /// Returns null if the prompt is allowed, or a user-facing reason if it
  /// matches a blocked category.
  static String? checkPrompt(String prompt) {
    final normalized = prompt.toLowerCase();
    for (final category in _categories) {
      for (final keyword in category.keywords) {
        if (normalized.contains(keyword)) {
          return "This app can't generate ${category.label}. "
              "Please try a different description.";
        }
      }
    }
    return null;
  }
}

class _BlockedCategory {
  final String label;
  final List<String> keywords;
  _BlockedCategory({required this.label, required this.keywords});
}
