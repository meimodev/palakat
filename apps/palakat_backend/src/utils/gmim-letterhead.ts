import { readFileSync } from 'fs';
import { join } from 'path';
import { inflateSync } from 'zlib';

export type GmimLetterhead = {
  title: string;
  line1: string;
  line2?: string;
  line3?: string;
};

const GMIM_TITLE = 'GEREJA MASEHI INJILI di MINAHASA';

let cachedLogoBuffer: Buffer | undefined;

function isPngSignature(buffer: Buffer): boolean {
  return (
    buffer.length >= 8 &&
    buffer[0] === 0x89 &&
    buffer[1] === 0x50 &&
    buffer[2] === 0x4e &&
    buffer[3] === 0x47 &&
    buffer[4] === 0x0d &&
    buffer[5] === 0x0a &&
    buffer[6] === 0x1a &&
    buffer[7] === 0x0a
  );
}

function isValidPng(buffer: Buffer): boolean {
  if (!isPngSignature(buffer)) return false;

  let width = 0;
  let height = 0;
  const idatChunks: Buffer[] = [];

  let offset = 8;
  while (offset + 8 <= buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.toString('ascii', offset + 4, offset + 8);

    const dataStart = offset + 8;
    const dataEnd = dataStart + length;
    const crcEnd = dataEnd + 4;

    if (crcEnd > buffer.length) return false;

    if (type === 'IHDR' && length >= 8) {
      width = buffer.readUInt32BE(dataStart);
      height = buffer.readUInt32BE(dataStart + 4);
    } else if (type === 'IDAT') {
      idatChunks.push(buffer.subarray(dataStart, dataEnd));
    } else if (type === 'IEND') {
      break;
    }

    offset = crcEnd;
  }

  if (!width || !height) return false;
  if (!idatChunks.length) return false;

  const pixels = width * height;
  if (!Number.isFinite(pixels) || pixels <= 0 || pixels > 20_000_000) {
    return false;
  }

  try {
    inflateSync(Buffer.concat(idatChunks));
    return true;
  } catch {
    return false;
  }
}

export function buildGmimLetterhead(params: {
  churchName: string;
  locationName?: string | null;
  phoneNumber?: string | null;
  email?: string | null;
}): GmimLetterhead {
  const churchName = (params.churchName ?? '').toString().trim();
  const locationName = (params.locationName ?? '').toString().trim();
  const phone = (params.phoneNumber ?? '').toString().trim();
  const email = (params.email ?? '').toString().trim();

  const captionParts = [locationName, phone, email].filter((x) => x.length > 0);

  return {
    title: GMIM_TITLE,
    line1: `Jemaat ${churchName || ''}`.trim(),
    line2: captionParts.length ? captionParts.join(' ') : undefined,
  };
}

export function getGmimLogoBuffer(): Buffer {
  if (cachedLogoBuffer?.length) return cachedLogoBuffer;

  const candidatePaths = [
    join(process.cwd(), 'src', 'assets', 'gmim-logo.png'),
    join(process.cwd(), 'dist', 'assets', 'gmim-logo.png'),
    // ts runtime (dev) usually has __dirname at src/utils
    join(__dirname, '..', 'assets', 'gmim-logo.png'),
    // compiled runtime (prod) usually has __dirname at dist/src/utils
    join(__dirname, '..', '..', 'assets', 'gmim-logo.png'),
  ];

  for (const path of candidatePaths) {
    try {
      const buf = readFileSync(path);
      if (!isValidPng(buf)) continue;
      cachedLogoBuffer = buf;
      return buf;
    } catch {
      // continue
    }
  }

  // No logo found/valid; don't cache emptiness so it can appear after adding the file.
  return Buffer.alloc(0);
}
