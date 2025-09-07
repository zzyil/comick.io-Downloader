# comick.io Downloader 📚

[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/) [![GNU GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

The most versatile, feature-rich & customizable command-line tool to download webtoons (manhwa), comics and manga from [comick.io](https://comick.io) and package them into **PDF**, **EPUB**, or **CBZ**—with intelligent image processing, resumable downloads, scanlation group prioritization, and optional chapter/file-size splitting.

## 📑 Table of Contents

- [🚀 Features](#-features)  
- [🛠️ Requirements](#%EF%B8%8F-requirements)  
- [🧰 Installation](#-installation)  
- [🚀 Usage](#-usage)  
- [⚙️ Options](#%EF%B8%8F-options)  
- [🔐 Cookie Setup](#-cookie-setup)  
- [📖 Examples](#-examples)  
- [💡 Tips & Tricks](#-tips--tricks)  
- [📁 Output Structure](#-output-structure)  
- [⚖️ Disclaimer](#️-disclaimer)
- [🤝 Contributing](#-contributing)  
- [🙏 Acknowledgements](#-acknowledgements)  
- [📄 License](#-license)  

---

## 🚀 Features

- 📥 **Flexible Chapter Selection**  
  Download specific chapters, ranges (`1-5`), or lists (`1,3,5-7`).
- 🏷️ **Scanlation Group Control**  
  Prioritize your favorite scanlation group(s), or choose by highest upvotes.
- 🖼️ **Image Processing**  
  Resize, scale, recombine, and compress images for optimal reading.
- 📁 **Multiple Formats**  
  Export as PDF, fixed-layout EPUB, vertical-scroll EPUB, or CBZ.
- 🔄 **Resumable Downloads**  
  Automatically picks up where it left off if interrupted.
- ✂️ **Book Splitting**  
  Split large downloads by file size (e.g., `400MB`) or chapter count (e.g., `10ch`).
- 💾 **Keep Originals**  
  Optionally retain raw images and per-chapter files.

---

## 🛠️ Requirements


- Python
  - Officially supported: 3.8+
  - Best-effort (tested): 3.7 (may require building Pillow from source on some platforms)
  - Not supported: 3.6 and Python 2.x
- OS: macOS, Linux, Windows
- Python packages (installed via requirements.txt)
  - beautifulsoup4
  - cloudscraper
  - lxml
  - Pillow
  - pypdf
  - requests
- Notes for macOS (Apple Silicon), Python 3.7 only:
  - Building Pillow from source may require system libraries. If you see build errors,
    install via Homebrew:
    - brew install jpeg-turbo libpng freetype libtiff webp little-cms2 zlib
  - Ensure Xcode command line tools are installed: xcode-select --install

Feature support by Python version

- Legend:
  - ✅ Supported
  - ⚠️ Supported with caveats (see notes)
  - ❌ Not supported

| Python | PDF | EPUB (page) | EPUB (vertical) | CBZ | Resume/Restore | Split (size/ch) | Keep images | Group priority/mix-by-upvote | Cloudscraper | lxml parser |
| ------ | --- | ----------- | --------------- | --- | -------------- | --------------- | ----------- | ---------------------------- | ------------ | ----------- |
| 3.13   | ✅  | ✅          | ✅              | ✅  | ✅             | ✅              | ✅          | ✅                           | ✅           | ✅          |
| 3.12   | ✅  | ✅          | ✅              | ✅  | ✅             | ✅              | ✅          | ✅                           | ✅           | ✅          |
| 3.11   | ✅  | ✅          | ✅              | ✅  | ✅             | ✅              | ✅          | ✅                           | ✅           | ✅          |
| 3.10   | ✅  | ✅          | ✅              | ✅  | ✅             | ✅              | ✅          | ✅                           | ✅           | ✅          |
| 3.9    | ✅  | ✅          | ✅              | ✅  | ✅             | ✅              | ✅          | ✅                           | ✅           | ✅          |
| 3.8    | ✅  | ✅          | ✅              | ✅  | ✅             | ✅              | ✅          | ✅                           | ✅           | ✅          |
| 3.7    | ✅  | ✅          | ✅              | ✅  | ✅             | ✅              | ✅          | ✅                           | ✅          | ✅ (fallback to html.parser if lxml unavailable) |
| 3.6    | ❌  | ❌          | ❌              | ❌  | ❌             | ❌              | ❌          | ❌                           | ❌          | ❌          |
| 2.7    | ❌  | ❌          | ❌              | ❌  | ❌             | ❌              | ❌          | ❌                           | ❌          | ❌          |

Notes:
- Cloudscraper is optional. If it’s not available or fails to initialize, the downloader
  automatically falls back to requests.Session.
- The HTML parser prefers lxml if installed, and falls back to the built-in html.parser.
- On macOS (Apple Silicon), Python 3.7 may need system libraries to build Pillow.

---

## 🧰 Installation

```bash
git clone https://github.com/zzyil/comick.io-Downloader.git
cd comick.io-Downloader
python3 -m pip install -r requirements.txt
```

---

## 🚀 Usage

```bash
python3 comick_downloader.py [OPTIONS] COMIC_URL
```

Run `python3 comick_downloader.py --help` for the full option list.

---

## ⚙️ Options

| Option                        | Description                                                                                                                                                                                                                  | Default     |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `COMIC_URL`                   | URL of the comic’s main page (e.g. `https://comick.io/comic/demo-comic`)                                                                                                                                                     | _required_  |
| `--cookies STRING`            | HTTP cookie string for restricted content (e.g. `key1=val1; key2=val2`)                                                                                                                                                     | `""`        |
| `--group STRING...`           | Preferred scanlation groups (comma-separated or multiple args).                                                                                                                                                              | `[]`        |
| `--mix-by-upvote`             | When multiple `--group` entries exist, pick the version with the highest upvotes among them.                                                                                                                                 | `False`     |
| `--no-partials`               | Skip fractional chapters (e.g. 1.5).                                                                                                                                                                                          | `False`     |
| `--chapters STRING`           | Chapter filter: `all`, single (`5`), range (`1-10`), or list/ranges (`1,3,5-7`).                                                                                                                                             | `all`       |
| `--language STRING`           | Language code (e.g. `en`, `ja`).                                                                                                                                                                                              | `en`        |
| `--format {pdf,epub,cbz,none}`     | Output format.                                                                                                                                                                                                                | `epub`      |
| `--epub-layout {page,vertical}` | EPUB layout: `page` (fixed), `vertical` (scroll).                                                                                                                                                                             | `vertical`  |
| `--width INT`                 | Base image width (px). Defaults vary by format/layout.                                                                                                                                                                        | _auto_      |
| `--aspect-ratio STRING`       | Target W:H ratio (e.g. `4:3` or `2.5`). Not used for PDF.                                                                                                                                                                     | _auto_      |
| `--quality INT`               | JPEG quality `%` (1–100).                                                                                                                                                                                                     | `85`        |
| `--scaling INT`               | Final image scale `%` (1–100).                                                                                                                                                                                                | `100`       |
| `--split STRING`              | Split by size (`400MB`) or chapters (`10ch`).                                                                                                                                                                                | `None`      |
| `--restore-parameters`        | Reuse saved processing settings (for format-only reassembly).                                                                                                                                                                 | `False`     |
| `--keep-images`               | Retain raw downloaded images under `comics/<Title>/Chapter_<n>/`.                                                                                                                                                             | `False`     |
| `--keep-chapters`             | Save each chapter as a separate file (`.pdf`, `.epub`, or `.cbz`).                                                                                                                                                            | `False`     |
| `--no-cleanup`                | Do not delete the temporary directory (`tmp_<hid>/`) after completion.                                                                                                                                                        | `False`     |
| `-v, --verbose`               | Enable detailed logging.                                                                                                                                                                                                      | `False`     |
| `-d, --debug`                 | Enable debug-level logging (image processing details).                                                                                                                                                                        | `False`     |

---

## 🔐 Cookie Setup

If authentication is required, export your cookies:

```bash
export COOKIES='ads_provider2="…"; membership_alert=true; …'
```

Then run:

```bash
python3 comick_downloader.py --cookies "$COOKIES" \
  https://comick.io/comic/your-comic-url
```

---

## 📖 Examples

1. **Page-layout EPUB**, chapters 1–2, preferred group **Asura**, verbose:

   ```bash
   python3 comick_downloader.py \
     --cookies "$COOKIES" \
     --group Asura \
     --chapters "1-2" \
     --format epub \
     --epub-layout page \
     --verbose \
     https://comick.io/comic/demo-comic
   ```

2. **Vertical EPUB**, chapters 1–20, split every 5 chapters, verbose & debug:

   ```bash
   python3 comick_downloader.py \
     --group Asura \
     --chapters "1-20" \
     --format epub \
     --epub-layout vertical \
     --split 5ch \
     --verbose --debug \
     https://comick.io/comic/demo-comic
   ```

3. **CBZ**, chapters 1–2, one chapter per file:

   ```bash
   python3 comick_downloader.py \
     --group Asura \
     --chapters "1-2" \
     --format cbz \
     --split 1ch \
     https://comick.io/comic/demo-comic
   ```

4. **PDF**, chapters 1–2, save each chapter separately:

   ```bash
   python3 comick_downloader.py \
     --group Asura \
     --chapters "1-2" \
     --format pdf \
     --keep-chapters \
     https://comick.io/comic/demo-comic
   ```

---

## 💡 Tips & Tricks

Here are some handy pointers to get the most out of your workflow:

- 🔄 **Ongoing Series Updates**  
  • Use `--no-cleanup` to keep your temporary data around and reuse the same settings.  
  • Run again whenever new chapters appear, only new content will be downloaded & processed. 
 • You can use `--restore-parameters` to restore input parameters to exactly match the previous one.
 
- 🗂️ **Archiving Originals**  
  • Add `--keep-images` to save every raw page under `comics/<Title>/Chapter_<n>/`.  
  • Useful if you want to re-process images later (different layout, quality, etc.).

- 📑 **Precise Chapter Selection**  
  • Use `--chapters "1-20,21,23-100"` to include exactly the chapters you want (skip fillers or extras).  
  • Supports single numbers, ranges, and comma-separated lists.    
  • Use `--no-partials` to skip fractional chapters such as 1.5, 30.1 or other non decimal exclusive chapters in order to prevent duplicates within your final export.

- ⚙️ **Recover from Failures**  
  • After a crash or network hiccup, rerun with `--restore-parameters`, which will restore all parameters except for your desired file format. 
  *(Please remember that PDFs don't adhere to aspect ratios the same way as EPUBs & CBZs do, so going from pdf to either of them isn't recommended, the other way around works fine.)*

- 🍏 **Apple Books Friendly**  
  • Apple Books can choke on massive EPUBs— personal recommendation: split into ~10-chapter chunks: `--split 10ch`.  
  • Alternatively, split by size: `--split 200MB`.

- 📖 **EPUB Layout Recommendations**  
  • For standard e-readers (Kindle, Kobo): `--epub-layout page`.  
  • For continuous scroll (Apple Books, PocketBook): `--epub-layout vertical`.

- 🎨 **Control Output Quality & Size**  
  • `--quality 60` to drop JPEG quality for smaller files.  
  • `--scaling 80` to downscale pages to 80% of the original processed size.  
  • Combine with `--split` to keep individual file sizes manageable.

- 🏷️ **Best Scanlation Version**  
  • `--group "YourFavGroup"` to prefer a specific scanlation team or even teams by using  `--group "YourFavGroup1, YourFavGroup2"`.  
  • Add `--mix-by-upvote` to pick the highest-upvoted release among your chosen groups.

- 🔍 **Debugging & Verbose Logs**  
  • `-v` / `--verbose` for step-by-step progress.  
  • `-d` / `--debug` for deep image-processing insights (resizing, recombining).

- 📦 **Per-Chapter Files**  
  • Use `--keep-chapters` to save each chapter as its own PDF/EPUB/CBZ alongside the main book.

---

## 📁 Output Structure

*   **Temporary Data**: `tmp_<hid>/`
    *   `run_params.json`: Stores the processing settings for resume functionality.
*   **Final Files**: `comics/`
    *   Named `<Title>[_Groups]_Ch_<start>-<end>.<format>` (e.g., `My_Awesome_Comic_Asura_Ch_1-5.epub`)
*   **Raw Images** (if `--keep-images` is used):
    *   `comics/<Title>/Chapter_<n>/` (e.g., `comics/My_Awesome_Comic/Chapter_1/`)

```
tmp_<hid>/                   # Temporary workspace
└── run_params.json          # Saved settings (resume/restore)
comics/
├── <Title>[_Groups]_Ch_a-b.epub/pdf/cbz   # Final build(s)
└── <Title>/Chapter_<n>/                  # Raw images (if --keep-images)
```

- Final files → `comics/`  
- Use `--no-cleanup` to inspect `tmp_<hid>/` after completion  
- Re-run with `--restore-parameters` + new `--format` to reassemble without re-downloading

---

## ⚖️ Disclaimer

This tool is provided strictly for educational purposes and to help you create personal, offline backups of manga to which you have legal access. Please respect the rights of content creators and publishers—unauthorized sharing, piracy, or redistribution of material is prohibited.

---

## 🤝 Contributing

1. Fork the repo  
2. Create a feature branch (`git checkout -b feature/foo`)  
3. Test your update with `/test_scripts/python_version_tester.sh`
4. Commit (`git commit -m "Add foo"`)  
5. Push (`git push origin feature/foo`)  
7. Open a Pull Request  

Please follow the existing style and include tests where applicable.

---

## 🙏 Acknowledgements

This project stands on the shoulders of many wonderful open-source tools and libraries—thank you to all the maintainers and contributors who make these possible, thank you:

- **Python** ([CPython](https://github.com/python/cpython)) – The language powering this script  
- **requests** ([psf/requests](https://github.com/psf/requests)) – HTTP for Humans  
- **cloudscraper** ([VeNoMouS/cloudscraper](https://github.com/VeNoMouS/cloudscraper)) – Seamless Cloudflare anti-bot bypass  
- **Beautiful Soup** ([BeautifulSoup](https://www.crummy.com/software/BeautifulSoup/)) – HTML/XML parsing made easy  
- **lxml** ([lxml/lxml](https://github.com/lxml/lxml)) – Fast, feature-rich XML/HTML processing  
- **Pillow** ([python-pillow/Pillow](https://github.com/python-pillow/Pillow)) – The friendly PIL fork for image manipulation  
- **pypdf** ([py-pdf/pypdf](https://github.com/py-pdf/pypdf)) – PDF generation and manipulation  

---

## 📄 License

This project is licensed under the [GNU GPLv3](LICENSE).

---
