import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
  ];

  /// **'Hai / Hi'**
  String get hi;

  /// **'Aplikasi EGP / EGP Mobile'**
  String get appTitle;

  /// **'Peta / Map'**
  String get choicepage_index_1;

  /// **'Dashboard PSOH'**
  String get choicepage_index_2;

  /// **'Mod Jejak / Trail Mode'**
  String get choicepage_index_3;

  /// **'Muat Naik Data / Upload Data'**
  String get choicepage_index_4;

  /// **'Tentang / About'**
  String get choicepage_index_5;

  /// **'Nama Jejak / Trail Name'**
  String get tracker_page_placeholder_1;

  /// **'Titik Mula/ Start Point'**
  String get tracker_page_placeholder_2;

  /// **'Titik Akhir / End Point'**
  String get tracker_page_placeholder_3;

  /// **'Mod Jejak / Trail Mode'**
  String get tracker_page_label_1;

  /// **'Kaedah Jejak / Trail Method'**
  String get tracker_page_label_2;

  /// **'Jejak / Trail'**
  String get trail;

  /// **'Pilih / Choose'**
  String get choose;

  /// **'Pilih Mod Jejak / Choose Trail Mode'**
  String get choose_trail_mode;

  /// **'Pilih Kaedah Jejak / Choose Method Mode'**
  String get choose_method_trail;

  /// **'Pilih Selang Masa / Choose Interval'**
  String get choose_interval;

  /// **'Selang Masa / Interval'**
  String get interval;

  /// **'Selamat Kembali / Welcome Back'**
  String get greeting;

  /// **'Tentang / About'**
  String get about_1;

  /// **'Detail about'**
  String get about_2;

  /// **'Log Keluar / Logout'**
  String get logout;

  /// **'Adakah anda pasti untuk log keluar? / Are you sure to log out?'**
  String get logoutConfirm;

  /// **'Anda telah berjaya log keluar / You have successfully logout'**
  String get successLogout;

  /// **'Ya / Yes'**
  String get yes;

  /// **'Tidak / No'**
  String get no;

  /// **'Batal / Cancel'**
  String get cancel;

  /// **'Tutup / Close'**
  String get close;

  /// **'Berjaya / Success'**
  String get success;

  /// **'Ralat / Error'**
  String get error;

  /// **'Mula / Start'**
  String get start;

  /// **'Henti / Finish'**
  String get finish;

  /// **'Anda pasti untuk henti jejak? / Are you sure to finish tracking?'**
  String get confirm_finish_track;

  /// **'Padam / Delete'**
  String get delete;

  /// **'Padam Semua / Delete All'**
  String get deleteAll;

  /// **'Anda pasti untuk padam data ini? / Are you sure to delete this data?'**
  String get confirm_delete;

  /// **'Anda pasti untuk padam / Are you sure to delete'**
  String get confirm_delete_item;

  /// **'Data telah berjaya dipadam / Data has been deleted.'**
  String get success_delete;

  /// **'Makluman / Attention'**
  String get attention;

  /// **'Sila isi semua ruangan dan pilhan dropdown terlebih dahulu / Please fill all the field and dropdown first'**
  String get fill_all;

  /// **'Sila mulakan tracking terlebih dahulu / Please start the tracking first'**
  String get track_first;

  /// **'Muat Naik / Upload'**
  String get upload;

  /// **'Anda pasti untuk muat naik / Are you sure to upload'**
  String get confirm_upload;

  /// **'Data telah berjaya dimuat naik. / Data has been uploaded.'**
  String get success_upload;

  /// **'Cari / Search'**
  String get search;

  /// **'Tiada data / No data'**
  String get noData;

  /// **'Tiada data yang dicari / No results found'**
  String get noResult;

  /// **'Tarikh / Date'**
  String get date;

  /// **'Masa / Time'**
  String get time;

  /// **'MOD JEJAK AKTIF / TRACKING ACTIVE'**
  String get trackerActive;

  /// **'MOD JEJAK NYAHAKTIF / TRACKING INACTIVE'**
  String get trackerInactive;

  /// **'Koordinat / Location Points'**
  String get locationPoint;

  /// **'titk / points'**
  String get points;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
