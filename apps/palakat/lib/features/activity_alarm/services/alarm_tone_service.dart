import 'dart:math' as math;
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class AlarmToneService {
  static const String _fileName = 'palakat_alarm_tone.wav';

  Future<String> ensureToneFilePath() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$_fileName';

    final file = File(path);
    final exists = await file.exists();
    if (!exists) {
      await _writeWavFile(file);
    }
    return path;
  }

  Future<void> _writeWavFile(File file) async {
    final bytes = _generateWavTone(
      seconds: 2,
      sampleRate: 44100,
      frequencyHz: 880,
      amplitude: 0.8,
    );

    await file.writeAsBytes(bytes, flush: true);
  }

  Uint8List _generateWavTone({
    required int seconds,
    required int sampleRate,
    required int frequencyHz,
    required double amplitude,
  }) {
    final totalSamples = seconds * sampleRate;
    final dataBytes = totalSamples * 2;

    final header = BytesBuilder(copy: false);

    void writeAscii(String s) {
      header.add(s.codeUnits);
    }

    void writeUint32LE(int v) {
      header.add(
        Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little),
      );
    }

    void writeUint16LE(int v) {
      header.add(
        Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little),
      );
    }

    writeAscii('RIFF');
    writeUint32LE(36 + dataBytes);
    writeAscii('WAVE');

    writeAscii('fmt ');
    writeUint32LE(16);
    writeUint16LE(1);
    writeUint16LE(1);
    writeUint32LE(sampleRate);
    writeUint32LE(sampleRate * 2);
    writeUint16LE(2);
    writeUint16LE(16);

    writeAscii('data');
    writeUint32LE(dataBytes);

    final pcm = Int16List(totalSamples);
    final twoPiF = 2.0 * math.pi * frequencyHz;

    final amp = (amplitude.clamp(0.0, 1.0) * 32767).round();

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final sample = math.sin(twoPiF * t);
      pcm[i] = (sample * amp).round();
    }

    final out = BytesBuilder(copy: false);
    out.add(header.takeBytes());
    out.add(pcm.buffer.asUint8List());
    return out.takeBytes();
  }
}
