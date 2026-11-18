import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Supported UI languages: English (default) + 10 Asian languages
/// (Thai intentionally excluded per project spec).
class AppLanguage {
  final String code; // BCP-47
  final String nativeName;
  final String speechLocale; // used by speech_to_text

  const AppLanguage(this.code, this.nativeName, this.speechLocale);
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage("en", "English", "en_US"),
  AppLanguage("km", "ខ្មែរ (Khmer)", "km_KH"),
  AppLanguage("vi", "Tiếng Việt", "vi_VN"),
  AppLanguage("zh", "中文 (简体)", "zh_CN"),
  AppLanguage("ja", "日本語", "ja_JP"),
  AppLanguage("ko", "한국어", "ko_KR"),
  AppLanguage("id", "Bahasa Indonesia", "id_ID"),
  AppLanguage("ms", "Bahasa Melayu", "ms_MY"),
  AppLanguage("tl", "Filipino", "fil_PH"),
  AppLanguage("hi", "हिन्दी", "hi_IN"),
  AppLanguage("my", "မြန်မာ (Burmese)", "my_MM"),
];

/// UI strings for every supported language. Keep keys identical across
/// all maps. Falls back to English if a key/language is missing.
final Map<String, Map<String, String>> _strings = {
  "en": {
    "app_title": "AI Image Studio",
    "describe_idea": "Describe your idea",
    "prompt_hint":
        "Describe the image you want... e.g. \"a cozy cabin in a snowy forest at night\"",
    "enhance_with_ai": "Enhance with AI",
    "choose_style": "Choose a style",
    "generate_image": "Generate Image",
    "generating": "Generating...",
    "no_image_yet": "No image yet",
    "no_image_subtitle": "Describe an idea above and tap Generate.",
    "settings": "Settings",
    "language": "Language",
    "color_mode": "Color mode",
    "history": "History",
    "regenerate": "Regenerate",
    "save": "Save",
    "share": "Share",
  },
  "km": {
    "app_title": "AI Image Studio",
    "describe_idea": "ពិពណ៌នាគំនិតរបស់អ្នក",
    "prompt_hint":
        "សរសេរអំពីរូបភាពដែលអ្នកចង់បាន... ឧ. \"ផ្ទះកញ្ចក់នៅព្រៃព្រិលពេលយប់\"",
    "enhance_with_ai": "កែលម្អដោយ AI",
    "choose_style": "ជ្រើសរើសរចនាបថ",
    "generate_image": "បង្កើតរូបភាព",
    "generating": "កំពុងបង្កើត...",
    "no_image_yet": "មិនទាន់មានរូបភាពទេ",
    "no_image_subtitle": "សរសេរគំនិតខាងលើ រួចចុចប៊ូតុងបង្កើត។",
    "settings": "ការកំណត់",
    "language": "ភាសា",
    "color_mode": "ពណ៌ក្រុម",
    "history": "ប្រវត្តិ",
    "regenerate": "បង្កើតឡើងវិញ",
    "save": "រក្សាទុក",
    "share": "ចែករំលែក",
  },
  "vi": {
    "app_title": "AI Image Studio",
    "describe_idea": "Mô tả ý tưởng của bạn",
    "prompt_hint":
        "Mô tả hình ảnh bạn muốn... vd: \"một căn nhà gỗ ấm cúng trong rừng tuyết ban đêm\"",
    "enhance_with_ai": "Cải thiện bằng AI",
    "choose_style": "Chọn phong cách",
    "generate_image": "Tạo ảnh",
    "generating": "Đang tạo...",
    "no_image_yet": "Chưa có ảnh nào",
    "no_image_subtitle": "Mô tả ý tưởng ở trên rồi nhấn Tạo ảnh.",
    "settings": "Cài đặt",
    "language": "Ngôn ngữ",
    "color_mode": "Chế độ màu",
    "history": "Lịch sử",
    "regenerate": "Tạo lại",
    "save": "Lưu",
    "share": "Chia sẻ",
  },
  "zh": {
    "app_title": "AI 图像工作室",
    "describe_idea": "描述你的创意",
    "prompt_hint": "描述你想要的图像……例如“雪夜森林里的温馨小屋”",
    "enhance_with_ai": "用 AI 优化",
    "choose_style": "选择风格",
    "generate_image": "生成图像",
    "generating": "生成中...",
    "no_image_yet": "还没有图像",
    "no_image_subtitle": "在上方描述创意，然后点击生成。",
    "settings": "设置",
    "language": "语言",
    "color_mode": "配色模式",
    "history": "历史记录",
    "regenerate": "重新生成",
    "save": "保存",
    "share": "分享",
  },
  "ja": {
    "app_title": "AI画像スタジオ",
    "describe_idea": "アイデアを説明してください",
    "prompt_hint": "生成したい画像を説明してください… 例:「雪の森の中の暖かい小屋」",
    "enhance_with_ai": "AIで改善する",
    "choose_style": "スタイルを選択",
    "generate_image": "画像を生成",
    "generating": "生成中...",
    "no_image_yet": "まだ画像がありません",
    "no_image_subtitle": "上でアイデアを入力し、生成ボタンを押してください。",
    "settings": "設定",
    "language": "言語",
    "color_mode": "カラーモード",
    "history": "履歴",
    "regenerate": "再生成",
    "save": "保存",
    "share": "共有",
  },
  "ko": {
    "app_title": "AI 이미지 스튜디오",
    "describe_idea": "아이디어를 설명하세요",
    "prompt_hint": "원하는 이미지를 설명하세요... 예: \"눈 내리는 밤 숲속의 아늑한 오두막\"",
    "enhance_with_ai": "AI로 개선하기",
    "choose_style": "스타일 선택",
    "generate_image": "이미지 생성",
    "generating": "생성 중...",
    "no_image_yet": "아직 이미지가 없습니다",
    "no_image_subtitle": "위에 아이디어를 입력하고 생성을 누르세요.",
    "settings": "설정",
    "language": "언어",
    "color_mode": "색상 모드",
    "history": "기록",
    "regenerate": "다시 생성",
    "save": "저장",
    "share": "공유",
  },
  "id": {
    "app_title": "AI Image Studio",
    "describe_idea": "Jelaskan ide Anda",
    "prompt_hint":
        "Jelaskan gambar yang Anda inginkan... misal: \"pondok hangat di hutan bersalju malam hari\"",
    "enhance_with_ai": "Tingkatkan dengan AI",
    "choose_style": "Pilih gaya",
    "generate_image": "Buat Gambar",
    "generating": "Membuat...",
    "no_image_yet": "Belum ada gambar",
    "no_image_subtitle": "Jelaskan ide di atas lalu ketuk Buat Gambar.",
    "settings": "Pengaturan",
    "language": "Bahasa",
    "color_mode": "Mode warna",
    "history": "Riwayat",
    "regenerate": "Buat ulang",
    "save": "Simpan",
    "share": "Bagikan",
  },
  "ms": {
    "app_title": "AI Image Studio",
    "describe_idea": "Terangkan idea anda",
    "prompt_hint":
        "Terangkan imej yang anda mahu... cth: \"pondok selesa di hutan bersalji waktu malam\"",
    "enhance_with_ai": "Tambah baik dengan AI",
    "choose_style": "Pilih gaya",
    "generate_image": "Jana Imej",
    "generating": "Menjana...",
    "no_image_yet": "Tiada imej lagi",
    "no_image_subtitle": "Terangkan idea di atas dan ketik Jana Imej.",
    "settings": "Tetapan",
    "language": "Bahasa",
    "color_mode": "Mod warna",
    "history": "Sejarah",
    "regenerate": "Jana semula",
    "save": "Simpan",
    "share": "Kongsi",
  },
  "tl": {
    "app_title": "AI Image Studio",
    "describe_idea": "Ilarawan ang iyong ideya",
    "prompt_hint":
        "Ilarawan ang gusto mong larawan... hal: \"maaliwalas na kubo sa maniyebeng gubat sa gabi\"",
    "enhance_with_ai": "Pahusayin gamit ang AI",
    "choose_style": "Pumili ng estilo",
    "generate_image": "Gumawa ng Larawan",
    "generating": "Ginagawa...",
    "no_image_yet": "Wala pang larawan",
    "no_image_subtitle":
        "Ilarawan ang ideya sa itaas pagkatapos i-tap ang Gumawa.",
    "settings": "Mga Setting",
    "language": "Wika",
    "color_mode": "Mode ng kulay",
    "history": "Kasaysayan",
    "regenerate": "Gawing muli",
    "save": "I-save",
    "share": "Ibahagi",
  },
  "hi": {
    "app_title": "एआई इमेज स्टूडियो",
    "describe_idea": "अपना विचार बताएं",
    "prompt_hint":
        "जो छवि आप चाहते हैं उसका वर्णन करें... जैसे: \"बर्फीले जंगल में रात की आरामदायक झोपड़ी\"",
    "enhance_with_ai": "AI से सुधारें",
    "choose_style": "शैली चुनें",
    "generate_image": "छवि बनाएं",
    "generating": "बनाया जा रहा है...",
    "no_image_yet": "अभी तक कोई छवि नहीं",
    "no_image_subtitle": "ऊपर विचार लिखें और जनरेट पर टैप करें।",
    "settings": "सेटिंग्स",
    "language": "भाषा",
    "color_mode": "रंग मोड",
    "history": "इतिहास",
    "regenerate": "फिर से बनाएं",
    "save": "सहेजें",
    "share": "साझा करें",
  },
  "my": {
    "app_title": "AI Image Studio",
    "describe_idea": "သင့်စိတ်ကူးကို ဖော်ပြပါ",
    "prompt_hint":
        "သင်လိုချင်သော ပုံကို ဖော်ပြပါ... ဥပမာ \"နှင်းကျသောတောထဲရှိ နွေးထွေးသည့်တဲငယ်\"",
    "enhance_with_ai": "AI ဖြင့် တိုးတက်အောင်ပြုလုပ်ပါ",
    "choose_style": "စတိုင်ရွေးပါ",
    "generate_image": "ပုံထုတ်လုပ်ပါ",
    "generating": "ထုတ်လုပ်နေသည်...",
    "no_image_yet": "ပုံမရှိသေးပါ",
    "no_image_subtitle":
        "အထက်တွင် စိတ်ကူးဖော်ပြပြီး ထုတ်လုပ်ပါခလုတ်ကို နှိပ်ပါ။",
    "settings": "ဆက်တင်များ",
    "language": "ဘာသာစကား",
    "color_mode": "အရောင်မုဒ်",
    "history": "မှတ်တမ်း",
    "regenerate": "ပြန်လုပ်ပါ",
    "save": "သိမ်းဆည်းပါ",
    "share": "မျှဝေပါ",
  },
};

class LocaleProvider extends ChangeNotifier {
  String _code = "en";

  String get code => _code;
  AppLanguage get current =>
      kSupportedLanguages.firstWhere((l) => l.code == _code,
          orElse: () => kSupportedLanguages.first);

  LocaleProvider();

  String t(String key) {
    return _strings[_code]?[key] ?? _strings["en"]![key] ?? key;
  }

  void setLanguage(String code) {
    _code = code;
    notifyListeners();
  }
}

/// Convenience accessor used across all screens: `context.t("key")`.
extension AppLocalizationContext on BuildContext {
  String t(String key) => watch<LocaleProvider>().t(key);
}
