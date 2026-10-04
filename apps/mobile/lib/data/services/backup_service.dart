import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashi/domain/study.dart';
import 'package:flashi/domain/study_package.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  Future<File> writeTemporary(StudyPackage package, {String? name}) async {
    final directory = await getTemporaryDirectory();
    final safe = (name ?? package.title)
        .replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '')
        .trim();
    final suffix = package.kind == StudyPackageKind.backup
        ? '.flashi-backup'
        : '.flashi-pack';
    final file = File(
      '${directory.path}/${safe.isEmpty ? 'Flashi' : safe}$suffix',
    );
    return file.writeAsString(package.encode(), flush: true);
  }

  Future<void> share(StudyPackage package, {String? name}) async {
    final file = await writeTemporary(package, name: name);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      text: 'Open this Flashi study package to preview and import it.',
    );
  }

  Future<StudyPackage?> pickPackage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    final file = File(path);
    if (await file.length() > 20 * 1024 * 1024) {
      throw const FormatException('Flashi package is too large');
    }
    return StudyPackage.decode(await file.readAsString());
  }

  StudyPackage packFor(StudySet set, {String creator = ''}) =>
      StudyPackage.pack([set], creator: creator);
}
