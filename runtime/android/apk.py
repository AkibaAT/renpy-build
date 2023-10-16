from __future__ import print_function, unicode_literals

import os
import struct
import zipfile
import io

from pygame_sdl2.rwobject import RWops_from_file, RWops_create_subfile # type: ignore

class APK(object):

    def __init__(self, apk=None, prefix="assets/"):
        """
        Opens an apk file, and lets you read the assets out of it.

        `apk`
            The path to the file to open. If this is None, it defaults to the
            apk file we are run out of.

        `prefix`
            The prefix inside the apk file to read.
        """

        if apk is None:
            apk = os.environ["ANDROID_APK"]
            print("Opening APK %r" % apk)

        self.apk = apk
        self.prefix = prefix

        self.zf = zipfile.ZipFile(apk, "r")

        # A map from unprefixed filename to ZipInfo object.
        self.info = { }

        for i in self.zf.infolist():
            fn = i.filename
            if not fn.startswith(prefix):
                continue

            fn = fn[len(prefix):]

            self.info[fn] = i

        f = open(self.apk, "rb")

        self.offset = { }

        import time
        start = time.time()

        for fn, info in self.info.items():
            f.seek(info.header_offset)

            h = struct.unpack(zipfile.structFileHeader, f.read(zipfile.sizeFileHeader))

            self.offset[fn] = (
                info.header_offset +
                zipfile.sizeFileHeader +
                h[zipfile._FH_FILENAME_LENGTH] +
                h[zipfile._FH_EXTRA_FIELD_LENGTH])

        f.close()

    def __reduce__(self):
        return (self.__class__, (self.apk, self.prefix))

    def list(self):
        return sorted(self.info)

    def open(self, fn):

        if fn not in self.info:
            raise IOError("{0} not found in apk.".format(fn))

        info = self.info[fn]

        if info.compress_type == zipfile.ZIP_STORED:

            rw = RWops_from_file(self.apk, "rb")
            return RWops_create_subfile(
                rw,
                self.offset[fn],
                info.file_size)

        return io.BytesIO(self.zf.read(info))
